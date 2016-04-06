//
//  CHKChatMessageCell.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/21/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MagnetMax;

@class CHKChatMessageCell;

@protocol CHKChatMessageDelegate <NSObject>

- (void)chatMessageCell:(CHKChatMessageCell*)cell updatedHeight:(CGFloat)height;

@end

@interface CHKChatMessageCell : UITableViewCell

@property (nonatomic, assign) id<CHKChatMessageDelegate> delegate;

// Content and cell size
@property (nonatomic, strong) MMXMessage *message;
@property (nonatomic, strong) UIView *bubbleContentView; // nil - default

@property (nonatomic, assign) BOOL showSenderName; // NO - default
@property (nonatomic, assign) BOOL showSenderAvatar; // NO - default
@property (nonatomic, assign) BOOL showMessageDate; // NO- default
@property (nonatomic, copy) NSString *messageDateFormat; // EEEE,MM-dd-yyy, hh:mm a - default

@property (nonatomic, assign) CGFloat avatarDimencionsSize; // 30(x30) by default

- (CGFloat)bubbleContentWidthMaxForTableWidth:(CGFloat)tableWidth;

- (CGFloat)cellHeight;
// UI customization

@property (nonatomic, strong) UIColor *avatarBackground;
@property (nonatomic, strong) UIColor *selfBubbleColor;
@property (nonatomic, strong) UIColor *otherBubbleColor;


@end
