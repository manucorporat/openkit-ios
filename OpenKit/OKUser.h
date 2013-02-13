//
//  OKUser.h
//  OKClient
//
//  Created by Suneet Shah on 12/27/12.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKUser : NSObject

@property (nonatomic, strong, readonly) NSNumber *userID;
@property (nonatomic, strong, readonly) NSString *secretKey;
@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSMutableDictionary *auth;

- (void)syncWithCompletionHandler:(void(^)(NSError *error))handler;
- (void)addAuth:(id)key service:(NSString*)service;
- (NSString*)authKeyForService:(NSString*)service;

+ (OKUser*)currentUser;
+ (void)logoutCurrentUserFromOpenKit;

@end
