//
//  CHKUtils.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/18/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CHKUtils : NSObject

+ (NSBundle*)chk_bundle;

+ (UIImage*)chk_imageNamed:(NSString*)name;

+ (void)chk_loadImageByUrl:(NSURL*)url toImageView:(UIImageView*)imageView animateLoading:(BOOL)aniLoad;

+ (UIImage*)chk_bubbleImageColored:(UIColor*)color flipped:(BOOL)flipped; //NO = tail at right

@end
