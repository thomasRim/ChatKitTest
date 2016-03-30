//
//  CHKMessageType.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/28/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKMessageType.h"

@implementation CHKMessageTypeContainer

+ (NSDictionary *)mappings {
    return @{
             @"text" : @(CHKMessageType_Text),
             @"location" : @(CHKMessageType_Location),
             @"photo" : @(CHKMessageType_Photo),
             @"video" : @(CHKMessageType_Video),
             @"audio" : @(CHKMessageType_Audio),
             @"url" : @(CHKMessageType_Link),
             @"web_template" : @(CHKMessageType_WebTemplate),
             @"system" :@(CHKMessageType_SystemMessage)
             };
}

@end
