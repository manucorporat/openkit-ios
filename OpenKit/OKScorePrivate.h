//
//  OKScorePrivate.h
//  OKClient
//
//  Created by Manuel Martinez-Almeida on 2/11/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OKScore.h"

@interface OKScore (Private)

- (id)initWithDictionary:(NSDictionary*)dict;
- (NSDictionary*)JSONRepresentation;

@end
