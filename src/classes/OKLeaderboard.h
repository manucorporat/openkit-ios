//
//  OKLeaderboard.h
//  OKClient
//
//  Created by Suneet Shah on 1/3/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HighValue,
    LowValue
} LeaderBoardSortType;

typedef enum {
    OKLeaderboardTimeRangeOneDay,
    OKLeaderboardTimeRangeOneWeek,
    OKLeaderboardTimeRangeAllTime,
    
    OKLeaderboardTimeRange_sentinel,
} OKLeaderboardTimeRange;


@class OKScore;
@interface OKLeaderboard : NSObject

@property (nonatomic, readonly) NSInteger leaderboardID;
@property (nonatomic, readonly) BOOL in_development;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, readonly) LeaderBoardSortType sortType;
@property (nonatomic, strong, readonly) NSString *icon_url;
@property (nonatomic, strong, readonly) NSDate *lastUpdate;
@property (nonatomic, strong) OKScore *userScore;
@property (nonatomic, readonly) int playerCount;

- (void)submitScore:(OKScore*)score withCompletionHandler:(void (^)(NSError *error))completionHandler;
- (NSArray*)getScoresForTimeRange:(OKLeaderboardTimeRange)timeRange;
- (void)getScoresForTimeRange:(OKLeaderboardTimeRange)timeRange withCompletionHandler:(void (^)(NSArray* scores, NSError *error))completion;

+ (NSArray*)leaderboards;
+ (OKLeaderboard*)leaderboardForID:(NSInteger)ok_id;
+ (void)syncWithCompletionHandler:(void (^)(NSError* error))handler;
@end
