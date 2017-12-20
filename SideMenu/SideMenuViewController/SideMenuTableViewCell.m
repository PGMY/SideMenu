//
//  SideMenuTableViewCell.m
//  SideMenu
//
//  Created by PGMY on 2017/11/07.
//  Copyright © 2017年 PGMY. All rights reserved.
//

#import "SideMenuTableViewCell.h"

@implementation SideMenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( self ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//    if ( selected ) {
//        self.backgroundColor = [UIColor secondaryColor];
//    } else {
//        self.backgroundColor = [UIColor clearColor];
//    }
//    // Configure the view for the selected state
//}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if ( highlighted ) {
        self.backgroundColor = [UIColor darkGrayColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}
@end
