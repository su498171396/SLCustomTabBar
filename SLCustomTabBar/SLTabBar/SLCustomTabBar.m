//
//  SLCustomTabBar.m
//  SLCustomTabBar
//
//  Created by 苏磊 on 2017/6/14.
//  Copyright © 2017年 苏磊. All rights reserved.
//

#import "SLCustomTabBar.h"
#import "SLButton.h"
#import "SLCenterButton.h"
#import "MiddleAnimation.h"

@interface SLCustomTabBar ()
/** selctButton */
@property (weak , nonatomic) SLButton *selButton;
/** center button of place */
@property(assign , nonatomic) NSInteger centerPlace;
/** Whether center button to bulge */
@property(assign , nonatomic,getter=is_bulge) BOOL bulge;
/** tabBarController */
@property (weak , nonatomic) UITabBarController *controller;
/** border */
@property (nonatomic,weak) CAShapeLayer *border;
@end

@implementation SLCustomTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.btnArr = [NSMutableArray array];
        //Set backgroundColor color
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/**
 *  Set items
 */
- (void)setItems:(NSArray<UITabBarItem *> *)items{
    _items = items;
    for (int i=0; i<items.count; i++)
    {
        UITabBarItem *item = items[i];
        UIButton *btn = nil;
        if (-1 != self.centerPlace && i == self.centerPlace)
        {
            self.centerBtn = [SLCenterButton buttonWithType:UIButtonTypeCustom];
            self.centerBtn.adjustsImageWhenHighlighted = NO;
            self.centerBtn.bulge = self.is_bulge;
            btn = self.centerBtn;
            if (item.tag == -1)
            {
                [btn addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [btn addTarget:self action:@selector(cntrolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        else
        {
            btn = [SLButton buttonWithType:UIButtonTypeCustom];
            //Add Observer
            [item addObserver:self forKeyPath:@"badgeValue"
                      options:NSKeyValueObservingOptionNew
                      context:(__bridge void * _Nullable)(btn)];
            [item addObserver:self forKeyPath:@"badgeColor"
                      options:NSKeyValueObservingOptionNew
                      context:(__bridge void * _Nullable)(btn)];
            
            [self.btnArr addObject:(SLButton *)btn];
            [btn addTarget:self action:@selector(cntrolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //Set image
        [btn setImage:item.image forState:UIControlStateNormal];
        [btn setImage:item.selectedImage forState:UIControlStateSelected];
        btn.adjustsImageWhenHighlighted = NO;
        
        //Set title
        [btn setTitle:item.title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:113/255.0 green:109/255.0 blue:104/255.0 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:113/255.0 green:109/255.0 blue:104/255.0 alpha:1] forState:UIControlStateSelected];
        
        btn.tag = item.tag;
        [self addSubview:btn];
    }
}

/**
 *  getter
 */
- (CAShapeLayer *)border{
    if (!_border) {
        CAShapeLayer *border = [CAShapeLayer layer];
        border.fillColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1].CGColor;
        border.path = [UIBezierPath bezierPathWithRect:
                       CGRectMake(0,0,self.bounds.size.width,0.5)].CGPath;
        [self.layer insertSublayer:border atIndex:0];
        _border = border;
    }
    return _border;
}


/**
 *  layout
 */
- (void)layoutSubviews{
    [super layoutSubviews];
    int count = (int)(self.centerBtn ? self.btnArr.count+1 : self.btnArr.count);
    int mid = count/2;
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width/count,self.bounds.size.height);
    int j = 0;
    
    for (int i=0; i<count; i++)
    {
        if (i == mid && self.centerBtn!= nil)
        {
            CGFloat h = self.items[self.centerPlace].title ? 10.f : 0;
            CGFloat radius = 10.f;
            self.centerBtn.frame = self.is_bulge
            ? CGRectMake(rect.origin.x+(rect.size.width-rect.size.height-radius)/2,
                         -BULGEH-h ,
                         rect.size.height+radius,
                         rect.size.height+radius)
            : rect;
        }
        else
        {
            self.btnArr[j++].frame = rect;
        }
        rect.origin.x += rect.size.width;
    }
    self.border.path = [UIBezierPath bezierPathWithRect:CGRectMake(0,0,self.bounds.size.width,1)].CGPath;
}

/**
 *  Pass events for center button
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = self.centerBtn.frame;
    if (CGRectContainsPoint(rect, point))
        return self.centerBtn;
    return [super hitTest:point withEvent:event];
}



/**
 *  Set bottom text normal color
 */
- (void)setTextColor:(UIColor *)textColor{
    for (UIButton *loop in self.btnArr) {
        [loop setTitleColor:textColor forState:UIControlStateNormal];
    }
    _textColor = textColor;
}

/**
 *  Set bottom text selected color
 */
- (void)setSelectedTextColor:(UIColor *)selectedTextColor{
    for (UIButton *loop in self.btnArr) {
        [loop setTitleColor:selectedTextColor forState:UIControlStateSelected];
    }
    _selectedTextColor = selectedTextColor;
}



/**
 *  Control button click
 */
- (void)cntrolBtnClick:(SLButton *)button{
    self.controller.selectedIndex = button.tag;
    [self setSelectButtoIndex:button.tag];
}

/**
 *  Set select button
 */
- (void)setSelectButtoIndex:(NSUInteger)index{
    for (SLButton *loop in self.btnArr) {
        if (loop.tag == index) {
            self.selButton = loop;
            return;
        }
    }
    if (index == self.centerBtn.tag) {
        self.selButton = (SLButton *)self.centerBtn;
    }
}

/**
 *  Switch select button to highlight
 */
- (void)setSelButton:(SLButton *)selButton{
    _selButton.selected = NO;
    _selButton = selButton;
    _selButton.selected = YES;
}


/**
 *  Center button click
 */
- (void)centerBtnClick:(SLCenterButton *)button{
    [MiddleAnimation standardMiddleAnimationWithView:button];
}


/**
 *  Observe the attribute value change
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"badgeValue"] || [keyPath isEqualToString:@"badgeColor"]) {
        SLButton *btn = (__bridge SLButton *)(context);
        btn.item = (UITabBarItem*)object;
    }
}

/**
 *  Remove observer
 */
- (void)dealloc{
    for (int i=0; i<self.btnArr.count; i++) {
        int index = ({
            int n = 0;
            if (-1 != _centerPlace)
                n = _centerPlace > i ? 0 : 1;
            i+n;});
        [self.items[index] removeObserver:self
                               forKeyPath:@"badgeValue"
                                  context:(__bridge void * _Nullable)(self.btnArr[i])];
        [self.items[index] removeObserver:self
                               forKeyPath:@"badgeColor"
                                  context:(__bridge void * _Nullable)(self.btnArr[i])];
    }
}

@end
