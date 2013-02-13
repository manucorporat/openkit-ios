//
//  OKLeaderboard.m
//  OKClient
//
//  Created by Suneet Shah on 1/3/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "OKLeaderboardPrivate.h"
#import "OKDirector.h"
#import "OKConfig.h"
#import "OKUserPrivate.h"
#import "OKScorePrivate.h"
#import "OKHelper.h"
#import "OKNetworker.h"

static NSArray *_leaderboards = nil;

@interface OKLeaderboard ()
{
    NSArray *scores_[OKLeaderboardTimeRange_sentinel];
}

@end

@implementation OKLeaderboard

@synthesize leaderboardID, name, in_development, sortType, icon_url, playerCount, userScore;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if ((self = [super init])) {
        [self configWithDictionary:dict];
    }
    return self;
}


- (void)configWithDictionary:(NSDictionary*)dict
{
    NSString *sortTypeString = [dict objectForKey:@"sort_type"];

    name                = [dict objectForKey:@"name"];
    leaderboardID       = [[dict objectForKey:OK_KEY_ID] integerValue];
    in_development      = [[dict objectForKey:@"in_development"] boolValue];
    sortType            = ([sortTypeString isEqualToString:@"HighValue"]) ? HighValue : LowValue;
    playerCount         = [[dict objectForKey:@"player_count"] integerValue];
    
    if([dict objectForKey:@"icon_url"])
        icon_url        = [dict objectForKey:@"icon_url"];
    
    if([dict objectForKey:@"userScore"])
        userScore       = [[OKScore alloc] initWithDictionary:[dict objectForKey:@"userScore"]];
}


- (void)setUserScore:(OKScore *)score
{
    userScore = score;
    [userScore setLeaderboardID:leaderboardID];
    [userScore setUser:[OKUser currentUser]];
    [userScore setIsPending:YES];
}


- (void)pushUserScore:(OKScore*)score
{
    if([score isGreaterThan:userScore])
        [self setUserScore:score];
}


- (void)submitScore:(OKScore*)score withCompletionHandler:(void (^)(NSError *error))completionHandler
{
    [self pushUserScore:score];
    [self resolvePendingScoreWithCompletionHandler:completionHandler];    
}


- (void)resolvePendingScoreWithCompletionHandler:(void (^)(NSError *error))completion
{
    if([userScore isPending]) {
        
        //Create a request and send it to OpenKit
        NSDictionary *params = [userScore JSONRepresentation];
        
        [OKNetworker postToPath:OK_URL_SCORES
                     parameters:params
                        handler:^(id responseObject, NSError *error)
         {
             if(!error) {
                 NSLog(@"Successfully posted score");
                 [userScore setIsPending:NO];
             }else{
                 NSLog(@"Failed to post score.");
                 NSLog(@"Error: %@", error);
             }
             if(completion)
             completion(error);
         }];
    }else
        completion(nil);
}


- (NSArray*)getScoresForTimeRange:(OKLeaderboardTimeRange)timeRange
{
    if(timeRange >= OKLeaderboardTimeRange_sentinel) {
        NSLog(@"Invalid leaderboard");
        return nil;
    }
    
    return scores_[timeRange];
}


- (void)getScoresForTimeRange:(OKLeaderboardTimeRange)timeRange
        withCompletionHandler:(void (^)(NSArray* scores, NSError *error))completion
{
    if(timeRange >= OKLeaderboardTimeRange_sentinel) {
        NSLog(@"Invalid leaderboard");
        completion(nil, nil);
        return;
    }
    NSArray *scores = scores_[timeRange];
    int distance = [self.lastUpdate timeIntervalSinceNow];
    if(scores == nil || distance < -(3600*2)) { // 3600seconds each hour
        [self fetchScoreForTimeRange:timeRange withCompletionHandler:^(NSArray* array, NSError* error)
         {
             if(!error)
                 completion(array, error);
             else
                 completion(scores, error);
         }];
    }else{
        completion(scores, nil);
    }
}


- (void)fetchScoreForTimeRange:(OKLeaderboardTimeRange)timeRange
         withCompletionHandler:(void (^)(NSArray* scores, NSError *error))completion
{
    //Create a request and send it to OpenKit
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSNumber numberWithInt:leaderboardID] forKey:@"leaderboard_id"];
    
    if (timeRange != OKLeaderboardTimeRangeAllTime) {
        int days;
        switch (timeRange) {
            case OKLeaderboardTimeRangeOneDay:  days = -1;      break;
            case OKLeaderboardTimeRangeOneWeek: days = -7;      break;
            default:                            days = INT_MIN; break;
        }

        NSDate *since = [OKHelper dateNDaysFromToday:days];
        [params setValue:since forKey:@"since"];
    }
    
    
    // OK NETWORK REQUEST
    [OKNetworker getFromPath:OK_URL_SCORES parameters:params
                     handler:^(id responseObject, NSError *error)
    {
        NSMutableArray *scores = nil;
        if(!error) {
            NSLog(@"Successfully got scores: %@", responseObject);

            NSArray *scoresJSON = (NSArray*)responseObject;
            NSMutableArray* scores = [NSMutableArray arrayWithCapacity:[scoresJSON count]];
            
            for(NSDictionary *dict in scoresJSON) {
                OKScore *score = [[OKScore alloc] initWithDictionary:dict];
                [scores addObject:score];
            }
            scores[timeRange] = [NSArray arrayWithArray:scores];
            
        }else{
            NSLog(@"Failed to get scores");
        }
        if(completion)
        completion(scores, error);
    }];
}


#pragma mark - Class methods

+ (NSString*)databasePath
{
    return [OKHelper persistentPath:OK_LEADERBOARD_DB_FILE];
}


+ (NSArray*)leaderboards
{
    return _leaderboards;
}


+ (OKLeaderboard*)leaderboardForID:(NSInteger)ok_id
{
    for(OKLeaderboard* leaderboard in [OKLeaderboard leaderboards]) {
        if(leaderboard.leaderboardID == ok_id)
            return leaderboard;
    }
    return nil;
}


+ (void)preload
{
    if(_leaderboards) {
        NSLog(@"[OKCloud preload] only can be called once.");
        return;
    }
    
    // This method is called automatically by OKDirector when OpenKit is initialized.
    // We preload the leaderboards from local memory (ROM).
    
    NSArray *leaderBoardsJSON = [NSArray arrayWithContentsOfFile:[OKLeaderboard databasePath]];
    NSMutableArray *leaderBoards = [NSMutableArray arrayWithCapacity:[leaderBoardsJSON count]];
    
    for(id obj in leaderBoardsJSON) {
        OKLeaderboard *leaderBoard = [[OKLeaderboard alloc] initWithDictionary:obj];
        [leaderBoards addObject:leaderBoard];
    }
    _leaderboards = [NSArray arrayWithArray:leaderBoards];
}


+ (void)resolveWithCompletionHandler:(void (^)(NSError* error))completion
{
    // TRY TO RESOLVE
    __block int total = [_leaderboards count];
    __block int count = 0;
    for(OKLeaderboard *leaderboard in _leaderboards) {
        [leaderboard resolvePendingScoreWithCompletionHandler:^(NSError *error)
         {
             ++count;
             if(total == count)
                 completion(error);
         }];
    }
    

}


+ (void)syncWithCompletionHandler:(void (^)(NSError* error))completion
{
    [OKLeaderboard resolveWithCompletionHandler:^(NSError *error)
     {
         // OK NETWORK REQUEST
         [OKNetworker getFromPath:OK_URL_LEADERBOARDS
                       parameters:nil
                          handler:^(id responseObject, NSError *error)
          {
              if(!error) {
                  NSLog(@"Successfully got list of leaderboards");
                  NSLog(@"Leaderboard response is: %@", responseObject);
                  NSArray *leaderBoardsJSON = (NSArray*)responseObject;
                  NSMutableArray *leaderboards = [NSMutableArray arrayWithCapacity:[leaderBoardsJSON count]];
                  
                  for(id obj in leaderBoardsJSON) {
                      OKLeaderboard *board = [OKLeaderboard leaderboardForID:[[obj objectForKey:OK_KEY_ID] integerValue]];
                      if(board)
                          [board configWithDictionary:obj];
                      else
                          board = [[OKLeaderboard alloc] initWithDictionary:obj];
                      
                      [leaderboards addObject:board];
                  }
                  
                  // Set leaderboards and save in memory
                  _leaderboards = [NSArray arrayWithArray:leaderboards];
                  [leaderBoardsJSON writeToFile:[OKLeaderboard databasePath] atomically:YES];
                  
              }else{
                  NSLog(@"Failed to get list of leaderboards: %@", error);
              }
              if(completion)
                  completion(error);
          }];
     }];
}

@end
