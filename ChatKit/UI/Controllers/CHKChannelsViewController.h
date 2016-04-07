//
//  ChatsList.h
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/2/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKBaseViewController.h"

@import MagnetMax;


@interface CHKChannelsViewController : CHKBaseViewController <UITableViewDelegate, UITableViewDataSource>

/**
 *  Defines if Search bar will be visible. and enabled for searching.
 */
@property (nonatomic, assign) BOOL enableSearch;

/**
 *  Numbers of channels presenting per page. Default = 0
 *  0 - all at once, no paging,
 *  n - paging with items == n or n -> # of visible items
 */
@property (nonatomic, assign) NSInteger channelsPerPage;

/**
 *  Custom channels for presentation.
 *  If value will be nil on -viewWillAppear: call - then -subscribedChannels: will be presented.
 */
@property (nonatomic, strong) NSArray <MMXChannel*> *channels;

/**
 *  NavBar title customization.
 *
 *  @return String value. Default value "Chats List". Nullable.
 */
@property (nonatomic, copy) NSString* titleString;

/**
 *  NavigationBar, on the left, button items.
 *
 *  @return Array of UIBarButtonItems that will be placed on the left side of NavigationBar;
 */
@property (nonatomic, strong) NSArray *leftBarButtonItems;

/**
 *  NavBar default right bar button item onPress interaction hook.
 */
- (void)didPressChatCreate;

/**
 *  NavBar default left bar button item onPress interaction hook.
 */
- (void)didPressCancel;

/**
 *  Chat channel interaction on select. Have default opening of selected channel.
 */
- (void)shouldOpenChatChannel:(MMXChannel*)channel;

/**
 *  Action customization for cell at @indexPath. Oprional. 
 *  Default action removes channel from presentation list and unsubscribe user fron channel for cell at @indexPath.
 *
 *  @return return custom (UITableViewRowAction) class object. Nullable.
 */
- (UITableViewRowAction*)swipeLeftActionForChatCellAtIndex:(NSIndexPath*)indexPath;

@end
