//
//  UIImageView+URL.h
//  TDSwipeSheetDemo
//
//  Created by TopDevs on 6/13/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (URL)

@property (nonatomic, strong) NSURL *imageURL;

- (void)loadImageFrom:(NSURL *)imageURL;

- (UIColor *)averageColor;

@end
