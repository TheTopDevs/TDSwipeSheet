//
//  UIView+Constraint.m
//  TDSwipeSheet
//
//  Created by TopDevs on 6/14/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import "UIView+Constraint.h"

@implementation UIView (Constraint)

- (void)addFullscreenView:(UIView *)view {
    [self addSubview:view];
    [self setOffsetsTo:view fromTop:0 fromBottom:0 fromLeft:0 fromRight:0];
}

- (void)setOffsetsTo:(UIView *)view fromTop:(CGFloat)top fromBottom:(CGFloat)botto fromLeft:(CGFloat)left fromRight:(CGFloat)right {
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%f)-[view]-(%f)-|", left, right]  options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%f)-[view]-(%f)-|", top, botto] options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    
    [self layoutIfNeeded];
}

@end
