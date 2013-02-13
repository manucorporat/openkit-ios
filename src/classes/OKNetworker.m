//
//  OKNetworker.m
//  OKClient
//
//  Created by Manuel Martinez-Almeida on 2/9/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "OKNetworker.h"
#import "OKDirector.h"
#import "OKUser.h"
#import "OKCrypto.h"
#import "OKConfig.h"
#import "AFNetworking.h"


#if OK_CRYPTO
@interface OKRequestGETOperation : AFJSONRequestOperation
{ };
@end

@interface OKRequestPOSTOperation : AFJSONRequestOperation
{
    NSString *decrypted;
};
@end


@implementation OKRequestPOSTOperation

- (NSString *)responseString {
    
    if(!decrypted) {
        decrypted = (NSString*)[OKCryto decryptOK:[[super responseString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return decrypted;
}

@end
#endif


static OKNetworker *_sharedInstance = nil;

@interface OKNetworker ()
{
    AFHTTPClient *getClient_;
    AFHTTPClient *postClient_;
};

@end


@implementation OKNetworker

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if(!_sharedInstance)
            _sharedInstance = [[OKNetworker alloc] init];
        
        return _sharedInstance;
    }
}


- (id)init
{
    self = [super init];
    if (self) {
        
        NSURL *url = [NSURL URLWithString:OK_BASE_URL];
        
        // We need different http clients because OpenKit
        // performs POST and GET requests in a different way.
        
        // GET http client
        getClient_  = [[AFHTTPClient alloc] initWithBaseURL:url];
        [getClient_ setDefaultHeader:@"Accept" value:@"application/json"];
        [getClient_ setDefaultHeader:@"Content-Type" value:@"application/json"];
        
        // POST http client
        postClient_ = [[AFHTTPClient alloc] initWithBaseURL:url];
        [postClient_ setDefaultHeader:@"Accept" value:@"application/octet-stream"];
        [postClient_ setDefaultHeader:@"Content-Type" value:@"application/octet-stream"];
        [postClient_ setDefaultHeader:OK_KEY_APPID value:[OpenKit getApplicationID]];
        
#if OK_CRYPTO
        [getClient_ registerHTTPOperationClass:[OKRequestGETOperation class]];
        [postClient_ registerHTTPOperationClass:[OKRequestPOSTOperation class]];
#else
        [getClient_ registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [postClient_ registerHTTPOperationClass:[AFJSONRequestOperation class]];
#endif
        
    }
    return self;
}


- (NSMutableDictionary*) mergeGETParams:(NSDictionary*)d user:(OKUser*)user
{
    NSAssert([OpenKit getApplicationID], @"Application ID can not be NULL");
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:d];

    [dict setValue:[OpenKit getApplicationID] forKey:OK_KEY_APPID];
    [dict setValue:[user userID] forKey:OK_KEY_USERID];
        
    return dict;
}


- (NSMutableDictionary*) mergePOSTParams:(NSDictionary*)d user:(OKUser*)user
{
    NSAssert([OpenKit getApplicationID], @"Application ID can not be NULL");
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:d];
    
    [dict setValue:[OpenKit getApplicationID] forKey:OK_KEY_APPID];
    [dict setValue:[user userID] forKey:OK_KEY_USERID];
    [dict setValue:[user secretKey] forKey:OK_KEY_USERKEY];
    [dict setValue:[NSDate date] forKey:OK_KEY_TIME];
    [dict setValue:d forKey:OK_KEY_CONTENT];

    return dict;
}


- (void) requestWithMethod:(NSString*)method
                      path:(NSString*)path
                parameters:(NSDictionary*)params
                      user:(OKUser*)user
                   handler:(void (^)(id responseObject, NSError* error))handler
{
    NSError *error;
    NSData *data;
    NSMutableURLRequest *request;
    AFHTTPClient *httpclient;

    if([method isEqualToString:@"GET"]) {
        httpclient = getClient_;
        params = [self mergeGETParams:params user:user];
        request = [httpclient requestWithMethod:method path:path parameters:params];
        
    }else{
        httpclient = postClient_;
        params = [self mergePOSTParams:params user:user];
        data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
#if OK_CRYPTO
        data = [OKCrypto encryptWithAppKey:data];
#endif
        request = [httpclient requestWithMethod:method path:path parameters:nil];
        [request setHTTPBody:data];
    }


    // Perform request
    AFHTTPRequestOperation *operation = [httpclient HTTPRequestOperationWithRequest:request success:
     ^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if(handler)
         handler(responseObject, nil);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if(handler)
         handler(nil, error);
     }];
    [operation start];
}


+ (void) getFromPath:(NSString*)path
          parameters:(NSDictionary*)params
             handler:(void (^)(id responseObject, NSError* error))handler
{
    [[OKNetworker sharedInstance] requestWithMethod:@"GET"
                                               path:path
                                         parameters:params
                                               user:[OKUser currentUser]
                                            handler:handler];
}


+ (void) postToPath:(NSString*)path
         parameters:(NSDictionary*)params
            handler:(void (^)(id responseObject, NSError* error))handler
{
    [[OKNetworker sharedInstance] requestWithMethod:@"POST"
                                               path:path
                                         parameters:params
                                               user:[OKUser currentUser]
                                            handler:handler];
}


+ (void) putToPath:(NSString*)path
        parameters:(NSDictionary*)params
           handler:(void (^)(id responseObject, NSError* error))handler
{
    [[OKNetworker sharedInstance] requestWithMethod:@"PUT"
                                               path:path
                                         parameters:params
                                               user:[OKUser currentUser]
                                            handler:handler];
}

@end
