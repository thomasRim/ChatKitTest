//
//  ChatViewController.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKBaseViewController.h"

@protocol CHKChatViewControllerDelegate <NSObject>

@optional
- (void)messageWillBeSend:(MMXMessage*)message;
- (void)messageDidSent:(MMXMessage*)message;
- (void)messageFailedTotSend:(NSError*)error;

- (UIView*)messageBubbleContentViewForMessage:(MMXMessage*)message maxBubbleWidth:(CGFloat)bubbleWidth;
- (CGFloat)messageBubbleContentHeightForMessage:(MMXMessage*)message;
- (MMXMessage*)preparedMessageToSend;

@end

@interface CHKChatViewController : CHKBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,CHKChatViewControllerDelegate>

@property (nonatomic, strong) MMXChannel *chatChannel;

@property (nonatomic, copy) NSString *titleString; // default - description of channel

@property (nonatomic, assign) BOOL showAttachIcon; // NO - default

@property (nonatomic, strong) UIColor *avatarBackgroundColor;
@property (nonatomic, strong) UIColor *selfBubbleColor;
@property (nonatomic, strong) UIColor *otherBubbleColor;

@end
