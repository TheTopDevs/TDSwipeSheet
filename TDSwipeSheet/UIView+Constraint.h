//
//  UIView+Constraint.h
//  TDSwipeSheet
//
//  Created by TopDevs on 6/14/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Constraint)

- (void)addFullscreenView:(UIView *)view;

- (void)setOffsetsTo:(UIView *)view
             fromTop:(CGFloat)top
          fromBottom:(CGFloat)botto
            fromLeft:(CGFloat)left
           fromRight:(CGFloat)right;

@end
