//
//  ChatsList.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/2/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKChannelsViewController.h"

#import "CHKContactsViewController.h"
#import "CHKChatViewController.h"

#import "CHKChannelCell.h"

@interface CHKChannelsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBBI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createBBI;

@property (weak, nonatomic) IBOutlet UITableView *channelsTable;

@property (nonatomic, strong) NSMutableArray *channelDetails;

@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;


@end

@implementation CHKChannelsViewController

+ (UINib*)nib {
    return [UINib nibWithNibName:NSStringFromClass([CHKChannelsViewController class])
                          bundle:[NSBundle bundleForClass:[CHKChannelsViewController class]]];
}

#pragma mark - UI and Loading

- (void)viewDidLoad
{
    [super viewDidLoad];

    _channelDetails = @[].mutableCopy;

}

- (void)setupUI
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableDataUI) name:MMXDidReceiveChannelInviteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageIncome:) name:MMXDidReceiveMessageNotification object:nil];
    
    _tableRefreshControl = [UIRefreshControl new];
    [_channelsTable addSubview:_tableRefreshControl];
    [_tableRefreshControl addTarget:self action:@selector(loadChannels) forControlEvents:UIControlEventValueChanged];

    self.titleString = @"Chats List";
    self.leftBarButtonItems = @[_cancelBBI];

    if (self.navigationController) {
        self.navigationItem.leftBarButtonItems = [self leftBarButtonItems];
        self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];
        
        self.navigationItem.title = [self titleString];
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_channelDetails.count) {
        [_channelsTable reloadData];
    } else {
        //loading default subscribed channels
        [self loadChannels];
    }
}

- (void)updateTableDataUI
{
    [_channelsTable reloadData];
}

- (void)messageIncome:(NSNotification*)notification
{
    [self loadChannels];
    NSLog(@"Got message income notification\n %@",notification.name);

    MMXMessage *msg = notification.userInfo[MMXMessageKey];
    NSLog(@"channel %@ \n message %@\nfrom %@ %@",msg.channel.name,msg.messageContent,msg.sender.firstName,msg.sender.lastName);
}

#pragma mark - Interface Methods

- (NSArray *)rightBarButtonItems
{
    return _createBBI?@[_createBBI]:@[];
}

- (void)didPressChatCreate
{
    NSLog(@"Activated didPressChatCreate. You should override this method to catch this interaction.");
    
    CHKContactsViewController *vc = [CHKContactsViewController new];
    
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)didPressCancel
{
    NSLog(@"Activated didPressCancel. You should override this method to catch this interaction.");

    if (self.navigationController) {
        if (self.navigationController.presentingViewController) {
            if (self.navigationController.viewControllers.count == 1) {
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UITableViewRowAction *)swipeLeftActionForChatCellAtIndex:(NSIndexPath *)indexPath
{
    UITableViewRowAction *defaultActionButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Leave" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        if (_channelDetails.count > 0 && indexPath.row < _channelDetails.count) {
                                            MMXChannelDetailResponse *channelToRemove = _channelDetails[indexPath.row];
                                            [channelToRemove.channel unSubscribeWithSuccess:^{
                                                NSLog(@"channel unsubscribed");
                                            } failure:^(NSError * _Nonnull error) {
                                                NSLog(@"channel unsubscribe error %@",error);
                                            }];
                                            [self.channelDetails removeObjectAtIndex:indexPath.row];
                                            [_channelsTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                        }
                                    }];
    defaultActionButton.backgroundColor = [UIColor redColor];
    return defaultActionButton;
}


- (void)shouldOpenChatChannel:(MMXChannel*)channel;
{
    if (channel) {
        if (self.navigationController) {
            CHKChatViewController *vc = [CHKChatViewController new];
            vc.chatChannel = channel;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            CHKChatViewController *vc = [CHKChatViewController new];
            vc.chatChannel = channel;
            [self.presentingViewController presentViewController:vc animated:YES completion:nil];
        }
    }
    
    NSLog(@"Activated shouldOpenChatForCellAtIndex. You should override this method to catch this interaction.");
}

#pragma mark - Life Cycle

- (void)loadChannels
{
    if (_channels.count) {
        [self loadChannelDetails];
    } else {
        [MMXChannel subscribedChannelsWithSuccess:^(NSArray<MMXChannel *> * _Nonnull channels) {
            _channels = channels;

            if (_channels.count) {
                [self loadChannelDetails];
            } else {
                [_tableRefreshControl endRefreshing];
                [_channelsTable reloadData];
            }
        } failure:^(NSError * _Nonnull error) {
            [_tableRefreshControl endRefreshing];
            NSLog(@"some error due loading default channels \n%@",error);
        }];
    }
}

- (void)loadChannelDetails
{
    [MMXChannel channelDetails:_channels numberOfMessages:1 numberOfSubcribers:1000 success:^(NSArray<MMXChannelDetailResponse *> * _Nonnull detailsForChannels) {

        if (detailsForChannels) {
            _channelDetails = [detailsForChannels sortedArrayUsingComparator:^NSComparisonResult(MMXChannelDetailResponse  *obj1, MMXChannelDetailResponse  *obj2) {
                NSString *date1 = obj1.lastPublishedTime;
                NSString *date2 = obj2.lastPublishedTime;
                return [date2 compare:date1 options:NSNumericSearch];
            }].mutableCopy;
        }

        [_tableRefreshControl endRefreshing];
        [_channelsTable reloadData];
    } failure:^(NSError * _Nonnull error) {
        [_tableRefreshControl endRefreshing];
        NSLog(@"some error due loading channels details \n%@",error);
    }];
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCHKChannelCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([CHKChannelCell class]);
    CHKChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CHKChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.channelDetail = _channelDetails[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _channelDetails.count;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[[self swipeLeftActionForChatCellAtIndex:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_channelDetails.count) {
        MMXChannel *channel = [_channelDetails[indexPath.row] channel];
        [self shouldOpenChatChannel:channel];
    }
    
}

#pragma mark Actions

- (IBAction)rightBtnPress:(UIBarButtonItem*)sender
{
    [self didPressChatCreate];
}

- (IBAction)leftBtnPress:(UIBarButtonItem*)sender
{
    [self didPressCancel];
}

@end
