//
//  CHKAvatarView.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/29/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKAvatarView.h"
#import "CHKConstants.h"
#import "CHKUtils.h"

@interface CHKAvatarView ()

@property (nonatomic, strong) UIView *backgroundV;
@property (nonatomic, strong) UIImageView *avatarIV;
@property (nonatomic, strong) UILabel *userAcrL;

@end

@implementation CHKAvatarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CGFloat minLength = MIN(frame.size.width, frame.size.height);
        _backgroundV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, minLength, minLength)];
        _backgroundV.backgroundColor = RGB_HEX(0x12aafa);
        _backgroundV.layer.cornerRadius = minLength/2;
        _backgroundV.layer.masksToBounds = YES;
        [self addSubview:_backgroundV];
        _backgroundV.center = self.center;

        _userAcrL = [[UILabel alloc] initWithFrame:_backgroundV.bounds];
        _userAcrL.font = [UIFont systemFontOfSize:minLength/2];
        _userAcrL.textAlignment = NSTextAlignmentCenter;
        _userAcrL.textColor = [UIColor whiteColor];
        [_backgroundV addSubview:_userAcrL];

        _avatarIV = [[UIImageView alloc] initWithFrame:_backgroundV.bounds];
        _avatarIV.contentMode = UIViewContentModeScaleAspectFill;
        [_backgroundV addSubview:_avatarIV];
        
    }
    return self;
}

- (void)setDelegate:(id<CHKAvatarViewDelegate>)delegate
{
    _delegate = delegate;
    if (_delegate) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
        [self addGestureRecognizer:tap];
    }
}

- (void)setUser:(MMUser *)user
{
    _user = user;
    if (_user) {
        NSString *fNl = @"";
        if (_user.firstName.length) {
            fNl = [_user.firstName substringWithRange:NSMakeRange(0, 1)].uppercaseString;
        }
        NSString *lNl = @"";
        if (_user.lastName.length) {
            lNl = [_user.lastName substringWithRange:NSMakeRange(0, 1)].uppercaseString;
        }
        _userAcrL.text = [NSString stringWithFormat:@"%@%@",fNl,lNl];

        [CHKUtils chk_loadImageByUrl:_user.avatarURL toImageView:_avatarIV animateLoading:NO];
    }
}

- (void)setDefaultBackgroundColor:(UIColor *)defaultBackgroundColor
{
    if (defaultBackgroundColor) {
        _backgroundV.backgroundColor = defaultBackgroundColor;
    }
}

- (void)setDefaultBackgroundImage:(UIImage *)defaultBackgroundImage
{
    if (defaultBackgroundImage) {
        _avatarIV.image = defaultBackgroundImage;
    }
}

- (void)tapGesture
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapOnView:)]) {
        [self.delegate didTapOnView:self];
    }
}

@end
