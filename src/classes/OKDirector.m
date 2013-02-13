//
//  OKDirector.m
//  OKClient
//
//  Created by Suneet Shah on 12/27/12.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "OKDirector.h"
#import "OKLeaderboardPrivate.h"
#import "OKUserPrivate.h"
#import "OKConfig.h"
#import "OKFacebookUtilities.h"
#import "OKTwitterUtilities.h"
#import "OKCloud.h"
#import "SimpleKeychain.h"
#import "OKMacros.h"
#import "OKDefines.h"


@interface OpenKit ()
{
    NSString *secretKey_;
    NSString *version_;
    OKUser *currentUser_;
}
- (id)initWithAppID:(NSString*)appid;

@property (nonatomic, strong) NSString *OKAppID;

@end

static OpenKit *_sharedInstance = nil;

@implementation OpenKit

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if(!_sharedInstance)
            OK_RAISE(@"OpenKit must be initiliazed first.");
                
        return _sharedInstance;
    }
}


+(void) initializeWithAppID:(NSString *)appID
                    version:(NSString*)version
                  secretKey:(NSString*)secretKey
{
    @synchronized(self)
    {
        if(!_sharedInstance) {
            _sharedInstance = [OpenKit alloc];
            _sharedInstance = [_sharedInstance initWithAppID:appID
                                                     version:version
                                                   secretKey:secretKey];
        }else
            OK_RAISE(@"OpenKit was already initialized.");
    }
}


- (id)initWithAppID:(NSString*)appid
            version:(NSString*)version
          secretKey:(NSString*)secretKey
{
    self = [super init];
    if (self) {
        // ?? what is this? in case this makes sence, does it should be here?
        [FBProfilePictureView class];
        
        version_ = appid;
        secretKey_ = secretKey;
        
        [self setOKAppID:appid];
        
        // try to autologin from keychain
        [self autoLogin];
        
        // preload OpenKit from local memory
        [self preload];
        
        // try to sync with server
        [self sync];
        
        // schedule
        [self schedule];
    }
    return self;
}


- (void)schedule
{
    [NSTimer timerWithTimeInterval:2
                            target:self
                          selector:@selector(push)
                          userInfo:nil
                           repeats:YES];
}




- (void)push
{
    [OKCloud pushWithCompletionHandler:nil];
}


- (BOOL)autoLogin
{
    OKUser *user = [self getSavedUserFromKeychain];
    if(user) {
        currentUser_ = user;
        [OKFacebookUtilities OpenCachedFBSessionWithoutLoginUI];
    }
    return (user != NULL);
}


- (void)preload
{
    // preload cloud from local memory
    [OKCloud preload];
    
    // preload leaderboards from local memory
    [OKLeaderboard preload];
}


- (void)sync
{
    // sync cloud
    [OKCloud syncWithCompletionHandler:nil];
    
    // sync leaderboards
    [OKLeaderboard syncWithCompletionHandler:nil];
}


- (void)save
{
    [OKCloud save];
}


- (OKUser*)currentUser
{
    return currentUser_;
}

- (OKUser*)getUserForDictionary:(NSDictionary*)dict
{
    if([[dict objectForKey:OK_KEY_APPID] integerValue] == [[currentUser_ userID] integerValue])
        return currentUser_;
    else
        return [[OKUser alloc] initWithDictionary:dict];
}

+(NSString*)getApplicationID
{
    return [[OpenKit sharedInstance] OKAppID];
}


- (void)logoutCurrentUser
{
    if(currentUser_) {
        NSLog(@"Logged out of openkit");
        currentUser_ = nil;
        [self removeCachedUserFromKeychain];
        //Log out and clear Facebook
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}


- (void)saveCurrentUser:(OKUser *)aCurrentUser
{
    currentUser_ = aCurrentUser;
    [self removeCachedUserFromKeychain];
    [self saveCurrentUserToKeychain];
}


- (void)saveCurrentUserToKeychain
{
    NSDictionary *userDict = [currentUser_ JSONRepresentation];
    [SimpleKeychain store:[NSKeyedArchiver archivedDataWithRootObject:userDict]];
}


- (OKUser*)getSavedUserFromKeychain
{
    NSDictionary *userDict;
    NSData *keychainData = [SimpleKeychain retrieve];
    if(!keychainData) {
        NSLog(@"Found  cached OKUser");
        userDict = [[NSKeyedUnarchiver unarchiveObjectWithData:keychainData] copy];
        return [[OKUser alloc] initWithDictionary:userDict];
    }
    else {
        NSLog(@"Did not find cached OKUser");
    }
    return nil;
}


- (void)removeCachedUserFromKeychain
{
    [SimpleKeychain clear];
}


#pragma mark - Application events handling

+(BOOL)handleOpenURL:(NSURL*)url
{
    return [OKFacebookUtilities handleOpenURL:url];
}
+(void)handleDidBecomeActive
{
    [OKFacebookUtilities handleDidBecomeActive];
}
+(void)handleWillTerminate
{
    [OKFacebookUtilities handleWillTerminate];
}


@end
