//
//  TDSwipeSheetViewController+Theme.h
//  TDSwipeSheet
//
//  Created by TopDevs on 6/13/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import "TDSwipeSheetViewController.h"

/**
 Сategory on a TDSwipeSheetViewController class that allows you to customize, change the appearance and change the appearance of the TDSwipeSheet in every possible way.
 */
@interface TDSwipeSheetViewController (Theme)

/// The standard light theme.
- (void)setUpLightTheme;

/// The standard dark theme.
- (void)setUpDarkTheme;

- (void)themeRefresh;

/// The image displayed in the handle button. This property contains the main image displayed by the handle button.
@property (nonatomic, strong) UIImage *handleButtonIcon;

/// Readonly propety for default button element
@property (nonatomic, strong, readonly) UIButton *handleButton;

/// The color of displayed image in the handle button.
@property (nonatomic, strong, readwrite) UIColor *handleButtonColor;

/// The view’s background color. Changes to this property can be animated. The default value is nil, which results in a transparent background color.
@property (nonatomic, strong) UIColor *backgroundColor;

/// Сhanges the direction of movement of the TDSwipeSheet object.
@property (nonatomic, assign, getter=isFromBottom) BOOL fromBottom;

/// The radius to use when drawing rounded corners for the layer’s background. Animatable.
@property (nonatomic, assign) CGFloat cornerRadius;

/// Color for dimming view
@property (nonatomic, strong) UIColor *dimmingViewColor;

/// The UIVisualEffect you provide for the view. This can be a UIBlurEffect or a UIVibrancyEffect.
@property (nonatomic, strong) UIVisualEffect *visualEffect;

@end
