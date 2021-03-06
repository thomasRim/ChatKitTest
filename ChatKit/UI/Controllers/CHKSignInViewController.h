//
//  SignInViewController.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/15/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKBaseViewController.h"

@import MagnetMax;

typedef enum {
    CHKSessionStatus_NotLogged,
    CHKSessionStatus_CanResume,
    CHKSessionStatus_LoggedIn
} CHKSessionStatus;


@protocol CHKSignInViewController <NSObject>

- (void)previousSavedSession:(CHKSessionStatus)savedSessionExist;

@end

@interface CHKSignInViewController : CHKBaseViewController<CHKSignInViewController>

/**
 *  Customisation Properties
 */

@property (nonatomic, assign) BOOL hideRememberMeCheckbox; // default - NO

@property (nonatomic, assign) BOOL rememberMe; // default - YES

@property (nonatomic, copy) NSString *loginPlaceholder; // login input field placeholder
@property (nonatomic, copy) NSString *passwordPlaceholder; // password input fiels placeholder

@property (nonatomic, strong) UIImage *logoImage; // top logo image
@property (nonatomic, assign) CGSize logoSize; // top logo image size
@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, assign) NSInteger minimupPasswordLength; //default = 0;

/**
 *  
 */

- (void)shouldSubmitCredentials:(NSString*)login password:(NSString*)password;

- (void)resumeSession:(void(^)(BOOL success))completition;

@end