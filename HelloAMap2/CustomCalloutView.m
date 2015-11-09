//
//  CustomCalloutView.m
//  HelloAMap2
//
//  Created by Devin on 15/11/6.
//  Copyright © 2015年 Devin. All rights reserved.
//

#import "CustomCalloutView.h"

#define kArrorHeight        10

#define kPortraitMargin     5
#define kPortraitWidth      70
#define kPortraitHeight     50

#define kTitleWidth         120
#define kTitleHeight        20

@interface CustomCalloutView ()

// 对应气泡上的控件
@property (nonatomic, strong) UIImageView *portraitView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;


@end


@implementation CustomCalloutView

// 将气泡背景色改为透明色
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initSubviews];
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

// 初始化控件
- (void)initSubviews{
    
    // 添加图片
    self.portraitView = [[UIImageView alloc] initWithFrame:(CGRectMake(kPortraitMargin, kPortraitMargin, kPortraitWidth, kPortraitHeight))];
    self.portraitView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.portraitView];
    
    // 添加标题
    self.titleLabel = [[UILabel alloc] initWithFrame:(CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin, kTitleWidth, kTitleHeight))];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = @"title";
    [self addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:(CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin * 2 + kTitleHeight, kTitleWidth, kTitleHeight))];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12];
    self.subtitleLabel.textColor = [UIColor cyanColor];
    self.subtitleLabel.text = @"subTitle";
    [self addSubview:self.subtitleLabel];
    
    self.GoButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.GoButton.frame = CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.bounds.size.width + 5, self.titleLabel.frame.origin.y, 40, 40);
    self.GoButton.backgroundColor = [UIColor whiteColor];
    [self.GoButton setTitle:@"GO" forState:(UIControlStateNormal)];
    [self addSubview:self.GoButton];
    
}

#pragma mark ----- 将数据属性和控件联系起来
- (void)setTitle:(NSString *)title{
    
    self.titleLabel.text = title;
}
- (void)setSubTitle:(NSString *)subTitle{
    
    self.subtitleLabel.text = subTitle;
}
- (void)setImage:(UIImage *)image{
    
    self.portraitView.image = image;
}



#pragma mark --- draw rect
- (void)drawRect:(CGRect)rect{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)drawInContext:(CGContextRef)context{
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3].CGColor);
    
    [self getDrawPath:context];
    
    CGContextFillPath(context);
}

- (void)getDrawPath:(CGContextRef)context{
    
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    
    CGFloat minX = CGRectGetMinX(rrect);
    CGFloat midX = CGRectGetMidX(rrect);
    CGFloat maxX = CGRectGetMaxX(rrect);
    
    CGFloat minY = CGRectGetMinY(rrect);
    CGFloat maxY = CGRectGetMaxY(rrect) - kArrorHeight;
    
    CGContextMoveToPoint(context, midX + kArrorHeight, maxY);
    CGContextAddLineToPoint(context, midX, maxY + kArrorHeight);
    CGContextAddLineToPoint(context, midX - kArrorHeight, maxY);
    
    CGContextAddArcToPoint(context, minX, maxY, minX, minY, radius);
    CGContextAddArcToPoint(context, minX, minX, maxX, minY, radius);
    CGContextAddArcToPoint(context, maxX, minY, maxX, maxX, radius);
    CGContextAddArcToPoint(context, maxX, maxY, midX, maxY, radius);
    
    CGContextClosePath(context);
}


@end
