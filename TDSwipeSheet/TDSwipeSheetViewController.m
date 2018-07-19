//
//  TDSwipeSheetViewController.m
//  TDSwipeSheet
//
//  Created by TopDevs on 5/8/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import "TDSwipeSheetViewController+Theme.h"
#import "UIView+Constraint.h"

#define kHandleButtonHeight                 25.f

#define displayWidth MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)

#define displayHeight MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)

typedef NS_ENUM(NSUInteger, TDSwipeSheetState) {
    TDSwipeSheetStateDragged              = 1 << 0,
    TDSwipeSheetStateTopLimitReached      = 1 << 1,
    TDSwipeSheetStateBottomLimitReached   = 1 << 2,
    TDSwipeSheetStateAnimated             = 1 << 3,
    TDSwipeSheetStateAppearing            = 1 << 4,
    TDSwipeSheetStateDisappearing         = 1 << 5,
    TDSwipeSheetStateChangeOrientation     = 1 << 6
};

@interface TDSwipeSheetViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapOnDimmingViewGesture;
@property (nonatomic, strong) UIButton *handleButton;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, strong) UIView *dimmingView;

@property (nonatomic, strong) NSLayoutConstraint *topOffsetConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomOffsetConstraint;
@property (nonatomic, strong) NSLayoutConstraint *viewHeightConstraint;

@property (nonatomic, strong) NSLayoutConstraint *visualEffectViewBottomOffset;
@property (nonatomic, strong) NSLayoutConstraint *visualEffectViewTopOffset;

@property (nonatomic, strong) UIVisualEffectView *visualEffectView;

@property (nonatomic, assign) TDSwipeSheetOrientation orientation;

@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat verticalTopLimit;
@property (nonatomic, assign) CGFloat verticalBottomLimit;

@property (nonatomic, assign) TDSwipeSheetState state;

@end

@implementation TDSwipeSheetViewController

+ (CGSize)screenSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIEdgeInsets safeAreaInsets = [TDSwipeSheetViewController safeAreaInsets];
    screenSize.height -= safeAreaInsets.bottom;
    return screenSize;
}

+ (UIEdgeInsets)safeAreaInsets {
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        return window.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

#pragma mark - Life Cycle

- (void)dealloc {
    
    self.panGesture = nil;
    self.tapOnDimmingViewGesture = nil;
    self.handleButton = nil;
    self.container = nil;
    self.stackView = nil;
    self.dimmingView = nil;
    self.topOffsetConstraint = nil;
    self.bottomOffsetConstraint = nil;
    self.viewHeightConstraint = nil;
    self.visualEffectViewBottomOffset = nil;
    self.visualEffectViewTopOffset = nil;
    self.visualEffectView = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        CGSize screenSize = [TDSwipeSheetViewController screenSize];
        self.verticalTopLimit = screenSize.height / 4.;
        self.verticalBottomLimit = screenSize.height - self.verticalTopLimit / 2;
        
        self.viewHeight = screenSize.height - self.verticalTopLimit;
        [self setUpLightTheme];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self SS_setUpUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addObserver:self
           forKeyPath:@"parentViewController.view.frame"
              options:NSKeyValueObservingOptionOld
              context:NULL];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if([keyPath isEqualToString:@"parentViewController.view.frame"]) {
        CGRect oldFrame = CGRectNull;
        CGRect newFrame = CGRectNull;
        if([change objectForKey:@"old"] != [NSNull null]) {
            oldFrame = [[change objectForKey:@"old"] CGRectValue];
        }
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
        }
        if (oldFrame.size.width != newFrame.size.width) {
            if (newFrame.size.width == displayWidth) {
                self.orientation = TDSwipeSheetOrientationPortrait;
            } else {
                self.orientation = TDSwipeSheetOrientationLandscape;
            }
        }
    }
}

#pragma mark - IBAction

- (void)topButtonAction:(UIButton *)sender {
    [self animateViewToFullSize:!self.isFullSize];
}

#pragma mark - Public

- (void)dismissSwipeSheetAnimated:(BOOL)animated completion:(void (^)(void))completion {
    
    [self setState:TDSwipeSheetStateDisappearing];
    
    CGFloat yPos = UIScreen.mainScreen.bounds.size.height + 10;
    if (self.isFromBottom == NO) {
        yPos = -10;
    }
    [self willMoveToParentViewController:nil];

    __weak __typeof(self) weakSelf = self;
    [self animate:animated animation:^{
        
        if (weakSelf.isFromBottom) {
            weakSelf.topOffsetConstraint.constant = yPos;
        } else {
            weakSelf.bottomOffsetConstraint.constant = -(UIScreen.mainScreen.bounds.size.height - yPos);
        }
        
        [weakSelf.parentViewController.view layoutIfNeeded];

    } completion:^(BOOL finished) {
        
        if (finished) {
            if (completion) {
                completion();
            }
            if (weakSelf.state == TDSwipeSheetStateDisappearing) {
                [weakSelf.view removeFromSuperview];
                [weakSelf.dimmingView removeFromSuperview];
                [weakSelf removeFromParentViewController];
            }
        }
    }];
}

- (void)presentSwipeSheetOnViewController:(UIViewController *)viewController {
    
    [self setState:TDSwipeSheetStateAppearing];
    if (![viewController isEqual:self.parentViewController]) {
        
        [self willMoveToParentViewController:viewController];
        [viewController addChildViewController:self];
        [viewController.view addFullscreenView:self.dimmingView];
        
        [viewController.view addSubview:self.view];
        
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"view": self.view}]];
        
        self.topOffsetConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:viewController.view
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.f
                                                                 constant:self.verticalBottomLimit];
        self.bottomOffsetConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:viewController.view
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.f
                                                                    constant:self.verticalTopLimit];
        
        self.viewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:0
                                                                  constant:self.viewHeight];
        if (self.fromBottom) {
            [viewController.view addConstraint:self.topOffsetConstraint];
            [viewController.view removeConstraint:self.bottomOffsetConstraint];
        } else {
            [viewController.view addConstraint:self.bottomOffsetConstraint];
            [viewController.view removeConstraint:self.topOffsetConstraint];
        }
        [viewController.view addConstraint:self.viewHeightConstraint];
        [viewController.view layoutIfNeeded];
        
        [self updateViewToFullSize:NO animated:YES];
    }
    [self themeRefresh];
}

- (void)addCustomView:(UIView *)view {
    [self.container addFullscreenView:view];
}

- (void)setGestureEnabled:(BOOL)enabled {
    self.panGesture.enabled = enabled;
}

- (void)animateViewToFullSize:(BOOL)fullSize {
    [self updateViewToFullSize:fullSize animated:YES];
}

#pragma mark - Private

- (void)SS_setUpUI {
    
    [self.view addGestureRecognizer:self.panGesture];
    
    if (self.visualEffectView == nil) {
        
        self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:self.visualEffect];
        [self.view addSubview:self.visualEffectView];
        [self.view sendSubviewToBack:self.visualEffectView];
        
        self.visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:@{@"view": self.visualEffectView}]];
        
        
        self.visualEffectViewTopOffset = [NSLayoutConstraint constraintWithItem:self.visualEffectView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.f
                                                                       constant:0];
        
        self.visualEffectViewBottomOffset = [NSLayoutConstraint constraintWithItem:self.visualEffectView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.f
                                                                          constant:0.f];
        [self.view addConstraints:@[self.visualEffectViewTopOffset, self.visualEffectViewBottomOffset]];
    }
    
    if (self.stackView.arrangedSubviews.count != 0) {
        [self.stackView removeArrangedSubview:self.handleButton];
        [self.stackView removeArrangedSubview:self.container];
    }
    
    if (self.isFromBottom) {
        [self.stackView addArrangedSubview:self.handleButton];
        [self.stackView addArrangedSubview:self.container];
    } else {
        [self.stackView addArrangedSubview:self.container];
        [self.stackView addArrangedSubview:self.handleButton];
    }
    
    [self setMaskTo:self.visualEffectView byDirection:self.isFromBottom];
}

- (void)setMaskTo:(UIView *)view byDirection:(BOOL)isFromBottom {
    
    view.clipsToBounds = YES;
    view.layer.cornerRadius = self.cornerRadius;
    
    if (isFromBottom) {
        self.visualEffectViewBottomOffset.constant = 100;
        self.visualEffectViewTopOffset.constant = 0;
        
    } else {
        self.visualEffectViewBottomOffset.constant = 0;
        self.visualEffectViewTopOffset.constant = -100;
    }
}

- (BOOL)hasExceededTopVerticalLimit:(CGFloat)yPosition {
    return yPosition < self.verticalTopLimit;
}

- (BOOL)hasExceededBottomVerticalLimit:(CGFloat)yPosition {
    return yPosition > self.verticalBottomLimit;
}

- (CGFloat)topValueForYPosition:(CGFloat)yPosition {
    return self.verticalTopLimit - sqrt(self.verticalTopLimit - yPosition);
}

- (CGFloat)bottomValueForYPosition:(CGFloat)yPosition {
    return self.verticalBottomLimit + sqrt(yPosition - self.verticalBottomLimit);
}

#pragma mark - Gesture

- (void)swipePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    [self setState:TDSwipeSheetStateDragged];

    if ([self.delegate respondsToSelector:@selector(swipeSheetDragged:)]) {
        [self.delegate swipeSheetDragged:self];
    }
    
    CGFloat y = fabs(self.topOffsetConstraint.constant);
    if (!self.isFromBottom) {
        y = UIScreen.mainScreen.bounds.size.height - fabs(self.bottomOffsetConstraint.constant);
    }
    CGFloat finalY = 0;
    CGFloat linearY = y + translation.y;
    if ([self hasExceededTopVerticalLimit:linearY]) {
        
        if ([self.delegate respondsToSelector:@selector(swipeSheet:hasReachedLimit:)]) {
            [self.delegate swipeSheet:self hasReachedLimit:TDSwipeSheetLimitTop];
        }
        [self setState:TDSwipeSheetStateTopLimitReached];
        finalY = [self topValueForYPosition:linearY];
    } else if ([self hasExceededBottomVerticalLimit:linearY]) {
        if ([self.delegate respondsToSelector:@selector(swipeSheet:hasReachedLimit:)]) {
            [self.delegate swipeSheet:self hasReachedLimit:TDSwipeSheetLimitBottom];
        }
        [self setState:TDSwipeSheetStateBottomLimitReached];
        finalY = [self bottomValueForYPosition:linearY];
    } else {
        finalY = y + translation.y;
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
    
    if (self.isFromBottom) {
        self.topOffsetConstraint.constant = finalY;
    } else {
        self.bottomOffsetConstraint.constant = - (UIScreen.mainScreen.bounds.size.height - finalY);
    }
    
    if (self.swipeSheetChangesHeightBlock) {
        self.swipeSheetChangesHeightBlock(UIScreen.mainScreen.bounds.size.height - y, self);
    }
    
    __weak __typeof(self)weakSelf = self;
    [self animate:YES animation:^{
        
        if (weakSelf.state & TDSwipeSheetStateTopLimitReached) {
            [weakSelf.dimmingView setHidden:!weakSelf.isFromBottom];
        } else if (weakSelf.state & TDSwipeSheetStateBottomLimitReached) {
            [weakSelf.dimmingView setHidden:weakSelf.isFromBottom];
        } else  {
            
            CGFloat alpha = 1;
            [weakSelf.dimmingView setHidden:NO];
            if (weakSelf.isFromBottom) {
                double percent = 1 - fabs(weakSelf.verticalTopLimit - weakSelf.view.frame.origin.y) / (weakSelf.view.frame.size.height - (UIScreen.mainScreen.bounds.size.height - weakSelf.verticalBottomLimit));
                alpha = MAX(0.0, percent);
            } else {
                double percent = 1 - fabs(weakSelf.view.frame.origin.y) / fabs(weakSelf.view.frame.size.height - weakSelf.verticalTopLimit);
                alpha = MAX(0.0, percent);
            }
            [weakSelf.dimmingView setAlpha:alpha];
        }
    } completion:nil];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGFloat y = CGRectGetMinY(self.view.frame);
        if (!self.isFromBottom) {
            y = CGRectGetMaxY(self.view.frame);
        }
        
        if ([self hasExceededTopVerticalLimit:y]) {
            [self animateViewToFullSize:self.isFromBottom? YES: NO];
        } else if ([self hasExceededBottomVerticalLimit:y]) {
            [self animateViewToFullSize:self.isFromBottom? NO: YES];
        } else {
            if (velocity.y > 0) {
                [self animateViewToFullSize:self.isFromBottom? NO: YES];
            } else {
                [self animateViewToFullSize:self.isFromBottom? YES: NO];
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
    
    CGFloat direction = [gesture velocityInView:self.view].y;
    
    if (self.observedScrollView) {
        
        CGFloat y = self.isFromBottom?
        self.topOffsetConstraint.constant:
        (UIScreen.mainScreen.bounds.size.height - fabs(self.bottomOffsetConstraint.constant));
        
        if (self.isFromBottom) {
            
            if ((y == self.verticalTopLimit &&
                 self.observedScrollView.contentOffset.y <= 0 && direction > 0) ||
                (y == self.verticalBottomLimit)) {
                [self.observedScrollView setScrollEnabled:NO];
            } else {
                [self.observedScrollView setScrollEnabled:YES];
            }
        } else {
            CGFloat outscreenHeight = self.observedScrollView.contentSize.height - (self.observedScrollView.bounds.size.height + self.observedScrollView.contentOffset.y);
            if ((y == self.verticalBottomLimit && outscreenHeight <= 0 && direction < 0 && self.observedScrollView.contentOffset.y >= 0) || y == self.verticalTopLimit) {
                [self.observedScrollView setScrollEnabled:NO];
            } else {
                [self.observedScrollView setScrollEnabled:YES];
            }
        }
    }
    return NO;
}

#pragma mark - Animation

- (void)animate:(BOOL)animated animation:(void (^)(void))animation completion:(void (^)(BOOL finished))completion {
    
    if (!animated) {
        animation();
        completion(YES);
    }
    if ([self.delegate respondsToSelector:@selector(swipeSheet:willAnimate:completion:)]) {
        [self.delegate swipeSheet:self willAnimate:animation completion:completion];
    } else {
        [UIView animateWithDuration:(animated ? 0.3f : 0.f) delay:0. options:UIViewAnimationOptionAllowUserInteraction animations:animation completion:completion];
    }
}

- (void)updateViewToFullSize:(BOOL)fullSize animated:(BOOL)animated {
    
    CGFloat yPos = fullSize? self.verticalTopLimit: self.verticalBottomLimit;
    
    if (!self.isFromBottom) {
        yPos = fullSize? self.verticalBottomLimit: self.verticalTopLimit;
    }
    if (fullSize) {
        [self.dimmingView setHidden:NO];
    }
    
    __weak __typeof(self) weakSelf = self;
    
    [self animate:animated animation:^{
        
        [weakSelf setState:TDSwipeSheetStateAnimated];
        
        [weakSelf.dimmingView setAlpha:fullSize ? 1 : 0.0];

        if (weakSelf.isFromBottom) {
            weakSelf.topOffsetConstraint.constant = yPos;
        } else {
            weakSelf.bottomOffsetConstraint.constant = -(UIScreen.mainScreen.bounds.size.height - yPos);
        }
        
        if (weakSelf.swipeSheetChangesHeightBlock) {
            weakSelf.swipeSheetChangesHeightBlock(UIScreen.mainScreen.bounds.size.height - yPos, weakSelf);
        }
        [weakSelf.parentViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            if (fullSize) {
                
                [weakSelf.observedScrollView setScrollEnabled:YES];
                if ([self.delegate respondsToSelector:@selector(swipeSheet:hasReachedLimit:)]) {
                    
                    [self.delegate swipeSheet:self hasReachedLimit:fullSize? (weakSelf.isFromBottom? TDSwipeSheetLimitTop: TDSwipeSheetLimitBottom):(weakSelf.isFromBottom? TDSwipeSheetLimitBottom: TDSwipeSheetLimitTop)];
                }
            }
            weakSelf.fullSize = fullSize;
            [weakSelf.view layoutIfNeeded];
        }
    }];
}

#pragma mark - Private accessors

- (UIPanGestureRecognizer *)panGesture {
    if (_panGesture != nil) {
        return _panGesture;
    }
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGesture:)];
    _panGesture.delegate = self;
    return _panGesture;
}

- (UIStackView *)stackView {
    
    if (_stackView != nil) {
        return _stackView;
    }
    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.distribution = UIStackViewDistributionFill;
    _stackView.alignment = UIStackViewAlignmentFill;
    _stackView.spacing = 8;
    [self.view addSubview:_stackView];
    [self.view setOffsetsTo:_stackView fromTop:8 fromBottom:8 fromLeft:0 fromRight:0];
    [self.view bringSubviewToFront:_stackView];
    
    return _stackView;
}

- (UIButton *)handleButton {
    if (_handleButton != nil) {
        return _handleButton;
    }
    
    _handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handleButton addTarget:self
                      action:@selector(topButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    [self setHandleButtonIcon:[UIImage imageNamed:@"TDSwipeSheetHandleButtonIcon.png"]];
    [_handleButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    NSLayoutConstraint *height = [NSLayoutConstraint
                                  constraintWithItem:_handleButton
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:0
                                  constant:kHandleButtonHeight];
    
    [_handleButton addConstraint:height];
    return _handleButton;
}

- (UIView *)container {
    if (_container != nil) {
        return _container;
    }
    _container = [UIView new];
    _container.backgroundColor = UIColor.clearColor;
    return _container;
}

- (void)setOrientation:(TDSwipeSheetOrientation)orientation {
    
    if (_orientation == orientation) {
        return;
    }
    _orientation = orientation;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    switch (orientation) {
        case TDSwipeSheetOrientationLandscape:
            screenSize = CGSizeMake(displayHeight, displayWidth);
            break;
        case TDSwipeSheetOrientationPortrait:
            screenSize = CGSizeMake(displayWidth, displayHeight);
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(needsVerticalTopLimitForSwipeSheetView:)]) {
        self.verticalTopLimit = [self.delegate needsVerticalTopLimitForSwipeSheetView:self];
    } else {
        self.verticalTopLimit = screenSize.height / 4.;
    }
    if ([self.delegate respondsToSelector:@selector(needsVerticalBottomLimitForSwipeSheetView:)]) {
        self.verticalBottomLimit = [self.delegate needsVerticalBottomLimitForSwipeSheetView:self];
    } else {
        self.verticalBottomLimit = screenSize.height - self.verticalTopLimit / 2;
    }
    
    
    if (self.fromBottom) {
        self.viewHeight = screenSize.height - self.verticalTopLimit;
    } else {
        self.viewHeight = self.verticalBottomLimit;
    }
    [self SS_setUpUI];
    if ([self.delegate respondsToSelector:@selector(swipeSheet:didChangeOrientation:)]) {
        [self.delegate swipeSheet:self didChangeOrientation:_orientation];
    }
    [self updateViewToFullSize:self.isFullSize animated:YES];
}

- (void)setViewHeight:(CGFloat)viewHeight {
    _viewHeight = viewHeight;
    self.viewHeightConstraint.constant = viewHeight;
}

- (UIView *)dimmingView {
    
    if (_dimmingView == nil) {
        _dimmingView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        [_dimmingView setBackgroundColor:self.dimmingViewColor];
        [self.dimmingView addGestureRecognizer:self.tapOnDimmingViewGesture];
    }
    return _dimmingView;
}

- (UITapGestureRecognizer *)tapOnDimmingViewGesture {
    
    if (_tapOnDimmingViewGesture == nil) {
        _tapOnDimmingViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topButtonAction:)];
    }
    return _tapOnDimmingViewGesture;
}

- (void)setState:(TDSwipeSheetState)state {
    
    if (self.state & TDSwipeSheetStateAppearing &&
        state && state & TDSwipeSheetStateAnimated) {
        _state = TDSwipeSheetStateAnimated | TDSwipeSheetStateAppearing;
    } else if (self.state & TDSwipeSheetStateDisappearing &&
               state && state & TDSwipeSheetStateAnimated) {
        _state = TDSwipeSheetStateAnimated | TDSwipeSheetStateDisappearing;
    } else if (self.state & TDSwipeSheetStateDragged && state & TDSwipeSheetStateTopLimitReached) {
        _state = TDSwipeSheetStateDragged | TDSwipeSheetStateTopLimitReached;
    } else if (self.state & TDSwipeSheetStateDragged && state & TDSwipeSheetStateBottomLimitReached) {
        _state = TDSwipeSheetStateDragged | TDSwipeSheetStateBottomLimitReached;
    } else {
        _state = state;
    }
}

@end
