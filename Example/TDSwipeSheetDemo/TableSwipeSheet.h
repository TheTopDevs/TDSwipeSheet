//
//  TableSwipeSheet.h
//  TDSwipeSheetDemo
//
//  Created by TopDevs on 5/4/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSwipeSheetViewController.h"

@protocol TableSwipeSheetDelegate;
@protocol TableSwipeSheetDataSource;

@interface TableSwipeSheet : TDSwipeSheetViewController

@property (nonatomic, weak, nullable) id <TableSwipeSheetDataSource> dataSource;
@property (nonatomic, weak, nullable) id <TableSwipeSheetDelegate> tableDelegate;

- (void)reloadData;
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;
- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

@end

@protocol TableSwipeSheetDelegate <NSObject>

@required

@optional

- (void)swipeSheetViewController:(TableSwipeSheet *)swipeSheet didSelectRowAtIndex:(NSInteger)index;
- (void)swipeSheetViewController:(TableSwipeSheet *)swipeSheet didDeselectRowAtIndex:(NSInteger)index;

- (void)swipeSheetViewController:(TableSwipeSheet *)swipeSheet willDisplayCell:(UITableViewCell *)cell;

@end

@protocol TableSwipeSheetDataSource <NSObject>

@required

- (NSInteger)numberOfRowsForSwipeSheetViewController:(TableSwipeSheet *)swipeSheet;
- (UITableViewCell *)swipeSheetViewController:(TableSwipeSheet *)swipeSheet cellForRowAtIndex:(NSInteger)index;

@optional

- (CGFloat)swipeSheetViewController:(TableSwipeSheet *)swipeSheet heightForRowAtIndex:(NSInteger)index;

@end
