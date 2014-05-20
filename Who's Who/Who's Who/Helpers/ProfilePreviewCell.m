//
//  ProfilePreviewCell.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "ProfilePreviewCell.h"

@implementation ProfilePreviewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib
{
	self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2;
	self.profileImageView.layer.masksToBounds = YES;
}


@end
