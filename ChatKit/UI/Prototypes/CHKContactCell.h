//
//  CHKContactCell.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/29/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCHK_ContactCellHeight 40

@import MagnetMax;

@interface CHKContactCell : UITableViewCell

@property (nonatomic, strong) MMUser *user;

@end
