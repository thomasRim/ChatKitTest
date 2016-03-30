//
//  CHKChatMessageCell.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/21/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKChatMessageCell.h"

@interface CHKChatMessageCell ()

@property (nonatomic, strong) UILabel *messageDateL;
@property (nonatomic, strong) UILabel *usernameL;
@property (nonatomic, strong) UIImageView *avatarIV;
@property (nonatomic, strong) UIView *bubbleV;

@end

@implementation CHKChatMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _avatarDimencionsSize = 30;
        _showSenderName = NO;
        _showMessageDate = NO;
        _showSenderAvatar = NO;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUI
{
    //
    BOOL selfMessage = [_message.sender.userID isEqualToString:[MMUser currentUser].userID];

    UIView *bubbleContent = nil;
    UIView * contentV = nil;

    if (_message) {

        CGFloat dateHeigth = 0;
        CGFloat senderNameHeigth = 0;

        if (_showMessageDate) {
            dateHeigth = 15;
        }
        if (_showSenderName) {
            senderNameHeigth = 15;
        }


        contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,
                                                            _bubbleContentView.frame.size.height + 20 + dateHeigth + senderNameHeigth)];

        CGFloat avatarForShift = 10;
        
        //avatar
        if (_showSenderAvatar) {

            avatarForShift = 40;

            CGRect avatarRect = CGRectZero;
            if (selfMessage) {
                avatarRect = CGRectMake(contentV.frame.size.width-30-5, contentV.frame.size.height-5-30, 30, 30);
            } else {
                avatarRect = CGRectMake(5, contentV.frame.size.height-5-30, 30, 30);
            }

            UIView *avaV = [[UIView alloc] initWithFrame:avatarRect];

            if (selfMessage) {
                avaV.backgroundColor = [UIColor blueColor];
            } else {
                avaV.backgroundColor = [UIColor blueColor];
            }

            avaV.layer.cornerRadius = avaV.frame.size.width/2;
            avaV.layer.masksToBounds = YES;
            [contentV addSubview:avaV];
        }
        //date
        if (_showMessageDate) {
            UILabel *messageDate = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            self.frame.size.width,
                                                                            12)];
            messageDate.text = [NSString stringWithFormat:@"%@",_message.timestamp];
            messageDate.textAlignment = NSTextAlignmentCenter;
            [contentV addSubview:messageDate];

        }
        //username
        if (_showSenderName) {
            UILabel *senderName = [[UILabel alloc] initWithFrame:CGRectMake(8,
                                                                            dateHeigth,
                                                                            self.frame.size.width-16,
                                                                            12)];
            senderName.text = [NSString stringWithFormat:@"%@ %@",_message.sender.firstName,_message.sender.lastName];
            if (selfMessage) {
                senderName.textAlignment = NSTextAlignmentRight;
            } else {
                senderName.textAlignment = NSTextAlignmentLeft;
            }
            [contentV addSubview:senderName];
        }

        //bubble
        UIView *bubble = [[UIView alloc] initWithFrame:CGRectMake(avatarForShift,
                                                                 dateHeigth + senderNameHeigth + 5,
                                                                 self.frame.size.width-2*avatarForShift,
                                                                 _bubbleContentView.frame.size.height+10)];
        if (selfMessage) {
            bubble.backgroundColor = [UIColor lightGrayColor];
        } else {
            bubble.backgroundColor = [UIColor lightGrayColor];
        }

        bubble.layer.cornerRadius = 10;
        bubble.layer.masksToBounds = YES;
        [contentV addSubview:bubble];

        [bubble addSubview:_bubbleContentView];

        _bubbleContentView.frame = CGRectMake(5, 5, _bubbleContentView.frame.size.width, bubbleContent.frame.size.height);

    }
    [self.contentView addSubview:contentV];
}

- (void)setMessage:(MMXMessage *)message
{
    // setups around-bubble info
    _message = message;

}

- (void)setShowSenderAvatar:(BOOL)showSenderAvatar
{
    _showSenderAvatar = showSenderAvatar;
    [self updateUI];
}

- (void)setShowSenderName:(BOOL)showSenderName
{
    _showSenderName = showSenderName;
    [self updateUI];
}

- (void)setShowMessageDate:(BOOL)showMessageDate
{
    _showMessageDate = showMessageDate;
    [self updateUI];
}

- (void)setBubbleContentView:(UIView *)bubbleContentView
{
    _bubbleContentView = bubbleContentView;
    [self updateUI];
}

- (void)setAvatarDimencionsSize:(CGFloat)avatarDimencionsSize
{
    _avatarDimencionsSize = avatarDimencionsSize;
    [self updateUI];
}

- (CGFloat)bubbleContentWidthMax
{
    CGFloat width = self.contentView.frame.size.width;
    
    return width;
}

- (CGFloat)cellHeight
{
    CGFloat height = 0;
    
    return height;
}

@end
