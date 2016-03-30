//
//  CHKMessageType.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/28/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MagnetMax;

typedef NS_ENUM(NSUInteger, CHKMessageType){
    CHKMessageType_Text = 0,
    CHKMessageType_Location,
    CHKMessageType_Photo,
    CHKMessageType_Video,
    CHKMessageType_Audio,
    CHKMessageType_Link,
    CHKMessageType_WebTemplate,
    CHKMessageType_SystemMessage
};

@interface CHKMessageTypeContainer : NSObject<MMEnumAttributeContainer>

@end
