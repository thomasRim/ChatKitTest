//
//  CHKAvatarView.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/29/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MagnetMax;

@class CHKAvatarView;
@protocol CHKAvatarViewDelegate <NSObject>

- (void)didTapOnView:(CHKAvatarView*)avatarView;

@end

@interface CHKAvatarView : UIView
@property (nonatomic, weak) id<CHKAvatarViewDelegate> delegate;
@property (nonatomic, strong) MMUser *user;

@end
