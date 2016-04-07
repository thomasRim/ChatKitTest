//
//  ChannelHelper.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 4/5/16.
//  Copyright © 2016 magnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MagnetMax;

/**
 *  Channel id and last view date and last viewed message id stores in MMUser extras.
 store format is a JSON like:
    "channels":
        [
            {
            "channelId" : @"channel_id_value",
            "lastViewDate" : lastViewDate,
            "messageDate" : messageDate,
            }, ...
        ]
 
 On channel view - do update ()
 */

@interface ChannelHelper : NSObject

/**
 *  Update stored data. If none stored - create new.
 *
 */
+ (void)updateLastViewDateForChannelId:(NSString *_Nonnull)channelId complete:(void(^_Nullable)(BOOL success))complete;

/**
 *  Find and update "channel" info @messageDate. If no "channel" info - create new with lastViewDate (1/1/70)
 *
 *  @param message MMXMessage object
 */
+ (void)updateDataForLastMessageIncome:(MMXMessage*_Nonnull)message complete:(void(^_Nullable)(BOOL success))complete;

/**
 *  Doing iteration through all stored "channel" infos and return yes if in any of info @messageDate greater then @lastViewDate
 */
+ (BOOL)haveUnreadMessagesForAllChannels;

/**
 *  Return YES - if @messageDate greater then @lastViewDate
 */
+ (BOOL)haveUnreadMessagesForChannelId:(NSString*_Nonnull)channelId;

/**
 *  Remove "channel" info from extras. Should be called on leaving or deleting of channel on MMX server.
 *
 */
+ (void)removeRecordForChannelId:(NSString*_Nonnull)channelId;

@end
