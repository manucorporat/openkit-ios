//
//  OKCloud.h
//  OKClient
//
//  Created by Louis Zell on 1/23/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKCloud : NSObject

+ (void)setObject:(id)obj forKey:(NSString *)key;
+ (id)objectForKey:(NSString*)key;
+ (void)syncWithCompletionHandler:(void (^)(NSError *error))completion;
+ (void)pushWithCompletionHandler:(void (^)(NSError *error))completion;
+ (void)preload;
+ (void)save;

@end
