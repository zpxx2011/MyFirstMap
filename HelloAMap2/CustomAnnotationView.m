//
//  CustomAnnotationView.m
//  HelloAMap2
//
//  Created by Devin on 15/11/6.
//  Copyright © 2015年 Devin. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomCalloutView.h"

#define kCalloutWidth 250.0
#define kCalloutHeight 70.0

@implementation CustomAnnotationView

#pragma mark ---- Override
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
    if (self.selected == selected) {
        
        return;
    }
    if (selected) {
        
        if (self.calloutView == nil) {
            
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:(CGRectMake(0, 0, kCalloutWidth, kCalloutHeight))];
            self.calloutView.center = CGPointMake(self.bounds.size.width / 2.f + self.calloutOffset.x, -self.calloutView.bounds.size.height / 2.f + self.calloutOffset.y);
        }
        
        // 将数据传入
        self.calloutView.image = [UIImage imageNamed:@"building"];
        self.calloutView.title = self.annotation.title;
        self.calloutView.subTitle = self.annotation.subtitle;
        
        [self addSubview:self.calloutView];
    }else{
        
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

// 重写此函数,用以实现点击calloutView判断为点击该annotationView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    BOOL inside = [super pointInside:point withEvent:event];
    
    if (!inside && self.selected) {
        
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}



@end
