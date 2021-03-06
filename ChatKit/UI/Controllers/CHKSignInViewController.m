//
//  SignInViewController.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/15/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKSignInViewController.h"

#import "CHKUtils.h"
#import "CHKChannelsViewController.h"

@interface CHKSignInViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoIV;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundIV;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoToTopLC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthLC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightLC;

@property (weak, nonatomic) IBOutlet UITextField *loginTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UIView *rememberCheckboxContent;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxIV;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation CHKSignInViewController

+ (UINib*)nib {
    return [UINib nibWithNibName:NSStringFromClass([CHKSignInViewController class])
                          bundle:[NSBundle bundleForClass:[CHKSignInViewController class]]];
}

- (void)setupUI
{
    self.loginPlaceholder = @"login/email";
    self.passwordPlaceholder = @"password";
    self.logoIV.image = [CHKUtils chk_imageNamed:@"logo_magnet"];
    self.rememberMe = YES;
    self.navigationController.navigationBarHidden = YES;


    if ([MMUser currentUser]) {
        [self previousSavedSession:CHKSessionStatus_LoggedIn];
    } else if ([MMUser savedUser]) {
        [self previousSavedSession:CHKSessionStatus_CanResume];
    } else {
        [self previousSavedSession:CHKSessionStatus_NotLogged];
    }
}

#pragma mark - Customosation

- (void)setLoginPlaceholder:(NSString *)loginPlaceholder
{
    _loginPlaceholder = loginPlaceholder;
    _loginTF.placeholder = _loginPlaceholder;
}


- (void)setPasswordPlaceholder:(NSString *)passwordPlaceholder
{
    _passwordPlaceholder = passwordPlaceholder;
    _passwordTF.placeholder = _passwordPlaceholder;
}

- (void)setHideRememberMeCheckbox:(BOOL)hideRememberMeCheckbox
{
    _hideRememberMeCheckbox = hideRememberMeCheckbox;
    _rememberCheckboxContent.hidden = _hideRememberMeCheckbox;
}

- (void)setLogoImage:(UIImage *)logoImage
{
    _logoImage = logoImage;
    _logoIV.image = _logoImage;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    _backgroundIV.image = _backgroundImage;
}

- (void)previousSavedSession:(CHKSessionStatus)savedSessionExist
{
}


- (void)resumeSession:(void (^)(BOOL))completition
{
    [_spinner startAnimating];

    [MMUser resumeSession:^{
        [_spinner stopAnimating];
        if (completition) {
            completition?completition(YES):nil;
        } else {
            [self presentDefaultChats];
        }
    } failure:^(NSError * _Nonnull error) {
        [_spinner stopAnimating];
        [MMUser logout];
        NSLog(@"resume error %@",error);
        completition?completition(NO):nil;
    }];
}

- (void)shouldSubmitCredentials:(NSString *)login password:(NSString *)password
{
    NSLog(@"did tap shouldSubmit. You may override this method for your own catch");


    NSURLCredential *creds = [NSURLCredential credentialWithUser:login password:password persistence:NSURLCredentialPersistenceNone];
    [_spinner startAnimating];

    [MMUser login:creds rememberMe:_rememberMe success:^{
        [_spinner stopAnimating];
        [self presentDefaultChats];
    } failure:^(NSError * _Nonnull error) {
        [_spinner stopAnimating];
        NSLog(@"login error %@",error);
    }];
}

- (void)presentDefaultChats
{
    CHKChannelsViewController *chnls = [CHKChannelsViewController new];
    if (self.navigationController) {
        [self.navigationController pushViewController:chnls animated:YES];
    } else {
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:chnls];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

#pragma mark - Data operation

- (void)setRememberMe:(BOOL)rememberMe
{
    _rememberMe = rememberMe;
    
    if (_rememberMe) {
        _checkboxIV.image = [CHKUtils chk_imageNamed:@"chb_select"];
    } else {
        _checkboxIV.image = [CHKUtils chk_imageNamed:@"chb_deselect"];
    }
}

#pragma mark - Actions

- (IBAction)submit:(UIButton*)sender
{
    [self shouldSubmitCredentials:self.loginTF.text password:self.passwordTF.text];
}

- (IBAction)checkboxTap:(UIButton*)sender
{
    self.rememberMe = !_rememberMe;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_loginTF]) {
        if (_loginTF.text.length == 0) {
            return NO;
        } else {
            [_passwordTF becomeFirstResponder];
        }
    } else if ([textField isEqual:_passwordTF]){
        if (_passwordTF.text.length < _minimupPasswordLength) {
            return NO;
        } else {
            [textField resignFirstResponder];
        }
    }
    return YES;
}

@end