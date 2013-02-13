//
//  OKUser.m
//  OKClient
//
//  Created by Suneet Shah on 12/27/12.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "OKUserPrivate.h"
#import "OKDirector.h"
#import "OKConfig.h"
#import "OKNetworker.h"
#import "OKDefines.h"

@interface OKUser ()
{
    BOOL isDirty_;
}

@end


@implementation OKUser

@synthesize userID, secretKey, nick, auth;

- (id)init
{
    self = [super init];
    if (self) {
        
        isDirty_        = NO;
        secretKey       = nil;
        
        userID          = nil;
        nick            = nil;
        auth            = [NSMutableDictionary dictionary];
    }
    return self;
}


- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self configWithDictionary:dict];
    }
    return self;
}


- (void)addAuth:(id)key service:(NSString*)service
{
    [auth setObject:key forKey:service];
}


- (NSString*)authKeyForService:(NSString*)service
{
    return [auth objectForKey:service];
}


- (void)configWithDictionary:(NSDictionary*)dict
{
    NSNumber *uID = [dict objectForKey:OK_KEY_ID];
    NSString *uSecretkey = [dict objectForKey:OK_KEY_USERKEY];
    NSString *uNick = [dict objectForKey:OK_KEY_USERNICK];
    NSDictionary *uAuth = [dict objectForKey:OK_KEY_USERAUTH];
    
    userID = uID;
    secretKey = uSecretkey;
    nick = uNick;
    auth = [NSMutableDictionary dictionaryWithDictionary:uAuth];
}


- (NSDictionary *)JSONRepresentation
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          nick, @"nick",
                          auth, @"auth", nil];
    return dict;
}


- (void)syncWithCompletionHandler:(void(^)(NSError *error))completion
{
    // This method works in two different ways.
    // Updating a current user or creating a new one.
    
    NSString *requestPath = nil;
    if(userID) {
        if(!secretKey) {
            if(completion) {
                NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:@"You don't have priviliges to modify this user."
                                                                      forKey:NSLocalizedDescriptionKey];
                NSError *error = [[NSError alloc] initWithDomain:OKErrorDomain code:0 userInfo:errorInfo];
                completion(error);
            }
            return;
        }
        requestPath = [NSString stringWithFormat:OK_URL_USERS@"/%@", [userID stringValue]];
        
    }else{
        requestPath = OK_URL_USERS;
    }
    
    
    [[OKNetworker sharedInstance] requestWithMethod:@"POST"
                                               path:requestPath
                                         parameters:[self JSONRepresentation]
                                               user:self
                                            handler:^(id responseObject, NSError *error)
     {
         if(!error)
             [self configWithDictionary:responseObject];

         else
             NSLog(@"Error updating username: %@", error);
         
         if(completion)
         completion(error);
     }];
}


+ (OKUser*)currentUser
{
    return [[OpenKit sharedInstance] currentUser];
}


+ (void)logoutCurrentUserFromOpenKit
{
    [[OpenKit sharedInstance] logoutCurrentUser];
}

@end
