//
//  OKCrypto.h
//  OKClient
//
//  Created by Manuel Martinez-Almeida on 2/11/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKCrypto : NSObject

+ (NSData*) encryptData:(NSData*)data key:(char*)key;
+ (NSData*) decryptData:(NSData*)data key:(char*)key;

+ (NSData*) encryptWithAppKey:(NSData*)data;
+ (NSData*) decryptWithAppKey:(NSData*)data;

@end