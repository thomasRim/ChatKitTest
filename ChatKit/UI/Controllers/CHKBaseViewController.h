//
//  CHKBaseViewController.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/15/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CHKMessageType.h"

@import MagnetMax;

@interface CHKBaseViewController : UIViewController

//non-overrides, just use
- (void)startAnimateWait;
- (void)stopAnimateWait;


// base overriden methods
- (void)setupUI;

@property (nonatomic, strong) id<MMEnumAttributeContainer> messageTypeContainer; //CHKMessageType by default

@property (nonatomic, strong) UIColor *backgroundColor;


@end
