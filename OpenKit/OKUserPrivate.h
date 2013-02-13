//
//  OKUserPrivate.h
//  OKClient
//
//  Created by Manuel Martinez-Almeida on 2/11/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OKUser.h"

@interface OKUser (Private)

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONRepresentation;

@end
