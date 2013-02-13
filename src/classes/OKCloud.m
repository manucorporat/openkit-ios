//
//  OKCloud.m
//  OKClient
//
//  Created by Louis Zell on 1/23/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//
// Ruby:
// x = {"aKey"=>{"foo"=>"bar"}}
// x.to_json  #=> "{\"aKey\":{\"foo\":\"bar\"}}"
//
// GDB:
// po [[(NSDictionary *)[decoder objectWithUTF8String:"{\"aKey\":{\"foo\":\"bar\"}}" length:22] objectForKey:@"aKey"] class]  #=> JKDictionary
//
// Redis cli:
// hget "dev:1:user:11" "firstKey"

#define USE_JSONKIT  1



#import "OKCloud.h"
#import "OKUser.h"
#import "OKConfig.h"
#import "OKHelper.h"
#import "OKNetworker.h"
#import "JSONKit.h"

static NSMutableDictionary *_entries = nil;
static NSDate *_lastUpdated = nil;

@interface OKCloudObject : NSObject <NSCoding>
@property (nonatomic, strong) id obj;
@property (nonatomic, strong) NSDate *lastUpdate;
@end

@implementation OKCloudObject

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.obj = [aDecoder decodeObjectForKey:@"object"];
        self.lastUpdate = [aDecoder decodeObjectForKey:OK_KEY_LASTUPDATE];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.obj forKey:@"object"];
    [aCoder encodeObject:self.lastUpdate forKey:OK_KEY_LASTUPDATE];
}

@end


@implementation OKCloud

+ (void)setObject:(id)obj forKey:(NSString *)key
{
    if(obj == nil)
        obj = [NSNull null];
    
    OKCloudObject *wrapper = [[OKCloudObject alloc] init];
    [wrapper setObj:obj];
    [wrapper setLastUpdate:[NSDate date]];
    
    [_entries setObject:wrapper forKey:key];
}


+ (id)objectForKey:(NSString*)key
{
    OKCloudObject *wrapper = [_entries objectForKey:key];
    if([wrapper obj]==[NSNull null])
        return nil;
    
    return [wrapper obj];
}


#pragma mark - Local recovery methods

+ (NSString*) databasePath
{
    return [OKHelper persistentPath:OKCLOUD_DB_FILE];
}


+ (void)preload
{
    if(_entries) {
        NSLog(@"[OKCloud preload] only can be called once.");
        return;
    }
    
    // This method is called automatically by OKDirector when OpenKit is initialized.
    // We preload the dictionary of cloud savings from local memory (ROM).
    // This makes OKCloud able to work offline and reduces drastically the internet usage.
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[OKCloud databasePath]];
    if(dict) {
        _entries = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:OK_KEY_ENTRIES]];
        _lastUpdated = [dict objectForKey:OK_KEY_LASTUPDATE];
    }else{
        _entries = [NSMutableDictionary dictionaryWithCapacity:10];
        _lastUpdated = [NSDate distantPast];
    }
}


+ (void)saveLocally
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          _entries, OK_KEY_ENTRIES,
                          _lastUpdated, OK_KEY_LASTUPDATE, nil];
    
    [dict writeToFile:[OKCloud databasePath] atomically:YES];
}


#pragma mark - High level saving method

+ (void)save
{
    // This method should be called before the app is going to background
    
    // we save it locally
    [OKCloud saveLocally];
    
    // we try to sync it
    [OKCloud pushWithCompletionHandler:^(NSError *error) {
        [OKCloud saveLocally];
    }];
}


#pragma mark - Server/Client synchronization methods

+ (NSDictionary*)getDirtyEntries
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[_entries count]];
    [_entries enumerateKeysAndObjectsWithOptions:0 usingBlock:^(id key, id obj, BOOL *stop)
     {
         OKCloudObject *wrapper = obj;
         NSTimeInterval time = [_lastUpdated timeIntervalSinceDate:[wrapper lastUpdate]];
         if(time < 0)
             [dict setObject:wrapper forKey:key];
     }];
    return dict;
}


#pragma mark Networking

+ (void)syncWithCompletionHandler:(void (^)(NSError *error))completion
{
    // This method is called automatically by OKDirector when OpenKit is inialized.
    // We request to the server new/updated entries based in the last time the local date base was updated.
    OKUser *user = [OKUser currentUser];
    if(!user) {
        if(completion)
        completion(nil);
        return;
    }
    
    // The sync protocol perform a simple merge between both sides (client/server)
    // First. My get the dirty entries based in his last update date.
    // We send the dirty entries to the server-
    // The server updates his database internally and responds with the
    // entries that should change in the client.
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _lastUpdated, OK_KEY_LASTUPDATE,
                            [self getDirtyEntries], OK_KEY_ENTRIES, nil];
    
    [OKNetworker getFromPath:OK_URL_CLOUD
                  parameters:params
                     handler:^(id responseObject, NSError *error)
     {
         if (!error) {
             [_entries enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                 [self setObject:obj forKey:key];
             }];
             _lastUpdated = [NSDate date];
         }
         if(completion)
             completion(error);
     }];
}


+ (void)pushWithCompletionHandler:(void (^)(NSError *error))completion
{
    // We sync with the server if some entry is dirty
    if([[OKCloud getDirtyEntries] count] > 0)
        [self syncWithCompletionHandler:completion];
    else if(completion)
        completion(nil);
}

@end
