//
//  CustomCalloutView.h
//  HelloAMap2
//
//  Created by Devin on 15/11/6.
//  Copyright © 2015年 Devin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCalloutView : UIView

// 气泡上的控件属性
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;

@property (nonatomic, strong) UIButton *GoButton;


@end
