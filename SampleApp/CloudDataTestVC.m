//
//  CloudDataTestVC.m
//  SampleApp
//
//  Created by Louis Zell on 1/30/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "CloudDataTestVC.h"
#import "OKCloud.h"
#import "OpenKit.h"


@implementation CloudDataTestVC

-(void)viewDidLoad
{
    [[self navigationItem] setTitle:@"Cloud Data Test"];
    
    if(![OKUser currentUser])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must be logged into OpenKit to test cloud data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)storeString:(id)sender
{
    [OKCloud setObject:@"Hello World" forKey:@"firstKey"];
}

- (IBAction)retrieveString:(id)sender
{
    NSString *string = [OKCloud objectForKey:@"firstKey"];
    if (string) {
        NSLog(@"Successfully got: %@", string);
    } else {
        NSLog(@"Error getting string!");
    }
}

- (IBAction)storeDict:(id)sender
{
    NSArray *arr = [NSArray arrayWithObjects:@"one", @"two", nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"foo",                           @"property1",
                          [NSNumber numberWithInt:-99],     @"property2",
                          [NSNumber numberWithBool:YES],    @"property3",
                          arr,                              @"property4",
                          nil];
    
    [OKCloud setObject:dict forKey:@"secondKey"];
}

- (IBAction)retrieveDict:(id)sender
{
    NSDictionary *dict = [OKCloud objectForKey:@"secondKey"];
    
    if (dict) {
        NSLog(@"Successfully got: %@", dict);
        NSLog(@"Class of property1: %@", [[dict objectForKey:@"property1"] class]);
        NSLog(@"Class of property2: %@", [[dict objectForKey:@"property2"] class]);
        NSLog(@"Class of property3: %@", [[dict objectForKey:@"property3"] class]);
        NSLog(@"Class of property4: %@", [[dict objectForKey:@"property4"] class]);
    } else {
        NSLog(@"Error getting dictionary!");
    }
}



@end
