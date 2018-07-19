//
//  UIImageView+URL.m
//  TDSwipeSheetDemo
//
//  Created by TopDevs on 6/13/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import "UIImageView+URL.h"
#import <Foundation/NSURLResponse.h>
#import <objc/runtime.h>

@implementation UIImageView (URL)

NSString const *imageURLKey           = @"imageURLKey";


- (NSURL *)imageURL {
    return objc_getAssociatedObject(self, &imageURLKey) ;
}

- (void)setImageURL:(NSURL *)imageURL {
    objc_setAssociatedObject(self, &imageURLKey, imageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSOperationQueue *queue = [NSOperationQueue new];

    NSInvocationOperation *operation = [[NSInvocationOperation alloc]
                                        initWithTarget:self
                                        selector:@selector(requestRemoteImage:)
                                        object:imageURL];
    [queue addOperation:operation];
}

- (void)loadImageFrom:(NSURL *)imageURL {
    if (![imageURL.absoluteString isEqualToString:self.imageURL.absoluteString]) {
        self.imageURL = imageURL;
    }
}

- (void)requestRemoteImage:(NSURL *)imageURL {
    __weak __typeof(self) weakSelf = self;
    
    [self downloadImageFromURL:imageURL completion:^(UIImage * _Nullable image) {
        [weakSelf performSelectorOnMainThread:@selector(placeImageInUI:) withObject:image waitUntilDone:YES];
    }];
}

- (void)placeImageInUI:(UIImage *)image {
    [self setImage:image];
}

- (void)getDataFromUrl:(NSURL *)url completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion {
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:completion] resume];
}

- (void)downloadImageFromURL:(NSURL *)imageURL completion:(void (^)(UIImage * _Nullable image))completion {
    [self getDataFromUrl:imageURL completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil && error == nil) {
            UIImage *image = [UIImage imageWithData:data];
            if (image != nil) {
                if(completion) {
                    completion(image);
                }
            }
        }
    }];
}

- (UIColor *)averageColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}


@end
