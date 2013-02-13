//
//  OKCrypto.m
//  OKClient
//
//  Created by Manuel Martinez-Almeida on 2/11/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "OKCrypto.h"

@implementation OKCrypto

+ (NSData*) encryptData:(NSData*)data key:(char*)key
{
    return data;
}


+(NSData*) decryptData:(NSData*)data key:(char*)key
{
    return data;
}


+ (NSData*) encryptWithAppKey:(NSData*)data
{
    return [OKCrypto encryptData:data key:NULL];
}


+ (NSData*) decryptWithAppKey:(NSData*)data
{
    return [OKCrypto decryptData:data key:NULL];
}

@end