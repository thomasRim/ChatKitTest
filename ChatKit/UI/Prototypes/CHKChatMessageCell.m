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

}

- (void)setMessage:(MMXMessage *)message
{
    // setups around-bubble info
    
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
