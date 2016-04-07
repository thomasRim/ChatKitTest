//
//  CHKBaseViewController.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/15/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKBaseViewController.h"

@interface CHKBaseViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *chk_baseSpinner;

@end

@implementation CHKBaseViewController

#pragma mark - Class Methods

- (void)startAnimateWait
{
    if (!_chk_baseSpinner) {
        _chk_baseSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _chk_baseSpinner.color = [UIColor darkGrayColor];
        _chk_baseSpinner.hidesWhenStopped = YES;
        [self.view addSubview:_chk_baseSpinner];
        _chk_baseSpinner.center = self.view.center;
        [_chk_baseSpinner startAnimating];
    }
}

- (void)stopAnimateWait;
{
    if (_chk_baseSpinner) {
        [_chk_baseSpinner stopAnimating];
        [_chk_baseSpinner removeFromSuperview];
        _chk_baseSpinner = nil;
    }
}


//overrides
+ (UINib *)nib
{
    NSLog(@"You need to override this method!");
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)setupUI
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self class] nib] instantiateWithOwner:self options:nil];

    _messageTypeContainer = [[CHKMessageTypeContainer class] new];

    [self setupUI];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.view.backgroundColor = _backgroundColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
