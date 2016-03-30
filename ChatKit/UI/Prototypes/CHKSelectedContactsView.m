//
//  CHKSelectedContactsView.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/30/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKSelectedContactsView.h"
#import "CHKConstants.h"
#import "CHKAvatarView.h"

#define kCHKAvatarHeight 35
#define kCHKAvatarSideShift 8

@interface CHKSelectedContactsView () <CHKAvatarViewDelegate>

@property (nonatomic, strong) UIScrollView *avatarsScrollPlace;
@property (nonatomic, strong) UILabel *selectedContactsL;

@property (nonatomic, strong) NSMutableArray * avatarViews;


@end

@implementation CHKSelectedContactsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _selectedContactsL = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 100, frame.size.height)];
        _selectedContactsL.text = @"0 selected";
        [self addSubview:_selectedContactsL];

        CGFloat sX = _selectedContactsL.frame.origin.x + _selectedContactsL.frame.size.width + 16;
        _avatarsScrollPlace = [[UIScrollView alloc] initWithFrame:
                               CGRectMake(sX,
                                          (frame.size.height - kCHKAvatarHeight)/2,
                                          [UIScreen mainScreen].bounds.size.width - sX - 8,
                                          kCHKAvatarHeight)];
        [self addSubview:_avatarsScrollPlace];
        _avatarViews = @[].mutableCopy;
        self.backgroundColor = RGB_HEX(0xf8f8f8);
    }
    return self;
}

- (void)addContact:(MMUser *)contact
{
    BOOL exist = NO;

    for (CHKAvatarView *av in _avatarViews) {
        if ([av.user.userID isEqualToString:contact.userID]) {
            exist = YES;
            break;
        }
    }

    if (!exist) {
        CHKAvatarView *av = [[CHKAvatarView alloc] initWithFrame:CGRectMake(0, 0, kCHKAvatarHeight, kCHKAvatarHeight)];
        av.user = contact;
        av.delegate = self;
        [_avatarViews addObject:av];
        [self reloadScrollSubviews];
    }
}

- (void)removeContact:(MMUser *)contact
{
    NSMutableArray *iterator = _avatarViews.mutableCopy;
    for (CHKAvatarView *av in iterator) {
        if ([av.user.userID isEqualToString:contact.userID]) {
            [_avatarViews removeObject:av];
            break;
        }
    }
    [self reloadScrollSubviews];
}

- (NSArray *)selectedContacts
{
    NSMutableArray *cntcts = @[].mutableCopy;
    for (CHKAvatarView *av in _avatarViews) {
        [cntcts addObject:av.user];
    }
    return cntcts;
}

- (void)reloadScrollSubviews
{
    _selectedContactsL.text = [NSString stringWithFormat:@"%@ selected",@(_avatarViews.count)];

    [_avatarsScrollPlace.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    _avatarsScrollPlace.contentSize = CGSizeMake( (kCHKAvatarHeight + kCHKAvatarSideShift)*_avatarViews.count, kCHKAvatarHeight);
    CGFloat x = 2;
    for (CHKAvatarView *av in _avatarViews) {
        av.frame = CGRectMake(x, 0, av.frame.size.width, av.frame.size.height);
        [_avatarsScrollPlace addSubview:av];
        x += av.frame.size.width + kCHKAvatarSideShift;
    }
}

#pragma mark - CHKAvatarViewDelegate

- (void)didTapOnView:(CHKAvatarView *)avatarView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(removedContactByTap:)]) {
        [self.delegate removedContactByTap:avatarView.user];
    }
    [self removeContact:avatarView.user];

}

@end
