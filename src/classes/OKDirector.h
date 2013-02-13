//
//  OKDirector.h
//  OKClient
//
//  Created by Suneet Shah on 12/27/12.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OKUser;
@interface OpenKit : NSObject

+ (id)sharedInstance;
- (OKUser*)getUserForDictionary:(NSDictionary*)dict;
- (void)saveCurrentUser:(OKUser *)aCurrentUser;
- (void)logoutCurrentUser;

+(void) initializeWithAppID:(NSString *)appID
                    version:(NSString*)version
                  secretKey:(NSString*)secretKey;
+(NSString*)getApplicationID;
+(BOOL)handleOpenURL:(NSURL*)url;
+(void)handleDidBecomeActive;
+(void)handleWillTerminate;

@end
