//
//  OKScore.h
//  OKClient
//
//  Created by Suneet Shah on 1/3/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OKUser;
@interface OKScore : NSObject

@property (nonatomic) NSInteger scoreValue;
@property (nonatomic) NSInteger leaderboardID;
@property (nonatomic, readonly) NSInteger scoreID;
@property (nonatomic, readonly) NSInteger scoreRank;
@property (nonatomic, strong) OKUser *user;
@property (nonatomic) BOOL isPending;

- (id)initWithValue:(NSInteger)integer;
- (void)submitTo:(NSInteger)leaderboardID withCompletionHandler:(void (^)(NSError *error))completion;
- (BOOL)isGreaterThan:(OKScore*)score;

@end
