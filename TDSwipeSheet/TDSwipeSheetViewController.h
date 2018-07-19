//
//  TDSwipeSheetViewController.h
//  TDSwipeSheet
//
//  Created by TopDevs on 5/8/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import <UIKit/UIKit.h>

/// TDSwipeSheetLimit is the limit that reached the TDSwipeSheetViewController.
typedef NS_ENUM(NSUInteger, TDSwipeSheetLimit) {
    TDSwipeSheetLimitTop,
    TDSwipeSheetLimitBottom
};

/// Orientation in which the view controller overturned. There are only portrait and landscape orientations.
typedef NS_ENUM(NSUInteger, TDSwipeSheetOrientation) {
    TDSwipeSheetOrientationLandscape,
    TDSwipeSheetOrientationPortrait
};

@class TDSwipeSheetViewController;

/**
 The delegate of a TDSwipeSheetViewController object must adopt the TDSwipeSheetViewControllerDelegate protocol. Optional methods of the protocol allow the delegate to manage gestures, animations, and events such as changing the orientation and reaching the limit.
 */
@protocol TDSwipeSheetViewControllerDelegate <NSObject>

@optional

/// Change top offset for view
- (CGFloat)needsVerticalTopLimitForSwipeSheetView:(TDSwipeSheetViewController *)swipeSheet;

/// Change bottom offset for view
- (CGFloat)needsVerticalBottomLimitForSwipeSheetView:(TDSwipeSheetViewController *)swipeSheet;


/**
 Tells the delegate when user drags the TDSwipeSheetViewController.
 The delegate typically implements this method to obtain the change in content offset from scrollView and draw the affected portion of the content view.
 @param swipeSheet The TDSwipeSheetViewController object.
 */
- (void)swipeSheetDragged:(TDSwipeSheetViewController *)swipeSheet;

/**
 Tells the delegate when the limits of the SwipeSheetViewController reached.
 
 @param swipeSheet The SwipeSheetViewController object.
 @param limit Parameter substantially object limit.
 */
- (void)swipeSheet:(TDSwipeSheetViewController *)swipeSheet
       hasReachedLimit:(TDSwipeSheetLimit)limit;

/**
 Tells the delegate when the SwipeSheet is going to play the animation. If you use this delegate method, you must return blocks of animation and completion.

 @param swipeSheet The SwipeSheetViewController object.
 @param animation A block object containing the changes to commit to the views. This parameter must not be NULL.
 @param completion A block object to be executed when the animation sequence ends. This parameter must not be NULL.
 */
- (void)swipeSheet:(TDSwipeSheetViewController *)swipeSheet
           willAnimate:(void (^)(void))animation
            completion:(void (^)(BOOL finished))completion;

/**
 Tells the delegate when the orientation of the TDSwipeSheetViewController changes.
 
 You can obtain the new orientation by getting the value of the orientation parameter.
 
 @param swipeSheet The TDSwipeSheetViewController object.
 @param orientation Substantially object orientation.
 */
- (void)swipeSheet:(TDSwipeSheetViewController *)swipeSheet
  didChangeOrientation:(TDSwipeSheetOrientation)orientation;

@end

/**
 TDSwipeSheet is a a simple, easy to integrate solution for presenting UIViewController or any view in bottom or top sheet. We handle all the hard work for you - transitions, gestures, taps and more are all automatically provided by the library. Styling, however, is intentionally left out, allowing you to integrate your own design language with ease.
 */
@interface TDSwipeSheetViewController: UIViewController

/**
 The delegate of the swipe sheet object.
 The delegate must adopt the TDSwipeSheetViewControllerDelegate protocol. The TDSwipeSheetViewController class, which does not retain the delegate, invokes each protocol method the delegate implements.
 */
@property (nonatomic, weak, nullable) id <TDSwipeSheetViewControllerDelegate> delegate;

/// You can call this block and get the height of the SwipeSheet
@property (nonatomic, copy) void (^swipeSheetChangesHeightBlock)(CGFloat height, TDSwipeSheetViewController *sheet);

/// The property that says that the view is expanded to the maximum size or at the minimaze. Setter animically expands or minimazes the SwipeSheet view.
@property (nonatomic, assign, getter=isFullSize) BOOL fullSize;

/// You can assign this control any scrolling view with your custom view for the correct work of dragging.
@property (nonatomic, strong) UIScrollView *observedScrollView;

/// You can turn gestures on or off.
- (void)setGestureEnabled:(BOOL)enabled;

/// It is animated to change the view to the maximum size if YES or the minimum if NO.
- (void)animateViewToFullSize:(BOOL)fullSize;

/// Add your custom view to the controller.
- (void)addCustomView:(UIView *)view;

/// You can show a SwipeSheet view on your view controller.
- (void)presentSwipeSheetOnViewController:(UIViewController *)viewController;

/// You can hide the SwipeSheet view animatively if YES or no animation if NO
- (void)dismissSwipeSheetAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end
