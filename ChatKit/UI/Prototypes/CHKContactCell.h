//
//  CHKContactCell.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/29/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCHK_ContactCellHeight 45

@import MagnetMax;

@interface CHKContactCell : UITableViewCell

@property (nonatomic, strong) MMUser *user;

//custom
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) UIColor *selectedUsernameColor;
@property (nonatomic, strong) UIColor *normalUsernameColor;
@end
