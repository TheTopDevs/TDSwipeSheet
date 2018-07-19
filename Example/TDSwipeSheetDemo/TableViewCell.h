//
//  TableViewCell.h
//  TDSwipeSheetDemo
//
//  Created by TopDevs on 6/13/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *pImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

+ (UINib *)nibFroCell;
+ (NSString *)reusableID;
@end
