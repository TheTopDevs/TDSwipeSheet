//
//  TDSwipeSheetViewController+Theme.m
//  TDSwipeSheet
//
//  Created by TopDevs on 6/13/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import "TDSwipeSheetViewController+Theme.h"
#import <objc/runtime.h>

@interface TDSwipeSheetViewController ()

+ (CGSize)screenSize;
- (void)setMaskTo:(UIView*)view byDirection:(BOOL)isFromBottom;

@property (nonatomic, strong) UIButton *handleButton;
@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, strong) NSLayoutConstraint *topOffsetConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomOffsetConstraint;

@property (nonatomic, strong) UIVisualEffectView *visualEffectView;

@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat verticalTopLimit;
@property (nonatomic, assign) CGFloat verticalBottomLimit;

@end

@implementation TDSwipeSheetViewController (Theme)

NSString const *fromBottomKey           = @"fromBottomKey";
NSString const *backgroundColorKey      = @"backgroundColorKey";
NSString const *cornerRadiusKey         = @"cornerRadiusKey";
NSString const *handleButtonIconKey     = @"handleButtonIconKey";
NSString const *handleButtonColorKey    = @"handleButtonColorKey";
NSString const *dimmingViewColorKey     = @"dimmingViewColorKey";
NSString const *visualEffectKey         = @"visualEffectKey";

- (void)setUpLightTheme {
    self.fromBottom = YES;
    self.cornerRadius = 10;
    self.visualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.backgroundColor = UIColor.clearColor;
    self.dimmingViewColor = [UIColor.whiteColor colorWithAlphaComponent:0.7];
    self.handleButtonColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    self.handleButtonIcon = [UIImage imageNamed:@"TDSwipeSheetHandleButtonIcon.png"];
}

- (void)setUpDarkTheme {
    self.fromBottom = YES;
    self.cornerRadius = 10;
    self.visualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.backgroundColor = UIColor.clearColor;
    self.dimmingViewColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    self.handleButtonColor = [UIColor.whiteColor colorWithAlphaComponent:0.7];
    self.handleButtonIcon = [UIImage imageNamed:@"TDSwipeSheetHandleButtonIcon.png"];
}

- (BOOL)isFromBottom {
    return [objc_getAssociatedObject(self, &fromBottomKey) boolValue];
}

- (BOOL)fromBottom {
    return [objc_getAssociatedObject(self, &fromBottomKey) boolValue];
}

- (void)setFromBottom:(BOOL)fromBottom {
    objc_setAssociatedObject(self, &fromBottomKey, @(fromBottom), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
        
        CGSize screenSize = [TDSwipeSheetViewController screenSize];
        if (self.isFromBottom) {
            [self.parentViewController.view addConstraint:self.topOffsetConstraint];
            [self.parentViewController.view removeConstraint:self.bottomOffsetConstraint];
        } else {
            [self.parentViewController.view addConstraint:self.bottomOffsetConstraint];
            [self.parentViewController.view removeConstraint:self.topOffsetConstraint];
        }
        if (fromBottom) {
            self.viewHeight = screenSize.height - self.verticalTopLimit;
        } else {
            self.viewHeight = self.verticalBottomLimit;
        }
        [self setMaskTo:self.visualEffectView byDirection:fromBottom];
        
}

- (UIVisualEffect *)visualEffect {
    return objc_getAssociatedObject(self, &visualEffectKey);
}

- (void)setVisualEffect:(UIVisualEffect *)visualEffect {
    objc_setAssociatedObject(self, &visualEffectKey, visualEffect, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.visualEffectView setEffect:visualEffect];
}

- (UIColor *)backgroundColor {
    return objc_getAssociatedObject(self, &backgroundColorKey);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    objc_setAssociatedObject(self, &backgroundColorKey, backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.visualEffectView.backgroundColor = backgroundColor;
}

- (CGFloat)cornerRadius {
    return [objc_getAssociatedObject(self, &cornerRadiusKey) floatValue];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    objc_setAssociatedObject(self, &cornerRadiusKey, @(cornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.visualEffectView.layer.cornerRadius = cornerRadius;
}

- (UIColor *)handleButtonColor {
    return objc_getAssociatedObject(self, &handleButtonColorKey);
}

- (void)setHandleButtonColor:(UIColor *)handleButtonColor {
    objc_setAssociatedObject(self, &handleButtonColorKey, handleButtonColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.handleButton setTintColor:handleButtonColor];
}

- (UIImage *)handleButtonIcon {
    return objc_getAssociatedObject(self, &handleButtonIconKey);
}

- (void)setHandleButtonIcon:(UIImage *)handleButtonIcon {
    objc_setAssociatedObject(self, &handleButtonIconKey, handleButtonIcon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UIImage *image = [handleButtonIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.handleButton setImage:image forState:UIControlStateNormal];
    [self.handleButton setTintColor:self.handleButtonColor];
}

- (void)setDimmingViewColor:(UIColor *)dimmingViewColor {
    objc_setAssociatedObject(self, &dimmingViewColorKey, dimmingViewColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.dimmingView setBackgroundColor:dimmingViewColor];
}

- (UIColor *)dimmingViewColor {
    return objc_getAssociatedObject(self, &dimmingViewColorKey);
}

- (void)themeRefresh {
    self.handleButtonIcon = self.handleButtonIcon;
    self.handleButtonColor = self.handleButtonColor;
    self.backgroundColor = self.backgroundColor;
    self.visualEffect = self.visualEffect;
    self.fromBottom = self.fromBottom;
    self.cornerRadius = self.cornerRadius ;
    self.dimmingViewColor = self.dimmingViewColor;
}

@end
