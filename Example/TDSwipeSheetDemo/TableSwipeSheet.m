//
//  TableSwipeSheet.h
//  TDSwipeSheetDemo
//
//  Created by TopDevs on 5/4/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import "TableSwipeSheet.h"

@interface TableSwipeSheet () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation TableSwipeSheet

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
    
    [self addCustomView:self.tableView];
}

- (void)setUpUI {
    
    self.tableView.estimatedRowHeight = 60.f;
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        UIEdgeInsets safeAreaInsets = window.safeAreaInsets;
        self.tableView.contentInset = UIEdgeInsetsMake(0., 0., safeAreaInsets.bottom, 0.);
    } else {
        self.tableView.contentInset = UIEdgeInsetsMake(0., 0., 8., 0.);
    }
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger row = [weakSelf.tableView numberOfRowsInSection:0] - 1;
        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    UITableViewCell *cell =[self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell;
}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)topButtonAction:(UIButton *)sender {
    [self animateViewToFullSize:!self.isFullSize];
}

//MARK: - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(numberOfRowsForSwipeSheetViewController:)]) {
        return [self.dataSource numberOfRowsForSwipeSheetViewController:self];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(swipeSheetViewController:heightForRowAtIndex:)]) {
        return [self.dataSource swipeSheetViewController:self heightForRowAtIndex:indexPath.row];
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(swipeSheetViewController:cellForRowAtIndex:)]) {
        return [self.dataSource swipeSheetViewController:self cellForRowAtIndex:indexPath.row];
    }
    UITableViewCell *cell = [UITableViewCell new];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tableDelegate respondsToSelector:@selector(swipeSheetViewController:willDisplayCell:)]) {
        [self.tableDelegate swipeSheetViewController:self willDisplayCell:cell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    if (self.selectedIndex == indexPath.row) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedIndex = -1000;
        if ([self.tableDelegate respondsToSelector:@selector(swipeSheetViewController:didDeselectRowAtIndex:)]) {
            [self.tableDelegate swipeSheetViewController:self didDeselectRowAtIndex:indexPath.row];
        }
    } else {
        if ([self.tableDelegate respondsToSelector:@selector(swipeSheetViewController:didSelectRowAtIndex:)]) {
            [self.tableDelegate swipeSheetViewController:self didSelectRowAtIndex:indexPath.row];
        }
        self.selectedIndex = indexPath.row;
    }
}

- (UITableView *)tableView {
    if (_tableView != nil) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = UIColor.clearColor;
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    self.observedScrollView = _tableView;
    return _tableView;
}

@end
