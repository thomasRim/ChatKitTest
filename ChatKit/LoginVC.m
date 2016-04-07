//
//  LoginVC.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/16/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "LoginVC.h"

#import "CHKChannelsViewController.h"

#import "AuthManager.h"
#import "SVProgressHUD.h"

@implementation LoginVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.passwordPlaceholder = @"my custom pass";
//    self.logoImage = [UIImage imageNamed:@"qr"];
//    self.minimupPasswordLength = 3;
//    self.backgroundImage = [UIImage imageNamed:@"qr"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}

- (void)previousSavedSession:(CHKSessionStatus)savedSessionExist
{
    switch (savedSessionExist) {
        case CHKSessionStatus_NotLogged: {
            [SVProgressHUD dismiss];
            break;
        }
        case CHKSessionStatus_LoggedIn:
        case CHKSessionStatus_CanResume: {
            [SVProgressHUD showWithStatus:@"Loading.."];
            [self resumeSession:nil];
            break;
        }
    }
}

@end
