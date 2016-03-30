//
//  CHKContactsViewController.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/9/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKContactsViewController.h"

#import "CHKChatViewController.h"
#import "CHKUtils.h"
#import "CHKContactCell.h"
#import "CHKSelectedContactsView.h"

#define kCHKSelectedHeight 50

@interface CHKContactsViewController ()<UISearchBarDelegate, CHKSelectedContactsViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBBI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createBBI;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) CHKSelectedContactsView *selectedCV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLC;

@property (nonatomic, strong) NSMutableArray *presentingUsers;

@end

@implementation CHKContactsViewController
#pragma mark - Class Methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([CHKContactsViewController class])
                          bundle:[NSBundle bundleForClass:[CHKContactsViewController class]]];
}

- (void)setupUI
{
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItems = [self leftBarButtonItems];
        self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];
        self.navigationItem.title = [self titleString];
    }
    _enableSearch = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (_contacts) {
        _presentingUsers = _contacts.mutableCopy;
    } else {
        [self searchUsers:nil];

    }
}

#pragma mark - Interface Methods

- (NSArray *)leftBarButtonItems
{
    return _cancelBBI?@[_cancelBBI]:@[];
}

- (NSArray *)rightBarButtonItems
{
    if (_createBBI) {
        _createBBI.enabled = NO;
        return @[_createBBI];
    } else {
        return @[];
    }
}

- (NSString *)titleString
{
    return @"Contacts";
}

- (void)setEnableSearch:(BOOL)enableSearch
{
    _enableSearch = enableSearch;
    
    if (_enableSearch) {
        [_searchBar sizeToFit];
        _contactsTable.tableHeaderView = _searchBar;
    } else {
        _contactsTable.tableHeaderView = nil;
    }
    _searchBar.hidden = !_enableSearch;

    [_contactsTable beginUpdates];
    [_contactsTable endUpdates];
}

- (void)shouldCreateChatWithSelectedUsers:(NSArray <MMUser*> *)users;
{
    NSString *channelName = [NSString stringWithFormat:@"chat-%@",[NSUUID UUID].UUIDString];
    NSString *description = (users.count>1)?@"GroupChat":@"PersonalChat";
    
    [MMXChannel createWithName:channelName summary:description isPublic:(users.count>1)?YES:NO publishPermissions:MMXPublishPermissionsSubscribers subscribers:[NSSet setWithArray:users] success:^(MMXChannel * _Nonnull channel) {
        
        if (channel) {
            if (self.navigationController) {
                NSMutableArray *vcs = self.navigationController.viewControllers.mutableCopy;
                CHKChatViewController *vc = [CHKChatViewController new];
                vc.chatChannel = channel;
                
                NSInteger index = 0;
                NSArray *iterVcs = [NSArray arrayWithArray:vcs];
                for (UIViewController *vcc in iterVcs) {
                    if ([vcc isKindOfClass:self.class]) {
                        index = [iterVcs indexOfObject:vcc];
                    }
                }
                [vcs insertObject:vc atIndex:index];
                self.navigationController.viewControllers = vcs;
                [self leftBtnPress:nil];
                
            } else {
                [self dismissViewControllerAnimated:YES completion:^{
                    CHKChatViewController *vc = [CHKChatViewController new];
                    vc.chatChannel = channel;
                    [self.presentingViewController presentViewController:vc animated:YES completion:nil];
                }];
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"Chat create error %@",error);
    }];
    
    NSLog(@"Activated didPressRightBarButtonItem. You may override this method to catch this interaction.");
}

#pragma mark - Life Cycle

#pragma mark UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCHK_ContactCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _presentingUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([CHKContactCell class]);

    CHKContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CHKContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    MMUser *user = _presentingUsers[indexPath.row];
    cell.user = user;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;

    if (_createBBI) {

        if ([tableView indexPathsForSelectedRows].count == 0) {
            _createBBI.enabled = NO;
            [_selectedCV removeFromSuperview];
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
                _topLC.constant = 0;
            }];
        } else {
            [_selectedCV removeContact:_presentingUsers[indexPath.row]];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;

    if (_createBBI) {
        if (_topLC.constant > 0) {
            [_selectedCV addContact:_presentingUsers[indexPath.row]];
        } else {
            _selectedCV = [[CHKSelectedContactsView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, kCHKSelectedHeight)];
            _selectedCV.delegate = self;
            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
                _topLC.constant = kCHKSelectedHeight;
            } completion:^(BOOL finished) {
                [self.view addSubview:_selectedCV];
                [_selectedCV addContact:_presentingUsers[indexPath.row]];
            }];
        }

        _createBBI.enabled = YES;
    }
}

#pragma mark - CHKSelectedContactsViewDelegate

- (void)removedContactByTap:(MMUser *)contact
{
    for (MMUser *user in _presentingUsers) {
        if ([user.userID isEqualToString:contact.userID]) {
            NSInteger index = [_presentingUsers indexOfObject:user];
            [_contactsTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];
            [self tableView:_contactsTable didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            break;
        }
    }
    
}

- (void)checkSelectedContacts
{
    NSArray *selectedContacts = _selectedCV.selectedContacts;
    for (MMUser *userPresent in _presentingUsers) {
        for (MMUser *userSelect in selectedContacts) {
            if ([userSelect.userID isEqualToString:userPresent.userID]) {
                NSInteger indexPresent = [_presentingUsers indexOfObject:userPresent];
                [_contactsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPresent inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

#pragma mark Actions

- (IBAction)rightBtnPress:(UIBarButtonItem*)sender
{
    NSArray *indexPaths = [_contactsTable indexPathsForSelectedRows];
    
    NSMutableArray *selectedUsers = @[].mutableCopy;
    for (NSIndexPath *path in indexPaths) {
        [selectedUsers addObject:_presentingUsers[path.row]];
    }
    
    [self shouldCreateChatWithSelectedUsers:selectedUsers];
}

- (IBAction)leftBtnPress:(UIBarButtonItem*)sender
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (self.navigationController) {
        if (self.navigationController.presentingViewController) {
            if (self.navigationController.viewControllers.count == 1) {
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchUsers:(NSString*)searchString
{

    NSString *searchPredStr = searchString;
    if (!searchString.length || [searchString isEqualToString:@""] || !searchString) {
        searchPredStr = @"firstName:*";
    } else {
        searchPredStr = [NSString stringWithFormat:@"userName:*%@* OR firstName:*%@* OR lastName:*%@",searchString,searchString,searchString];
    }

    [MMUser searchUsers:searchPredStr limit:1000 offset:0 sort:@"firstName:asc" success:^(NSArray<MMUser *> * _Nonnull users) {
        _contacts = users;
        NSLog(@"contacts %@",@(users.count));
        _presentingUsers = _contacts.mutableCopy;
        [_contactsTable reloadData];

        [self checkSelectedContacts];

    } failure:^(NSError * _Nonnull error) {
        NSLog(@"search users err %@",error);
    }];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    [self searchUsers:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchUsers:searchBar.text];
}

@end
