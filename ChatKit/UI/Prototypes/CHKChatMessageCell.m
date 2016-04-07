//
//  CHKChatMessageCell.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/21/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKChatMessageCell.h"

#import "CHKUtils.h"
#import "CHKAvatarView.h"

@interface CHKChatMessageCell ()

@property (weak, nonatomic) IBOutlet UILabel *messageDateL;
@property (weak, nonatomic) IBOutlet UILabel *usernameL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateHeightLC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameHeightLC;

@property (weak, nonatomic) IBOutlet UIView *leftAvatarBaseV;
@property (weak, nonatomic) IBOutlet UIView *rightAvatarBaseV;
@property (weak, nonatomic) IBOutlet UIView *bubbleV;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleIV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleIVLeftLC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleIVRightLC;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avaLW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avaLH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avaRW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avaRH;

@end

@implementation CHKChatMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        NSArray *nibs = [[CHKUtils chk_bundle]
                         loadNibNamed:NSStringFromClass([CHKChatMessageCell class])
                         owner:self
                         options:nil];
        self = [nibs objectAtIndex:0];

        _avatarDimencionsSize = 30;
        _showSenderName = NO;
        _showMessageDate = NO;
        _showSenderAvatar = NO;
        _messageDateFormat = @"EEEE,MM-dd-yyy, hh:mm a";
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self layoutIfNeeded];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGFloat)cellHeight
{
    CGFloat subsHeight = _dateHeightLC.constant + _usernameHeightLC.constant + _bubbleContentView.frame.size.height;
    CGFloat height = 15 + MAX(_rightAvatarBaseV.frame.size.height, subsHeight);

    return  height;
}

- (void)updateUI
{
    //
    BOOL selfMessage = [_message.sender.userID isEqualToString:[MMUser currentUser].userID];

    if (_message) {

        _dateHeightLC.constant = _showMessageDate?15:0;

        _usernameHeightLC.constant = _showSenderName?15:0;

        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                [self cellHeight]);
        
        //avatar
        if (_showSenderAvatar) {


            CHKAvatarView *avatarV = nil;

            if (selfMessage) {
                avatarV = [[CHKAvatarView alloc] initWithFrame:_rightAvatarBaseV.bounds];
                [_rightAvatarBaseV addSubview:avatarV];
                _leftAvatarBaseV.hidden = YES;
                _rightAvatarBaseV.hidden = NO;
            } else {
                avatarV = [[CHKAvatarView alloc] initWithFrame:_leftAvatarBaseV.bounds];
                [_leftAvatarBaseV addSubview:avatarV];
                _leftAvatarBaseV.hidden = NO;
                _rightAvatarBaseV.hidden = YES;
            }
            avatarV.defaultBackgroundColor = self.avatarBackground?:avatarV.defaultBackgroundColor;
            avatarV.user = _message.sender;
        }

        //date
        if (_showMessageDate) {

            NSDateFormatter *df = [NSDateFormatter new];
            df.dateFormat = _messageDateFormat;
            NSString *dateStr = [df stringFromDate:_message.timestamp];
            _messageDateL.text = dateStr;
        }
        //username
        if (_showSenderName) {
            _usernameL.text = [NSString stringWithFormat:@"%@ %@",_message.sender.firstName,_message.sender.lastName];
            if (selfMessage) {
                _usernameL.textAlignment = NSTextAlignmentRight;
            } else {
                _usernameL.textAlignment = NSTextAlignmentLeft;
            }
        }
        //bubble
        if (selfMessage) {
            _bubbleIV.image = [CHKUtils chk_bubbleImageColored:self.selfBubbleColor flipped:NO];
            _bubbleIVLeftLC.constant = 0;
            _bubbleIVRightLC.constant = -5;
//            _bubbleV.backgroundColor = self.selfBubbleColor?:[UIColor lightGrayColor];
        } else {
            _bubbleIV.image = [CHKUtils chk_bubbleImageColored:self.otherBubbleColor flipped:YES];
            _bubbleIVLeftLC.constant = -5;
            _bubbleIVRightLC.constant = 0;
//            _bubbleV.backgroundColor = self.otherBubbleColor?:[UIColor lightGrayColor];
        }
//
//        _bubbleV.layer.cornerRadius = 10;
//        _bubbleV.layer.masksToBounds = YES;


        _bubbleContentView.frame = CGRectMake(5, 5,
                                              _bubbleContentView.frame.size.width,
                                              _bubbleContentView.frame.size.height);

        [_bubbleV addSubview:_bubbleContentView];

    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(chatMessageCell:updatedHeight:)]) {
        [self.delegate chatMessageCell:self updatedHeight:self.frame.size.height];
    }
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
    _avaLW.constant = avatarDimencionsSize;
    _avaLH.constant = avatarDimencionsSize;
    _avaRW.constant = avatarDimencionsSize;
    _avaRH.constant = avatarDimencionsSize;
    [self updateUI];
}



- (CGFloat)bubbleContentWidthMaxForTableWidth:(CGFloat)tableWidth
{
    CGFloat width = tableWidth-2*(10);

    if (_showSenderAvatar) {
        width -= 2*(5 + _avatarDimencionsSize);
    }

    return width-10;
}


@end
