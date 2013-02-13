//
//  OKScore.m
//  OKClient
//
//  Created by Suneet Shah on 1/3/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "OKScorePrivate.h"
#import "OKUserPrivate.h"
#import "OKDirector.h"
#import "OKConfig.h"
#import "OKLeaderboard.h"
#import "OKNetworker.h"
#import "OKDefines.h"

@implementation OKScore

@synthesize leaderboardID, scoreID, scoreValue, user, scoreRank, isPending;

- (id)initWithValue:(NSInteger)integer
{
    self = [super init];
    if (self) {
        self.scoreValue = integer;
    }
    return self;
}


- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        // Initialization code here.
        leaderboardID   = [[dict objectForKey:OK_KEY_LEADERBOARDID] integerValue];
        scoreID         = [[dict objectForKey:OK_KEY_ID] integerValue];
        scoreValue      = [[dict objectForKey:OK_KEY_SCOREVALUE] integerValue];
        scoreRank       = [[dict objectForKey:OK_KEY_SCORERANK] integerValue];
        isPending       = [[dict objectForKey:OK_KEY_SCOREPENDING] boolValue];
        user            = [[OpenKit sharedInstance] getUserForDictionary:[dict objectForKey:@"user"]];
    }
    
    return self;
}


-(NSDictionary*)representation
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:scoreID], OK_KEY_ID,
                          [NSNumber numberWithInt:scoreValue], OK_KEY_SCOREVALUE,
                          [NSNumber numberWithInt:scoreRank], OK_KEY_SCORERANK,
                          [NSNumber numberWithInt:leaderboardID], OK_KEY_LEADERBOARDID,
                          [NSNumber numberWithBool:isPending], OK_KEY_SCOREPENDING,
                          [user JSONRepresentation], @"user", nil];
    
    return dict;
}


-(NSDictionary*)JSONRepresentation
{    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:scoreValue], OK_KEY_SCOREVALUE,
                          [NSNumber numberWithInt:leaderboardID], OK_KEY_LEADERBOARDID, nil];
    
    return dict;
}


- (BOOL)isGreaterThan:(OKScore*)score
{
    if(!score)
        return YES;
    
    if(self.leaderboardID != score.leaderboardID ) {
        NSLog(@"Impossible to compare scores.");
        return NO;
    }
    
    return (self.scoreValue > score.scoreValue);
}


- (void)submitTo:(NSInteger)lID withCompletionHandler:(void (^)(NSError *error))completion
{
    OKLeaderboard *leaderboard = [OKLeaderboard leaderboardForID:lID];
    if(!leaderboard && completion) {
        NSError *error;
        completion(error);
    }
    
    [leaderboard submitScore:self withCompletionHandler:completion];
}

@end
