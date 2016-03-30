//
//  CHKUtils.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/18/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKUtils.h"

@implementation CHKUtils


+ (NSBundle *)chk_bundle
{
    return [NSBundle bundleForClass:[CHKUtils class]];

}

+ (id)chk_imageNamed:(NSString *)name
{
    NSString *bundleResourcePath = [CHKUtils chk_bundle].resourcePath;
    NSString *assetPath = [bundleResourcePath stringByAppendingPathComponent:@"CHKAssets.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:assetPath];
    NSString *path = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

+ (void)chk_loadImageByUrl:(NSURL *)url toImageView:(UIImageView *)imageView animateLoading:(BOOL)aniLoad
{

    NSString *imageName = url.lastPathComponent;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [paths[0] stringByAppendingPathComponent:imageName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]
        && ([NSData dataWithContentsOfFile:filePath].length > 0)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = [UIImage imageWithContentsOfFile:filePath];
        });
    } else {
        UIActivityIndicatorView __block *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        if (aniLoad) {
            spinner.hidesWhenStopped = YES;
            spinner.color = [UIColor lightGrayColor];
            [imageView addSubview:spinner];
            spinner.center = CGPointMake(imageView.bounds.size.width/2,
                                         imageView.bounds.size.height/2);
            [spinner startAnimating];
        }

        // load URL request

        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            [spinner removeFromSuperview];
            
            // apply received data
            if (!error && ((NSHTTPURLResponse*)response).statusCode == 200) {
                [data writeToFile:filePath atomically:YES];
                dispatch_async(dispatch_get_main_queue(), ^{

//                    imageView.image = [UIImage imageWithData:data];
//                    [imageView.superview reloadInputViews];

                    imageView.image = [UIImage imageWithContentsOfFile:filePath];
                });
            }

        }] resume];
    }

}

@end
