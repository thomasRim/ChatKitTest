//
//  CHKConstants.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/30/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#ifndef CHKConstants_h
#define CHKConstants_h

#define RGB_HEX(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0] //hex color is like 0xffffff

#define RGB(r,g,b) [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:1.]

#endif /* CHKConstants_h */
