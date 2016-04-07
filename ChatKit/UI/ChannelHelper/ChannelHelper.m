//
//  ChannelHelper.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 4/5/16.
//  Copyright © 2016 magnet. All rights reserved.
//

#import "ChannelHelper.h"

#define kExtraChannels @"mmx_channels"

#define kChannelId @"channelId"
#define kMessageDate @"messageDate"
#define kLastViewDate @"lastViewDate"

@implementation ChannelHelper

/**
 *  Update stored data. If none stored - create new.
 *
 */
+ (void)updateLastViewDateForChannelId:(NSString *_Nonnull)channelId complete:(void(^_Nullable)(BOOL success))complete
{
    NSMutableArray *infos = [ChannelHelper loadChannelInfos].mutableCopy;
    BOOL exist = NO;

    for (NSDictionary *channel in infos.mutableCopy) {
        if ([channel[kChannelId] isEqualToString:channelId]) {

            NSMutableDictionary *info = channel.mutableCopy;
            [infos removeObject:channel];
            info[kLastViewDate] = [[ChannelHelper dateFormatter] stringFromDate:[NSDate date]];
            [infos addObject:info];

            exist = YES;
            break;
        }
    }
    if (!exist) {
        NSMutableDictionary *info = @{}.mutableCopy;
        info[kChannelId] = channelId;
        info[kLastViewDate] = [[ChannelHelper dateFormatter] stringFromDate:[NSDate date]];
        info[kMessageDate] = [[ChannelHelper dateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]];
        [infos addObject:info];
    }

    [ChannelHelper saveChannelInfos:infos complete:^(BOOL success) {
        complete?complete(success):nil;
    }];
}

/**
 *  Find and update "channel" info @messageDate. If no "channel" info - create new with lastViewDate (1/1/70)
 *
 *  @param message MMXMessage object
 */
+ (void)updateDataForLastMessageIncome:(MMXMessage*_Nonnull)message complete:(void(^_Nullable)(BOOL success))complete
{
    NSMutableArray *infos = [ChannelHelper loadChannelInfos].mutableCopy;
    BOOL exist = NO;

    for (NSDictionary *channel in infos.mutableCopy) {
        if ([channel[kChannelId] isEqualToString:message.channel.channelID]) {

            NSMutableDictionary *info = channel.mutableCopy;
            [infos removeObject:channel];
            info[kMessageDate] = [[ChannelHelper dateFormatter] stringFromDate:(message.timestamp?:[NSDate date])];
            [infos addObject:info];

            exist = YES;
            break;
        }
    }
    if (!exist) {
        NSMutableDictionary *info = @{}.mutableCopy;
        info[kChannelId] = message.channel.channelID;
        if (message) {
            info[kLastViewDate] = [[ChannelHelper dateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]];
            info[kMessageDate] = [[ChannelHelper dateFormatter] stringFromDate:(message.timestamp?:[NSDate date])];
        }
        [infos addObject:info];
    }

    [ChannelHelper saveChannelInfos:infos complete:^(BOOL success) {
        complete?complete(success):nil;
    }];
}


/**
 *  Doing iteration through all stored "channel" infos and return yes if in any of info @messageDate greater then @lastViewDate
 */
+ (BOOL)haveUnreadMessagesForAllChannels
{
    BOOL haveUnread = NO;

    NSMutableArray *infos = [ChannelHelper loadChannelInfos].mutableCopy;

    for (NSMutableDictionary *channel in infos) {

            NSDate *lastViewDate = [[ChannelHelper dateFormatter] dateFromString:channel[kLastViewDate]];
            NSDate *messageDate = [[ChannelHelper dateFormatter] dateFromString:channel[kMessageDate]];

            if (messageDate.timeIntervalSince1970 > lastViewDate.timeIntervalSince1970) {
                haveUnread = YES;
                break;
            }
    }

    return haveUnread;
}

/**
 *  Return YES - if @messageDate greater then @lastViewDate or "channel" info not exist - hehe
 */
+ (BOOL)haveUnreadMessagesForChannelId:(NSString*_Nonnull)channelId
{
    BOOL haveUnread = YES;

    NSMutableArray *infos = [ChannelHelper loadChannelInfos].mutableCopy;

    for (NSDictionary *channel in infos) {
        if ([channel[kChannelId] isEqualToString:channelId]) {
            NSDate *lastViewDate = [[ChannelHelper dateFormatter] dateFromString:channel[kLastViewDate]];
            NSDate *messageDate = [[ChannelHelper dateFormatter] dateFromString:channel[kMessageDate]];

            if (lastViewDate && messageDate) {
                if (messageDate.timeIntervalSince1970 < lastViewDate.timeIntervalSince1970) {
                    haveUnread = NO;
                }
                break;
            } else {
                haveUnread = NO;

            }
        }
    }

    return haveUnread;
}

+ (void)removeRecordForChannelId:(NSString *)channelId
{
    NSMutableArray *infos = [ChannelHelper loadChannelInfos].mutableCopy;

    NSArray *iterator = [NSArray arrayWithArray:infos];
    
    for (NSMutableDictionary *channel in iterator) {
        if ([channel[kChannelId] isEqualToString:channelId]) {
            [infos removeObject:channel];
            break;
        }
    }

    [ChannelHelper saveChannelInfos:infos complete:nil];
}


#pragma mark - Private Helpers


+ (void)saveChannelInfos:(NSArray*)channelInfos complete:(void(^)(BOOL success))complete
{
    if (channelInfos) {
        NSError *error = nil;
        NSData *infosData = [NSJSONSerialization dataWithJSONObject:channelInfos options:0 error:&error];

        if (!error) {
            NSString *infosStr = [[NSString alloc] initWithData:infosData encoding:NSUTF8StringEncoding];


            NSMutableDictionary *updExtras = [MMUser currentUser].extras.mutableCopy;
            updExtras[kExtraChannels] = infosStr;

            MMUpdateProfileRequest *req = [[MMUpdateProfileRequest alloc]initWithUser:[MMUser currentUser]];
            req.extras = updExtras;

            [MMUser updateProfile:req success:^(MMUser * _Nonnull user) {
                NSLog(@"channel infos updated");
                complete?complete(YES):nil;
            } failure:^(NSError * _Nonnull error) {
                NSLog(@"fail to update infos");
                complete?complete(NO):nil;
            }];
        } else {
            complete?complete(NO):nil;
            NSLog(@"error serializing infoData");
        }
    } else {
        complete?complete(NO):nil;
    }
}

+ (NSArray*)loadChannelInfos
{
    NSMutableArray *infos = @[].mutableCopy;
    if ([MMUser currentUser].extras[kExtraChannels].length) {
        NSString *infosStr = [MMUser currentUser].extras[kExtraChannels];
        NSData *infosData = [infosStr dataUsingEncoding:NSUTF8StringEncoding];

        NSError *error = nil;
        NSArray *channels = [NSJSONSerialization JSONObjectWithData:infosData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            infos = channels.mutableCopy;
        } else {
            NSLog(@"error parsing stored infosData");
        }
    }
    return infos;
}

+ (NSDateFormatter*)dateFormatter
{
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return df;
}

@end
