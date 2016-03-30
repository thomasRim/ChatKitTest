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
        _avaBase = [[CHKAvatarView alloc] initWithFrame:CGRectMake(kShiftX, kAvaShiftY, kCHK_ContactCellHeight-2*kAvaShiftY, kCHK_ContactCellHeight-2*kAvaShiftY)];
        [self.contentView addSubview:_avaBase];
        _usernameL = [[UILabel alloc] initWithFrame:CGRectMake(_avaBase.frame.origin.x + _avaBase.frame.size.width + 2*kShiftX,
                                                               0,
                                                               [UIScreen mainScreen].bounds.size.width - _avaBase.frame.origin.x + kShiftX*2,
                                                               kCHK_ContactCellHeight)];
        _usernameL.font = [UIFont systemFontOfSize:kCHK_ContactCellHeight/2];
        [self.contentView addSubview:_usernameL];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.contentView.backgroundColor = RGB_HEX(0xcbcbcb);
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    // Configure the view for the selected state
}

@end
