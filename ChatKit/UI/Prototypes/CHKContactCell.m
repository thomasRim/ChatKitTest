//
//  CHKContactCell.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/29/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKContactCell.h"
#import "CHKConstants.h"
#import "CHKAvatarView.h"

#define kAvaShiftY 2
#define kShiftX 8

@interface CHKContactCell ()

@property (nonatomic, strong) CHKAvatarView *avaBase;
@property (nonatomic, strong) UILabel *usernameL;

@end

@implementation CHKContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _normalUsernameColor = [UIColor blackColor];
        _selectedUsernameColor = [UIColor blackColor];
        _selectedBackgroundColor = RGB_HEX(0xcbcbcb);

        _avaBase = [[CHKAvatarView alloc] initWithFrame:CGRectMake(kShiftX, kAvaShiftY, kCHK_ContactCellHeight-2*kAvaShiftY, kCHK_ContactCellHeight-kShiftX)];

        [self.contentView addSubview:_avaBase];
        _usernameL = [[UILabel alloc] initWithFrame:CGRectMake(_avaBase.frame.origin.x + _avaBase.frame.size.width + 2*kShiftX,
                                                               0,
                                                               [UIScreen mainScreen].bounds.size.width - _avaBase.frame.origin.x + kShiftX*2,
                                                               kCHK_ContactCellHeight)];
        _usernameL.font = [UIFont systemFontOfSize:kCHK_ContactCellHeight*2/5];
        _usernameL.textColor = self.normalUsernameColor;
        [self.contentView addSubview:_usernameL];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    return self;
}

- (void)setUser:(MMUser *)user
{
    _user = user;

    _avaBase.user = _user;
    if (_user.firstName || _user.lastName) {
        _usernameL.text = [NSString stringWithFormat:@"%@%@%@",
                           _user.firstName.length?_user.firstName:@"",
                           _user.lastName.length?@" ":@"",
                           _user.lastName.length?_user.lastName:@""];
    } else if (_user.userName.length){
        _usernameL.text = _user.userName;
    }
}

- (void)setNormalUsernameColor:(UIColor *)normalUsernameColor
{
    _normalUsernameColor = normalUsernameColor;
    [self updateUI];
}

- (void)setSelectedUsernameColor:(UIColor *)selectedUsernameColor
{
    _selectedUsernameColor = selectedUsernameColor;
    [self updateUI];
}

- (void)updateUI
{
    if (self.selected) {
        _usernameL.textColor = _selectedUsernameColor;
    } else {
        _usernameL.textColor = _normalUsernameColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        _usernameL.textColor = _selectedUsernameColor;
        self.contentView.backgroundColor = _selectedBackgroundColor;
    } else {
        _usernameL.textColor = _normalUsernameColor;
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    // Configure the view for the selected state
}

@end
