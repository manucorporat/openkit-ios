//
//  OKHelper.m
//  OKClient
//
//  Created by Suneet Shah on 1/7/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "OKHelper.h"

@implementation OKHelper

+ (NSDate *)dateNDaysFromToday:(int)n
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = n;
    return [calendar dateByAddingComponents:components toDate:now options:0];
}


+ (NSString*) persistentPath:(NSString*)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *nspath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    nspath = [nspath stringByAppendingPathComponent:filename];
    return nspath;
}

@end
