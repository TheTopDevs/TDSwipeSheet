//
//  TableViewCell.m
//  TDSwipeSheetDemo
//
//  Created by TopDevs on 6/13/18.
//  Copyright © 2018 TopDevs. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

+ (UINib *)nibFroCell {
    return  [UINib nibWithNibName:@"TableViewCell" bundle:nil];
}

+ (NSString *)reusableID {
    return @"TableViewCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
