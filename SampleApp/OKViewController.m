//
//  OKViewController.m
//  SampleApp
//
//  Created by Suneet Shah on 12/26/12.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "OKViewController.h"
#import "ScoreSubmitterVC.h"
#import "CloudDataTestVC.h"



@implementation OKViewController


- (id)init
{
    self = [super initWithNibName:@"OKViewController" bundle:nil];
    self.navigationItem.title = @"OpenKit Sample App";
    return self;
}


-(void)updateUIforOKUser
{
    if ([OKUser currentUser]) {
        [self.loginButton setHidden:YES];
        [self.logoutButton setHidden:NO];
        
        [self.profileImageView setUser:[OKUser currentUser]];
        [self.userNickLabel setHidden:NO];
        [self.userNickLabel setText:[NSString stringWithFormat:@"%@", [[OKUser currentUser] nick]]];
    } else {
        [self.loginButton setHidden:NO];
        [self.logoutButton setHidden:YES];
        [self.profileImageView setUser:nil];
        [self.userNickLabel setHidden:YES];
        
    }
}


-(IBAction)logoutOfOpenKit:(id)sender
{
    [OKUser logoutCurrentUserFromOpenKit];
    [self updateUIforOKUser];
}

-(IBAction)loginToOpenKit:(id)sender
{
    OKLoginView *loginView = [[OKLoginView alloc] init];
    [loginView showWithCompletionHandler:^{
        [self updateUIforOKUser];
    }];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUIforOKUser];
}


-(IBAction)viewLeaderboards:(id)sender
{
    OKLeaderboardsViewController *leaderBoards = [[OKLeaderboardsViewController alloc] init];
    [self presentModalViewController:leaderBoards animated:YES];
}

-(IBAction)submitScore:(id)sender
{
    ScoreSubmitterVC *scoreSubmitter = [[ScoreSubmitterVC alloc] initWithNibName:@"ScoreSubmitterVC" bundle:nil];
    [self presentModalViewController:scoreSubmitter animated:YES];
}


- (IBAction)showCloudDataTest:(id)sender
{
    CloudDataTestVC *vc = [[CloudDataTestVC alloc] initWithNibName:@"CloudDataTestVC" bundle:nil];
    [[self navigationController] pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
