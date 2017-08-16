//
//  SLBadgeView.m
//  SLCustomTabBar
//
//  Created by 苏磊 on 2017/6/14.
//  Copyright © 2017年 苏磊. All rights reserved.
//

#import "SLBadgeView.h"

@implementation SLBadgeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = NO;
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        //set protection of image area
        UIImage *image = [UIImage imageNamed:@"SLTabBar.bundle/main_badge"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
        [self setBackgroundImage:image forState:UIControlStateNormal];
        //set text of alignment
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

/**
 *  Set remind number
 */
- (void)setBadgeValue:(NSString *)badgeValue
{
    if (![_badgeValue isEqualToString:badgeValue])
    {
        _badgeValue = badgeValue;
        [self layoutIfNeeded];
    }
}

/**
 *  Set color for remind Badge
 */
- (void)setBadgeColor:(UIColor *)badgeColor{
    if (badgeColor!=nil && ![_badgeColor isEqual:badgeColor]) {
        UIImage *image = [UIImage imageNamed:@"SLTabBar.bundle/main_badge"];
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
        CGContextRef ref = UIGraphicsGetCurrentContext();
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        CGContextClipToMask(ref, rect, image.CGImage);
        [badgeColor setFill];
        CGContextFillRect(ref, rect);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
        [self setBackgroundImage:image forState:UIControlStateNormal];
        _badgeColor = badgeColor;
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    /**
     *  red dot remind
     */
    if ([_badgeValue isEqualToString:@"remind"]) {
        self.frame = CGRectMake(self.superview.frame.size.width/2+7, 4,
                                self.currentBackgroundImage.size.width/2,
                                self.currentBackgroundImage.size.height/2);
        return;
    }
    
    /**
     *  number remind
     */
    if ([_badgeValue integerValue] <= 0) {
        _badgeValue = nil;
        self.hidden = YES;
        return;
    }
    
    
    int n = 0;
    self.hidden = NO;
    if ([_badgeValue integerValue]>999) {
        [self setTitle:@"···" forState:UIControlStateNormal];
    }
    else{
        n = [_badgeValue integerValue] > 9 ? 8 : 0; //number beyond 9 to broaden
        [self setTitle:_badgeValue forState:UIControlStateNormal];
    }
    
    self.frame = CGRectMake(self.superview.frame.size.width/2+5, 1,
                            self.currentBackgroundImage.size.width+n,
                            self.currentBackgroundImage.size.height);
}


@end
