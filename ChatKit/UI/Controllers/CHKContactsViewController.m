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
#import "CHKConstants.h"
#import "CHKContactCell.h"
#import "CHKSelectedContactsView.h"

#define kCHKSelectedHeight 50

@interface ContactsGroup : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *contacts;
@end

@implementation ContactsGroup
- (instancetype)init{
    if (self = [super init]) {
        self.name = @"";
        self.contacts = @[].mutableCopy;
    } return self;
}

@end

@interface CHKContactsViewController ()<UISearchBarDelegate, CHKSelectedContactsViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBBI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createBBI;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) CHKSelectedContactsView *selectedCV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLC;

@property (nonatomic, strong) NSMutableArray *plainListContacts;
@property (nonatomic, strong) NSMutableArray *grouppedContacts;

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
    _contactsPerPage = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (_contacts) {
        _plainListContacts = _contacts.mutableCopy;
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
    if (_enableGroupping) {
        ContactsGroup *group = _grouppedContacts[section];
        return group.contacts.count;
    } else {
        return _plainListContacts.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_enableGroupping) {
        return _grouppedContacts.count;
    } else {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_enableGroupping) {
        return nil;
    } else {
        ContactsGroup *group = _grouppedContacts[section];

        UIView *base = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        base.backgroundColor = RGB_HEX(0xacb5c0);
        UILabel *groupLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, base.bounds.size.width, base.bounds.size.height)];
        groupLbl.textColor = [UIColor whiteColor];
        groupLbl.text = group.name.capitalizedString;
        [base addSubview:groupLbl];
        return base;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!_enableGroupping) {
        return 0;
    } else {
        return 20;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([CHKContactCell class]);

    CHKContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CHKContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectedBackgroundColor = RGB_HEX(0xc9e0e5);
        cell.normalUsernameColor = [UIColor lightGrayColor];
    }

    MMUser *user = nil;
    if (_enableGroupping) {
        ContactsGroup *group = _grouppedContacts[indexPath.section];
        user = group.contacts[indexPath.row];
    } else {
        user = _plainListContacts[indexPath.row];
    };
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
            MMUser *contact = nil;

            if (!_enableGroupping) {
                contact = _plainListContacts[indexPath.row];
            } else {
                ContactsGroup *group = _grouppedContacts[indexPath.section];
                contact = group.contacts[indexPath.row];
            }
            contact?[_selectedCV removeContact:contact]:nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;

    if (_createBBI) {
        MMUser *contact = nil;

        if (!_enableGroupping) {
            contact = _plainListContacts[indexPath.row];
        } else {
            ContactsGroup *group = _grouppedContacts[indexPath.section];
            contact = group.contacts[indexPath.row];
        }

        if (_topLC.constant > 0) {
            contact?[_selectedCV addContact:contact]:nil;
        } else {
            _selectedCV = [[CHKSelectedContactsView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, kCHKSelectedHeight)];
            _selectedCV.delegate = self;
            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
                _topLC.constant = kCHKSelectedHeight;
            } completion:^(BOOL finished) {
                [self.view addSubview:_selectedCV];
                contact?[_selectedCV addContact:contact]:nil;
            }];
        }

        _createBBI.enabled = YES;
    }
}

#pragma mark - CHKSelectedContactsViewDelegate

- (void)removedContactByTap:(MMUser *)contact
{
    if (!_enableGroupping) {
        for (MMUser *user in _plainListContacts) {
            if ([user.userID isEqualToString:contact.userID]) {
                NSInteger index = [_plainListContacts indexOfObject:user];
                [_contactsTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];
                [self tableView:_contactsTable didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                break;
            }
        }
    } else {
        for (ContactsGroup *group in _grouppedContacts) {
            for (MMUser *user in group.contacts) {
                if ([user.userID isEqualToString:contact.userID]) {
                    NSInteger section = [_grouppedContacts indexOfObject:group];
                    NSInteger row = [group.contacts indexOfObject:user];

                    [_contactsTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:YES];
                    [self tableView:_contactsTable didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    break;
                }
            }
        }
    }

    
}

- (void)checkSelectedContacts
{
    NSArray *selectedContacts = _selectedCV.selectedContacts;

    if (!_enableGroupping) {
        for (MMUser *userPresent in _plainListContacts) {
            for (MMUser *userSelect in selectedContacts) {
                if ([userSelect.userID isEqualToString:userPresent.userID]) {
                    NSInteger indexPresent = [_plainListContacts indexOfObject:userPresent];
                    [_contactsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPresent inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
    } else {
        for (ContactsGroup *group in _grouppedContacts) {
            for (MMUser *user in group.contacts) {
                for (MMUser *userSelected in selectedContacts) {
                    if ([user.userID isEqualToString:userSelected.userID]) {
                        NSInteger section = [_grouppedContacts indexOfObject:group];
                        NSInteger row = [group.contacts indexOfObject:user];
                        [_contactsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }

    }
}

#pragma mark Actions

- (IBAction)rightBtnPress:(UIBarButtonItem*)sender
{
    NSArray *indexPaths = [_contactsTable indexPathsForSelectedRows];
    
    NSMutableArray *selectedUsers = @[].mutableCopy;

    if (!_enableGroupping) {
        for (NSIndexPath *path in indexPaths) {
            [selectedUsers addObject:_plainListContacts[path.row]];
        }
    } else {
        for (NSIndexPath *path in indexPaths) {
            ContactsGroup *group = _grouppedContacts[path.section];
            [selectedUsers addObject:group.contacts[path.row]];
        }
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

#pragma mark - Search and Filter

- (void)searchUsers:(NSString*)searchString
{
    [self startAnimateWait];

    NSString *searchPredStr = searchString;
    if (!searchString.length || [searchString isEqualToString:@""] || !searchString) {
        searchPredStr = @"firstName:*";
    } else {
        searchPredStr = [NSString stringWithFormat:@"userName:*%@* OR firstName:*%@* OR lastName:*%@",searchString,searchString,searchString];
    }

    [MMUser searchUsers:searchPredStr limit:1000 offset:0 sort:@"lastName:asc" success:^(NSArray<MMUser *> * _Nonnull users) {
        [self stopAnimateWait];
        _contacts = users;
        NSLog(@"contacts %@",@(users.count));

        _plainListContacts = _contacts.mutableCopy;

        if (!_enableGroupping) {
            [_contactsTable reloadData];
        } else {
            [self groupAndPresentContacts];
        }

        [self checkSelectedContacts];

    } failure:^(NSError * _Nonnull error) {
        [self stopAnimateWait];
        NSLog(@"search users err %@",error);
    }];
}

- (void)groupAndPresentContacts
{
    _grouppedContacts = @[].mutableCopy;
    //sort by lastName
    NSArray *sortedUsers = [_plainListContacts sortedArrayUsingComparator:^NSComparisonResult(MMUser *user1,MMUser *user2) {
        NSString *fullName1 = [NSString stringWithFormat:@"%@%@%@",
                              user1.firstName.length?user1.firstName:@"",
                              user1.lastName.length?@" ":@"",
                              user1.lastName.length?user1.lastName:@""];
        NSString *fullName2 = [NSString stringWithFormat:@"%@%@%@",
                               user2.firstName.length?user2.firstName:@"",
                               user2.lastName.length?@" ":@"",
                               user2.lastName.length?user2.lastName:@""];
        return [fullName1.lowercaseString compare:fullName2.lowercaseString options:NSNumericSearch|NSForcedOrderingSearch];
    }];

    //precreae groups if users with appropriate tags exist
    if (_tagGroups.count) {
        for (NSString *tagName in _tagGroups) {
            ContactsGroup *group = [ContactsGroup new];
            group.name = tagName.lowercaseString;
            [_grouppedContacts addObject:group];
        }
    }

    // fill
    for (MMUser *user in sortedUsers) {
        if ([user.userID isEqualToString:[MMUser currentUser].userID]) { //exclude self
            continue;
        }

        if (user.tags.count) { // send user to any tag groups due to contact's tags
            BOOL userTagsUsable = NO;

            for (ContactsGroup *tagedGroup in _grouppedContacts) {
                for (NSString *tag in user.tags) {
                    if ([tag.lowercaseString isEqualToString:tagedGroup.name.lowercaseString]) {
                        userTagsUsable = YES;
                        [tagedGroup.contacts addObject:user];
                    }
                }
            }
            if (!userTagsUsable) {
                [self addUserToRegularGroup:user];
            }
        } else { // other non-tagged users
            [self addUserToRegularGroup:user];
        }
    }

    NSArray *testGroups = [NSArray arrayWithArray:_grouppedContacts];
    for (ContactsGroup *group in testGroups) {
        if (group.contacts.count == 0) {
            [_grouppedContacts removeObject:group];
        }
    }

    [_contactsTable reloadData];
}

- (void)addUserToRegularGroup:(MMUser*)user
{
    NSString *groupChar = @" ";
    if (user.lastName.length) {
        groupChar = [user.lastName substringWithRange:NSMakeRange(0, 1)].lowercaseString;
    }

    BOOL groupForCharExist = NO;
    ContactsGroup *groupToAssignTo = nil;

    for (ContactsGroup *group in _grouppedContacts) {
        if ([group.name.lowercaseString isEqualToString:groupChar.lowercaseString]) {
            groupForCharExist = YES;
            groupToAssignTo = group;
            break;
        }
    }
    if (groupForCharExist) {
        [groupToAssignTo.contacts addObject:user];
    } else {
        groupToAssignTo = [ContactsGroup new];
        groupToAssignTo.name = groupChar.lowercaseString;
        [groupToAssignTo.contacts addObject:user];
        [_grouppedContacts addObject:groupToAssignTo];
    }
}

@end
