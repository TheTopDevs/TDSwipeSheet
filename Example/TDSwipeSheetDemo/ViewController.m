//
//  ViewController.m
//  TDSwipeSheetDemo
//
//  Created by TopDevs on 6/6/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import "ViewController.h"

#import "TableSwipeSheet.h"
#import "TDSwipeSheetViewController.h"
#import "TDSwipeSheetViewController+Theme.h"
#import "TableViewCell.h"

#import "UIImageView+URL.h"

#import <WebKit/WebKit.h>

@interface Content: NSObject

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) NSURL *link;

- (instancetype)initWithImage:(NSString *)image name:(NSString *)name category:(NSString *)category number:(NSInteger)number link:(NSURL *)link;

@end

@implementation Content

- (instancetype)initWithImage:(NSString *)imagePath name:(NSString *)name category:(NSString *)category number:(NSInteger)number link:(NSURL *)link {
    self = [super init];
    
    self.imageURL = [NSURL URLWithString:imagePath];
    self.name = name;
    self.category = category;
    self.number = number;
    self.link = link;
    
    return self;
}
    
@end

@interface ViewController () <TableSwipeSheetDelegate, TableSwipeSheetDataSource, TDSwipeSheetViewControllerDelegate>

@property (nonatomic, strong) TableSwipeSheet *tableSwipeSheet;
@property (nonatomic, strong) TDSwipeSheetViewController *swipeSheetViewController;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSArray <Content *>*contentArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentArray = @[[[Content alloc] initWithImage:@"https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Einstein_1921_by_F_Schmutzer_-_restoration.jpg/440px-Einstein_1921_by_F_Schmutzer_-_restoration.jpg"
                                                   name:@"Albert Einstein"
                                               category:@"Physics, philosophy"
                                                 number:1
                                                    link:[NSURL URLWithString:@"https://en.wikipedia.org/wiki/Albert_Einstein"]],
                         [[Content alloc] initWithImage:@"https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/GodfreyKneller-IsaacNewton-1689.jpg/440px-GodfreyKneller-IsaacNewton-1689.jpg"
                                                   name:@"Isaac Newton"
                                               category:@"Physics, Astronomy, Mathematics"
                                                 number:2
                                                   link:[NSURL URLWithString:@"https://en.wikipedia.org/wiki/Isaac_Newton"]],
                         [[Content alloc] initWithImage:@"https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Justus_Sustermans_-_Portrait_of_Galileo_Galilei%2C_1636.jpg/440px-Justus_Sustermans_-_Portrait_of_Galileo_Galilei%2C_1636.jpg"
                                                   name:@"Galileo Galilei"
                                               category:@"Astronomy, physics, engineering"
                                                 number:3
                                                   link:[NSURL URLWithString:@"https://en.wikipedia.org/wiki/Galileo_Galilei"]],
                         [[Content alloc] initWithImage:@"https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/N.Tesla.JPG/440px-N.Tesla.JPG"
                                                   name:@"Nikola Tesla"
                                               category:@"Physics, engineering"
                                                 number:4
                                                   link:[NSURL URLWithString:@"https://en.wikipedia.org/wiki/Nikola_Tesla"]],
                         [[Content alloc] initWithImage:@"https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Charles_Darwin_seated_crop.jpg/440px-Charles_Darwin_seated_crop.jpg"
                                                   name:@"Charles Darwin"
                                               category:@"Natural history, geology"
                                                 number:5
                                                   link:[NSURL URLWithString:@"https://en.wikipedia.org/wiki/Charles_Darwin"]],
                         [[Content alloc] initWithImage:@"https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/Curie-nobel-portrait-2-600.jpg/519px-Curie-nobel-portrait-2-600.jpg"
                                                   name:@"Marie Curie"
                                               category:@"Physics, chemistry"
                                                 number:6
                                                   link:[NSURL URLWithString:@"https://en.wikipedia.org/wiki/Marie_Curie"]],
                         [[Content alloc] initWithImage:@"https://upload.wikimedia.org/wikipedia/commons/e/eb/Stephen_Hawking.StarChild.jpg"
                                                   name:@"Stephen Hawking"
                                               category:@"General relativity, quantum gravity"
                                                 number:7
                                                   link:[NSURL URLWithString:@"https://en.wikipedia.org/wiki/Stephen_Hawking"]]];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableSwipeSheet = [TableSwipeSheet new];
    [self.tableSwipeSheet registerNib:[TableViewCell nibFroCell] forCellReuseIdentifier:[TableViewCell reusableID]];
    
    self.tableSwipeSheet.fromBottom = NO;
    self.tableSwipeSheet.backgroundColor = UIColor.whiteColor;
    [self.tableSwipeSheet setTableDelegate:self];
    [self.tableSwipeSheet setDataSource:self];
    
    [self.tableSwipeSheet presentSwipeSheetOnViewController:self];
    
    self.swipeSheetViewController = [TDSwipeSheetViewController new];

    self.webView = [[WKWebView alloc] init];
    self.webView.backgroundColor = UIColor.clearColor;
    [self.swipeSheetViewController addCustomView:self.webView];
    [self.swipeSheetViewController setUpDarkTheme];
    
}

- (NSInteger)numberOfRowsForSwipeSheetViewController:(TableSwipeSheet *)swipeSheet {
    return self.contentArray.count;
}

- (UITableViewCell *)swipeSheetViewController:(TableSwipeSheet *)swipeSheet cellForRowAtIndex:(NSInteger)index {
    TableViewCell *cell = [swipeSheet dequeueReusableCellWithIdentifier:[TableViewCell reusableID] forIndex:index];
    
    Content *object = self.contentArray[self.contentArray.count - 1 - index];
    [cell setBackgroundColor: UIColor.clearColor];
    [cell.pImageView loadImageFrom:object.imageURL];
    [cell.nameLabel setText:[@"Name: " stringByAppendingString:object.name]];
    [cell.numberLabel setText:[NSString stringWithFormat:@"#%@%ld", (object.number >= 10 ? (object.number >= 10 ? @"0" : @"0") : @"00"), (long)object.number]];
    [cell.categoryLabel setText:[@"Category: " stringByAppendingString:object.category]];
    
    return cell;
}

- (CGFloat)swipeSheetViewController:(TableSwipeSheet *)swipeSheet heightForRowAtIndex:(NSInteger)index {
    return 100;
}

- (void)swipeSheetViewController:(TableSwipeSheet *)swipeSheet didSelectRowAtIndex:(NSInteger)index {
    Content *object = self.contentArray[self.contentArray.count - 1 - index];

    [self.swipeSheetViewController presentSwipeSheetOnViewController:self];
    [self.webView loadRequest:[NSURLRequest requestWithURL:object.link]];
    [self.swipeSheetViewController animateViewToFullSize:YES];
    
}

- (void)swipeSheetViewController:(TableSwipeSheet *)swipeSheet didDeselectRowAtIndex:(NSInteger)index {
    [self.swipeSheetViewController dismissSwipeSheetAnimated:YES completion:nil];
}

@end

