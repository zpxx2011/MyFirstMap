//
//  CustomAnnotationView.h
//  HelloAMap2
//
//  Created by Devin on 15/11/6.
//  Copyright © 2015年 Devin. All rights reserved.
//

#import <AMapNaviKit/AMapNaviKit.h>
//#import <MAMapKit/MAMapKit.h>
@class CustomCalloutView;


@interface CustomAnnotationView : MAAnnotationView

// 气泡视图
@property (nonatomic, strong) CustomCalloutView *calloutView;


@end
