//
//  ChannelCell.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKChannelCell.h"

#import "CHKAvatarView.h"

#import "CHKUtils.h"
#import "CHKConstants.h"
#import "CHKMessageType.h"

@interface CHKChannelCell ()

@property (nonatomic, strong) UIView *haveNewMessagesIndicatorIV;
@property (nonatomic, strong) CHKAvatarView *channelTypeV;
@property (nonatomic, strong) UILabel *channelSummaryL;
@property (nonatomic, strong) UILabel *lastMesageL;
@property (nonatomic, strong) UILabel *lastMessageTimeL;
@property (nonatomic, strong) UIImageView *sideArrowIV;

@end

@implementation CHKChannelCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);

        _haveNewMessagesIndicatorIV = [[UIView alloc] initWithFrame:CGRectMake(5, 8, 5, 5)];
        _haveNewMessagesIndicatorIV.backgroundColor = RGB_HEX(0x0079fe);
        _haveNewMessagesIndicatorIV.layer.cornerRadius = 2.5;
        _haveNewMessagesIndicatorIV.layer.masksToBounds = YES;
        _haveNewMessagesIndicatorIV.hidden = YES;
        [self.contentView addSubview:_haveNewMessagesIndicatorIV];

        _channelTypeV = [[CHKAvatarView alloc] initWithFrame:CGRectMake(8, 4, 30, 40)];
        _channelTypeV.defaultBackgroundImage = [CHKUtils chk_imageNamed:@"user_group"];
        [self.contentView addSubview:_channelTypeV];

        _sideArrowIV = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-14, 4, 6, 12)];
        _sideArrowIV.image = [CHKUtils chk_imageNamed:@"arrow_right"];
        [self.contentView addSubview:_sideArrowIV];

        CGFloat timeoutWidth = 50;
        _lastMessageTimeL = [[UILabel alloc] initWithFrame:CGRectMake(_sideArrowIV.frame.origin.x-(timeoutWidth+4), 4, timeoutWidth, _sideArrowIV.frame.size.height)];
        _lastMessageTimeL.font = [UIFont systemFontOfSize:_lastMessageTimeL.frame.size.height-2];
        _lastMessageTimeL.textColor = [UIColor lightGrayColor];
        _lastMessageTimeL.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_lastMessageTimeL];

        CGFloat textsX = _channelTypeV.frame.origin.x + _channelTypeV.frame.size.width + 10;

        _channelSummaryL = [[UILabel alloc] initWithFrame:CGRectMake(textsX, 4, _lastMessageTimeL.frame.origin.x - textsX, 15)];
        [self.contentView addSubview:_channelSummaryL];

        CGFloat lastMessY = _channelSummaryL.frame.origin.y +_channelSummaryL.frame.size.height;

        _lastMesageL = [[UILabel alloc] initWithFrame:CGRectMake(textsX, lastMessY, [UIScreen mainScreen].bounds.size.width - textsX - 8, kCHKChannelCellHeight - lastMessY - 8)];
        _lastMesageL.numberOfLines = 2;
        _lastMesageL.textColor = [UIColor lightGrayColor];
        _lastMesageL.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_lastMesageL];

    }
    return self;
}

- (void)setChannel:(MMXChannel *)channel
{
    _channel = channel;
    
    _channelTypeV.defaultBackgroundImage = [CHKUtils chk_imageNamed:@"user_default"];
    
    if (_channel.subscribers) {
            NSMutableArray *usernames = @[].mutableCopy;
        
            if (_channel.subscribers.count > 2) {
                _channelTypeV.defaultBackgroundImage = [CHKUtils chk_imageNamed:@"user_group"];
            } else {
                _channelTypeV.defaultBackgroundImage = [CHKUtils chk_imageNamed:@"user_default"];
            }
            
            for (MMUser* user in _channel.subscribers) {
                [usernames addObject:[NSString stringWithFormat:@"%@%@%@",
                                      user.firstName.length?user.firstName:@"",
                                      user.lastName.length?@" ":@"",
                                      user.lastName.length?user.lastName:@""]];
            }
            _channelSummaryL.text = [usernames componentsJoinedByString:@","];

    } else {
        _channelSummaryL.text = _channel.summary;
        [_channel subscribersWithLimit:100 offset:0 success:^(int totalCount, NSArray<MMUser *> * _Nonnull subscribers) {
        if (subscribers.count) {
            _channelTypeV.defaultBackgroundImage = [CHKUtils chk_imageNamed:@"user_group"];
        } else {
            _channelTypeV.defaultBackgroundImage = [CHKUtils chk_imageNamed:@"user_default"];
        }
        } failure:^(NSError * _Nonnull error) {
        
        }];
    }
}

- (void)setChannelDetail:(MMXChannelDetailResponse *)channelDetail
{
    _channelDetail = channelDetail;
    if (channelDetail) {
        if (_channelDetail.subscriberCount > 2) {

            NSMutableArray *names = @[].mutableCopy;
            for (MMUserProfile *prof in _channelDetail.subscribers) {
                [names addObject:prof.displayName];
            }
            _channelSummaryL.text = [names componentsJoinedByString:@", "];

        } else if (_channelDetail.subscriberCount == 2){


            for (MMUserProfile *profile in _channelDetail.subscribers) {
                if (![profile.userId isEqualToString:[MMUser currentUser].userID]) {

                    [MMUser usersWithUserIDs:@[profile.userId] success:^(NSArray<MMUser *> * _Nonnull users) {
                        _channelTypeV.user = users.firstObject;
                    } failure:^(NSError * _Nonnull error) {

                    }];

                    _channelSummaryL.text = profile.displayName;
                    break;
                }
            }


        } else {

            MMUserProfile *profile = _channelDetail.subscribers.firstObject;
            [MMUser usersWithUserIDs:@[profile.userId] success:^(NSArray<MMUser *> * _Nonnull users) {
                _channelTypeV.user = users.firstObject;
            } failure:^(NSError * _Nonnull error) {

            }];

            _channelSummaryL.text = profile.displayName;
        }

        MMXMessage *lastMsg = _channelDetail.messages.lastObject;

        _lastMessageTimeL.text = [self lastMessageDate:_channelDetail.lastPublishedTime];

        CHKMessageType type = [self messageTypeForMessage:lastMsg];

        switch (type) {
            case CHKMessageType_Text: {
                _lastMesageL.text = lastMsg.messageContent[@"message"];
                break;
            }
            case CHKMessageType_Photo:
            case CHKMessageType_Video:
            case CHKMessageType_Audio:
            case CHKMessageType_Link:
            case CHKMessageType_WebTemplate: {
                _lastMesageL.text = @"Attachment data";
                break;
                break;
            }
            default: {

            }
        }
    }
}

- (CHKMessageType)messageTypeForMessage:(MMXMessage*)message
{
    CHKMessageType type = CHKMessageType_Text;

    NSDictionary *content = message.messageContent;
    NSDictionary *typesMapp = [[CHKMessageTypeContainer class] mappings];

    type = [typesMapp[content[@"type"]] integerValue];

    return type;
}

- (NSString*)lastMessageDate:(NSString*)publishDate
{
    NSString *str = @"";
    if (publishDate.length) {
        NSDate *lastDate = nil;

        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        lastDate = [df dateFromString:publishDate];

        if (lastDate) {
            df = [NSDateFormatter new];
            df.dateFormat = @"hh':'mm' 'a";
            str = [df stringFromDate:lastDate].uppercaseString;
        }
    }
    return str;
}

@end
