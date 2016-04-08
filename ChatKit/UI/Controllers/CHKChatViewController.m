//
//  CHKChatViewController.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/7/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKChatViewController.h"

#import "CHKChatMessageCell.h"

@interface CHKChatViewController ()<UIWebViewDelegate, CHKChatMessageDelegate>

@property (weak, nonatomic) IBOutlet UITableView *chatTable;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBBI;

@property (nonatomic, strong) NSMutableArray *presentingMessages;

//send bar items
@property (weak, nonatomic) IBOutlet UIBarButtonItem *attachBBI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBBI;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btmLC;

@property (nonatomic, strong) MMAttachment *outMessageAttachment;
@property (nonatomic, assign) CHKMessageType outMessageType;

@property (nonatomic, strong) NSMutableArray *chatCells;

@end

@implementation CHKChatViewController


+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([CHKChatViewController class])
                          bundle:[NSBundle bundleForClass:[CHKChatViewController class]]];
}

#pragma mark - Interface Methods


- (void)setupUI
{
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItems = [self leftBarButtonItems];
        
        self.titleString = _chatChannel.summary;
    }

    
    _sendBtn.enabled = NO;
    self.showAttachIcon = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:MMXDidReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:([NSDate date].timeIntervalSince1970 - 7*24*60*60)];
    
    [_chatChannel messagesBetweenStartDate:endDate endDate:[NSDate date] limit:1000 offset:0 ascending:YES success:^(int totalCount, NSArray<MMXMessage *> * _Nonnull messages) {

        _presentingMessages = messages.mutableCopy;

        [self filterPresentingMessages];

        [_chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_presentingMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)filterPresentingMessages
{
    NSMutableArray *iterator = _presentingMessages.mutableCopy;

    for (MMXMessage *msg in iterator) {
        if (CHKMessageType_SystemMessage == [self messageTypeForMessage:msg]){
            [_presentingMessages removeObject:msg];
        }
    }
    [self generateCells];
}

- (void)generateCells
{
    _chatCells = @[].mutableCopy;

    for (MMXMessage *msg in _presentingMessages) {

        CHKChatMessageCell *cell = [self cellForMessage:msg];
        NSInteger index = [_presentingMessages indexOfObject:msg];

        if (index == 0) {
            cell.showSenderName = YES;
            cell.showMessageDate = YES;
        } else  if (_presentingMessages.count > 1){

            MMXMessage *prevMessage = _presentingMessages[index-1];
            if (![msg.sender.userID isEqualToString:prevMessage.sender.userID]) {
                cell.showSenderName = YES;
            }

            NSTimeInterval interval = msg.timestamp.timeIntervalSince1970-prevMessage.timestamp.timeIntervalSince1970;
            if (interval > 60*60) {
                cell.showMessageDate = YES;
            } else if (interval > 5*60) {
                cell.showMessageDate = YES;
                cell.messageDateFormat = @"hh:mm a";
            }
        }

        cell.showSenderAvatar = YES;
        cell.delegate = self;

        cell.bubbleContentView = [self contentCellViewForMessage:msg forCell:cell];

        [_chatCells addObject:cell];

    }
    [_chatTable reloadData];
}

- (NSArray *)leftBarButtonItems
{
    return _cancelBBI?@[_cancelBBI]:@[];
}

- (void)setTitleString:(NSString *)titleString
{
    _titleString = titleString;
    self.navigationItem.title = _titleString;
}

- (void)setShowAttachIcon:(BOOL)showAttachIcon
{
    _showAttachIcon = showAttachIcon;
    if (_showAttachIcon) {
        _attachBBI.width = _inputTF.frame.size.height;
    } else {
        _attachBBI.width = 0.2;
    }
    _inputTF.frame = CGRectMake(0,
                                0,
                                [UIScreen mainScreen].bounds.size.width - _attachBBI.width - _sendBBI.width - (2*16+2*8),
                                _inputTF.frame.size.height);
}

#pragma mark - Actions

- (IBAction)leftBtnPress:(UIBarButtonItem*)sender
{
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

- (IBAction)sendMessage:(UIButton*)sender
{

    MMXMessage *message = [self preparedMessageToSend];

    if (!message) {
        [self messageFailedTotSend:[NSError errorWithDomain:@"in-app" code:300 userInfo:@{@"error":@"no message of MMXMessage type to send. Check -preparedMessageToSend method return an object."}]];
        return;
    }

    [self messageWillBeSend:message];

    [message sendWithSuccess:^(NSSet<NSString *> * _Nonnull invalidUsers) {
        _inputTF.text = nil;
        [_inputTF resignFirstResponder];
        [self messageDidSent:message];
    } failure:^(NSError * _Nonnull error) {
        [self messageFailedTotSend:error];
    }];
}

- (IBAction)attachData:(UIButton*)sender
{
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange
{
    if (_inputTF.text.length) {
        _sendBtn.enabled = YES;
    } else {
        _sendBtn.enabled = NO;
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _chatCells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 60;

    CHKChatMessageCell *cell = _chatCells[indexPath.row];

    height = [cell cellHeight];

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHKChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CHKChatMessageCell class])];
    cell = _chatCells[indexPath.row];
    return cell;
}

#pragma mark - MMX

- (void)receivedMessage:(NSNotification*)notification
{
    if (notification.userInfo) {
        NSDictionary *info = notification.userInfo;
        if (info[MMXMessageKey]) {
            MMXMessage *message = info[MMXMessageKey];
            if ([message.channel.name.lowercaseString isEqualToString:_chatChannel.name.lowercaseString]) {
                if (!_presentingMessages.count) {
                    _presentingMessages = @[].mutableCopy;
                }

                if (CHKMessageType_SystemMessage != [self messageTypeForMessage:message]) {
                    [_chatTable beginUpdates];

                    [_presentingMessages addObject:message];
                    [self generateCells];

                    [_chatTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_chatCells.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [_chatTable endUpdates];

                    [_chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatCells.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                }

            }
        }
    }
    MMXMessage *msg = notification.userInfo[MMXMessageKey];

    NSLog(@"chat %@ \ngot message %@\nfrom %@ %@",msg.channel.name,msg.messageContent,msg.sender.firstName,msg.sender.lastName);
}

#pragma mark - Content processing

- (UIView*)messageBubbleContentViewForMessage:(MMXMessage*)message maxBubbleWidth:(CGFloat)bubbleWidth;
{
    UIView *resultView = nil;
    if (message) {

        CHKMessageType type = [self messageTypeForMessage:message];

        switch (type) {
            case CHKMessageType_Text: {
                resultView = [self textCellContentForMessage:message width:bubbleWidth];
                break;
            }
            case CHKMessageType_Photo: {
                resultView = [self imageCellContentForMessage:message width:bubbleWidth];
                break;
            }
            case CHKMessageType_WebTemplate: {
                resultView = [self webCellContentForMessage:message width:bubbleWidth];
                break;
            }
            default: {
                resultView = [self textCellContentForMessage:message width:bubbleWidth];
            }
        }
    }
    return resultView;
}

- (UIView*)contentCellViewForMessage:(MMXMessage*)message forCell:(CHKChatMessageCell*)cell
{
    UIView *bubbleContent = nil;

    if (message) {
        // bubble content
        bubbleContent = [self messageBubbleContentViewForMessage:message maxBubbleWidth:[cell bubbleContentWidthMaxForTableWidth:_chatTable.bounds.size.width]];
        }
    return bubbleContent;
}

- (UIView*)webCellContentForMessage:(MMXMessage*)message width:(CGFloat)width
{

    NSDictionary *content = message.messageContent;

    //webView
    NSString *urlStr = content[@"message"];
    UIWebView *webV = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  width,
                                                                  190)];
    webV.scalesPageToFit = YES;
    webV.scrollView.scrollEnabled = NO;
    webV.delegate = self;

    webV.scrollView.maximumZoomScale = 1;
    webV.scrollView.minimumZoomScale = 0.1;

    webV.layer.cornerRadius = 10;
    webV.layer.masksToBounds = YES;
    
    [webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    
    return webV;
}

- (UIView*)textCellContentForMessage:(MMXMessage*)message width:(CGFloat)width
{
    NSDictionary *content = message.messageContent;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             width,
                                                             0)];
    lbl.text = [content[@"message"] length]?content[@"message"]:@" ";
    lbl.numberOfLines = 0;
    lbl.textColor = [UIColor whiteColor];
    lbl.lineBreakMode = NSLineBreakByWordWrapping;
    [lbl sizeToFit];
    
    return lbl;
}

- (UIView*)imageCellContentForMessage:(MMXMessage*)message width:(CGFloat)width
{
    UIImageView *iv = [[UIImageView alloc]  initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     width,
                                                                     100)];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    if (message.attachments.count) {
        MMAttachment *attach = message.attachments.firstObject;
        if (attach.data) {
            iv.image = [UIImage imageWithData:attach.data];
        } else if (attach.downloadURL) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:attach.downloadURL];
                if (data.length) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        iv.image = [UIImage imageWithData:data];
                    });
                }
            });
        }
    }
    return iv;
}

#pragma mark - ChatViewControllerDelegate

- (MMXMessage *)preparedMessageToSend
{
    NSString *messageTypeKey = @"";
    _outMessageType = CHKMessageType_Text;

    NSDictionary *typesMapp = [[self.messageTypeContainer class] mappings];

    for (NSString *key in typesMapp.allKeys) {
        CHKMessageType type = [typesMapp[key] integerValue];
        if (type == _outMessageType) {
            messageTypeKey = key;
            break;
        }
    }

    MMXMessage *message = [MMXMessage messageToChannel:_chatChannel
                                    messageContent:@{@"type" : messageTypeKey,
                                                     @"message" : _inputTF.text}];
    return message;
}
- (void)messageWillBeSend:(MMXMessage *)message {}
- (void)messageDidSent:(MMXMessage *)message {}
- (void)messageFailedTotSend:(NSError *)error {}



#pragma mark - Helpers

- (CHKMessageType)messageTypeForMessage:(MMXMessage*)message
{
    CHKMessageType type = CHKMessageType_Text;

    NSDictionary *content = message.messageContent;
    NSDictionary *typesMapp = [[self.messageTypeContainer class] mappings];

    type = [typesMapp[content[@"type"]] integerValue];

    return type;
}

- (CHKChatMessageCell*)cellForMessage:(MMXMessage*)message
{
    CHKChatMessageCell *cell = [[CHKChatMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CHKChatMessageCell class])];

    cell.selfBubbleColor = _selfBubbleColor;
    cell.otherBubbleColor = _otherBubbleColor;
    cell.avatarBackground = _avatarBackgroundColor;
    cell.message = message;

    return cell;
}

#pragma mark - Keyboard

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        _btmLC.constant = kbSize.height;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2f animations:^{
        _btmLC.constant = 0;
    }];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView.scrollView setZoomScale:0.1];
    NSLog(@"did start load web");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"did fail to load web %@",error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"inapp"]) {
        NSString *message = @"n/a";
        if ([request.URL.host isEqualToString:@"nocancel"]) {
            message = @"No, cancel";
            // do capture action
        } else if ([request.URL.host isEqualToString:@"yesagree"]) {
            message = @"Yes, I agree";
        }
        MMXMessage *msg = [MMXMessage messageToChannel:_chatChannel messageContent:@{@"type" : @"text",
                                                                                     @"message" : message}];
                [msg sendWithSuccess:^(NSSet<NSString *> * _Nonnull invalidUsers) {
        } failure:^(NSError * _Nonnull error) {
        }];

        return NO;
    }
    return YES;
}

#pragma mark - CHKChatMessageDelegate

- (void)chatMessageCell:(CHKChatMessageCell *)cell updatedHeight:(CGFloat)height
{
//    NSLog(@"cell %@, height %@",cell,@(height));
//    [_chatTable beginUpdates];
//    [_chatTable endUpdates];
}




@end
