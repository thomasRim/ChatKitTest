//
//  CHKSelectedContactsView.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/30/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MagnetMax;

@protocol CHKSelectedContactsViewDelegate <NSObject>

- (void)removedContactByTap:(MMUser*)contact;

@end

@interface CHKSelectedContactsView : UIView

@property (nonatomic, weak) id<CHKSelectedContactsViewDelegate> delegate; // for interaction on tapToRemove action

- (void)addContact:(MMUser*)contact;
- (void)removeContact:(MMUser*)contact;

- (NSArray*)selectedContacts;

@end
