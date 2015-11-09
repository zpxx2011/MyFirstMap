//
//  ViewController.m
//  HelloAMap2
//
//  Created by Devin on 15/11/5.
//  Copyright © 2015年 Devin. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "CustomAnnotationView.h"
#import "CustomCalloutView.h"


#define APIKey @"018051a0557dfee8326cfcc199cd9c28"



@interface ViewController ()<MAMapViewDelegate, AMapSearchDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) MAMapView *mapView; // 地图属性
// 创建一个按钮随时可以定位用户位置
@property (nonatomic, strong) UIButton *locationButton;


// 创建当前位置信息属性
@property (nonatomic, strong) CLLocation *currentLocation;
// 创建search
@property (nonatomic, strong) AMapSearchAPI *search;


// 创建annotations数组,放annotation
@property (nonatomic, strong) NSMutableArray *annotations;
// 创建搜索结果的poi数组
@property (nonatomic, strong) NSArray *pois;
// 创建展示的tableView
@property (nonatomic, strong) UITableView *tableView;


// 长按手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
// 添加目的地坐标
@property (nonatomic, strong) MAPointAnnotation *destinationPoint;
// 声明路径规划线路数组,polyline:地图覆盖物的一种
@property (nonatomic, strong) NSArray *pathPloylines;

// 声明一个导航管理对象
//@property (nonatomic, strong) AMapNaviManager *naviManager;
// 声明一个导航视图控制对象
//@property (nonatomic, strong) AMapNaviViewController *naviViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    // 显示地图
    [self initMapView];
    
    // 定位按钮
    [self initLocationButton];
    
    // 搜索服务
    [self initSearch];
    
    // 显示周边
    [self initAttributes];
    
    // tableView的初始化
    [self initTableView];
    
    // 导航管理的初始化
//    [self initNaviManager];
    
    // 导航视图控制器的初始化
//    [self initNaviViewController];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


#pragma mark ----- Init
// 初始化显示地图
- (void)initMapView{
    
    // 绑定创建的key
    [MAMapServices sharedServices].apiKey = APIKey;
    
    _mapView = [[MAMapView alloc] initWithFrame:(CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height * 0.5))];
    
    // 设置代理
    _mapView.delegate = self;
    // 设置罗盘
    _mapView.compassOrigin = CGPointMake(_mapView.compassOrigin.x, 22);
    // 设置比例尺
    _mapView.scaleOrigin = CGPointMake(_mapView.scaleOrigin.x, 22);
    
    [self.view addSubview:_mapView];
    
    // 显示的时候就定在了用户所在位置
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    // 显示用户的位置
    _mapView.showsUserLocation = YES;
}

// 初始化按钮
- (void)initLocationButton{
    
    _locationButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    _locationButton.frame = CGRectMake(20, _mapView.bounds.size.height - 80, 40, 40);
    _locationButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    _locationButton.backgroundColor = [UIColor whiteColor];
    _locationButton.layer.cornerRadius = 5;
    
    [_locationButton addTarget:self action:@selector(locateAction) forControlEvents:(UIControlEventTouchUpInside)];
    [_locationButton setImage:[UIImage imageNamed:@"location_no"] forState:(UIControlStateNormal)];
    
    [_mapView addSubview:_locationButton];
    
    // 添加搜索按钮
    UIButton *searchButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    searchButton.frame = CGRectMake(80, _mapView.bounds.size.height - 80, 40, 40);
    searchButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    searchButton.backgroundColor = [UIColor whiteColor];
    
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:(UIControlStateNormal)];
    [searchButton addTarget:self action:@selector(searchAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    [_mapView addSubview:searchButton];
    
    
    // 添加路线规划按钮
    UIButton *pathButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    pathButton.frame = CGRectMake(140, _mapView.bounds.size.height - 80, 40, 40);
    pathButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    pathButton.backgroundColor = [UIColor whiteColor];
    
    [pathButton addTarget:self action:@selector(pathAction) forControlEvents:(UIControlEventTouchUpInside)];
    [pathButton setImage:[UIImage imageNamed:@"path"] forState:(UIControlStateNormal)];
    
    [_mapView addSubview:pathButton];
    
    // 添加导航按钮
    UIButton *naviButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    naviButton.frame = CGRectMake(200, _mapView.bounds.size.height - 80, 40, 40);
    naviButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    naviButton.backgroundColor = [UIColor whiteColor];
    
    [naviButton addTarget:self action:@selector(naviAction) forControlEvents:(UIControlEventTouchUpInside)];
    [naviButton setTitle:@"导航" forState:(UIControlStateNormal)];
    
    
    [_mapView addSubview:naviButton];
}

// 初始化搜索服务
- (void)initSearch{
    
    // 必须设置APIKey
    [AMapSearchServices sharedServices].apiKey = APIKey;
    
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
}

// 初始化周边poi和annotation
- (void)initAttributes{
    
    _annotations = [NSMutableArray array];
    _pois = nil;
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _longPressGesture.delegate = self;
    [_mapView addGestureRecognizer:_longPressGesture];
}

// 初始化tableView
- (void)initTableView{
    
    CGFloat height = self.view.bounds.size.height * 0.5;
    
    _tableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, height, self.view.bounds.size.width, height)) style:(UITableViewStylePlain)];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

//// 初始化导航管理对象
//- (void)initNaviManager{
//    
//    if (_naviManager == nil) {
//        
//        _naviManager = [[AMapNaviManager alloc] init];
//        _naviManager.delegate = self;
//    }
//}
//
//// 初始化导航视图控制器
//- (void)initNaviViewController{
//    
//    if (_naviViewController == nil) {
//        
//        _naviViewController = [[AMapNaviViewController alloc] initWithMapView:self.mapView delegate:self];
//    }
//}





#pragma mark ----- Action
// 实现定位按钮方法
- (void)locateAction{
    
    if (_mapView.userTrackingMode != MAUserTrackingModeFollow) {
        
        [_mapView setUserTrackingMode:(MAUserTrackingModeFollow) animated:YES];
    }
}

// 逆地理编码,发起搜索请求
- (void)reGeoAction{
    
    if (_currentLocation) {
        
        // 将用户位置转给request
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
        
        // 进行逆地理编码
        [_search AMapReGoecodeSearch:request];
    }
}

- (void)reGeoAction1{
    
    if (_destinationPoint) {
        
        // 将用户位置转给request
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        request.location = [AMapGeoPoint locationWithLatitude:_destinationPoint.coordinate.latitude longitude:_destinationPoint.coordinate.longitude];
        
        // 进行逆地理编码
        [_search AMapReGoecodeSearch:request];
    }
}


// 搜索周边方法实现,发送请求
- (void)searchAction{
    
    if (_currentLocation == nil || _search == nil) {
        
        NSLog(@"search failed");
    }
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    
    request.keywords = @"餐饮";
    
    // 接收请求
    [_search AMapPOIAroundSearch:request];
}

// 路线规划实现
- (void)pathAction{
    
    if (_destinationPoint == nil || _currentLocation == nil || _search == nil) {
        
        NSLog(@"path search failed");
    }
    
    // 设置路径规划为步行路径
    AMapWalkingRouteSearchRequest *request = [[AMapWalkingRouteSearchRequest alloc] init];
    request.origin = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    request.destination = [AMapGeoPoint locationWithLatitude:_destinationPoint.coordinate.latitude longitude:_destinationPoint.coordinate.longitude];
    
    [_search AMapWalkingRouteSearch:request];
}

// 实现长按手势操作
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        // 将点击屏幕的坐标转换为经纬度坐标
        CLLocationCoordinate2D coordinate = [_mapView convertPoint:[gesture locationInView:_mapView] toCoordinateFromView:_mapView];
        
        // 添加标注,不为空的时候就要清理原有数据
        if (_destinationPoint != nil) {
            
            // 清理
            [_mapView removeAnnotation:_destinationPoint];
            _destinationPoint = nil;
        }
        
        // 初始化目的地
        _destinationPoint = [[MAPointAnnotation alloc] init];

        _destinationPoint.coordinate = coordinate;
        _destinationPoint.title = @"Destination";
        
        [_mapView addAnnotation:_destinationPoint];
    }
}

// 附近特色地点导航路线
- (void)GoThereAction{
    
    [self pathAction];
}

//// 开启导航
//- (void)naviAction{
//    
//    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
//    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:_destinationPoint.coordinate.latitude longitude:_destinationPoint.coordinate.longitude];
//    
//    NSArray *startPoints = @[startPoint];
//    NSArray *endPoints = @[endPoint];
//    
//    // 步行路径规划
//    [_naviManager calculateWalkRouteWithStartPoints:startPoints endPoints:endPoints];
//}



#pragma mark ----- mapView delegate
// 当用户调整地图时,追踪改变,进入mapView的代理方法,这时改变定位按钮的样式
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    
    // 修改定位按钮状态
    if (mode == MAUserTrackingModeNone) {
        
        [_locationButton setImage:[UIImage imageNamed:@"location_no"] forState:(UIControlStateNormal)];
    }else{
        
        [_locationButton setImage:[UIImage imageNamed:@"location_yes"] forState:(UIControlStateNormal)];
    }
}

// 更新用户位置信息,并返回位置信息,得到用户位置的经纬度
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
    _currentLocation = [userLocation.location copy];
}

// 选中用户位置annotation时弹出当前地址
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    
    // 选中定位annotation的时候进行逆地理编码
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
        
        [self reGeoAction];
    }
    
    if ([view.annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
        
        if ([view isKindOfClass:[CustomAnnotationView class]]) {
            
            if (_destinationPoint != nil) {
                
                // 清理
                [_mapView removeAnnotation:_destinationPoint];
                _destinationPoint = nil;
            }
            
            // 将选中地点的坐标传给目的地坐标,这样就可以绘制线路了
            _destinationPoint = [[MAPointAnnotation alloc] init];
            _destinationPoint.coordinate = view.annotation.coordinate;
            
            CustomAnnotationView *customView = (CustomAnnotationView *)view;
            [customView.calloutView.GoButton addTarget:self action:@selector(GoThereAction) forControlEvents:(UIControlEventTouchUpInside)];
        }
        
        
        
        [self reGeoAction1];
    }
}

// 地图询问对应的annotation
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    
    if (annotation == _destinationPoint) {
        
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"destination"];
        if (annotationView == nil) {
            
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"destination"];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        return annotationView;
    }
    
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
        if (annotationView == nil) {
            
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        }
        
        annotationView.canShowCallout = NO;
        
        annotationView.image = [UIImage imageNamed:@"restaurant"];
        annotationView.centerOffset = CGPointMake(0, -18);
        
        
        
        return annotationView;
    }
    
    return nil;
}

// 对polyline进行回调
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth = 4;
        polylineView.strokeColor = [UIColor magentaColor];
        
        return polylineView;
    }
    
    return nil;
}




#pragma mark ---- AMapSearch delegate
// 逆地理编码,搜索回调
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    
    NSLog(@"request:%@, error:%@", request, error);
}
// 逆编码完成,返回结果进行赋值
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    
    
    NSString *cityName = response.regeocode.addressComponent.city;
    if (cityName.length == 0) {
        
        cityName = response.regeocode.addressComponent.province;
    }
    
    _mapView.userLocation.title = cityName;
    _mapView.userLocation.subtitle = response.regeocode.formattedAddress;
    
    _destinationPoint.title = cityName;
    _destinationPoint.subtitle = response.regeocode.formattedAddress;
}

// 搜索完成回调
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    
    if (response.pois.count > 0) {
        
        _pois = response.pois;
        
        [_tableView reloadData];
        
        // 清空标注
        [_mapView removeAnnotations:_annotations];
        [_annotations removeAllObjects];
    }
}

// 路径规划方法实现,接收到请求,进行回调
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    
    if (response.count > 0) {
        
        [_mapView removeOverlays:_pathPloylines];
        _pathPloylines = nil;
        
        // 只显示一条
        _pathPloylines = [self polylinesForPath:response.route.paths[0]];
        [_mapView addOverlays:_pathPloylines];
        
        [_mapView showAnnotations:@[_destinationPoint, _mapView.userLocation] animated:YES];
    }
}


#pragma mark --- 对polyline进行解析
- (NSArray *)polylinesForPath:(AMapPath *)path{
    
    if (path == nil || path.steps.count == 0) {
        
        return nil;
    }
    
    NSMutableArray *polylines = [NSMutableArray array];
    
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop){
        
        NSUInteger count = 0;
        CLLocationCoordinate2D *coordinates = [self coordinatesForString:step.polyline coordinateCount:&count parseToken:@";"];
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
        [polylines addObject:polyline];
        
        free(coordinates), coordinates = NULL;
    }];
    
    return polylines;
}

// 字符串解析
- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string coordinateCount:(NSUInteger *)coordinateCount parseToken:(NSString *)token{
    
    if (string == nil) {
        
        return NULL;
    }
    if (token == nil) {
        
        token = @",";
    }
    
    NSString *str = @"";
    
    if (![token isEqualToString:@","]) {
        
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }else{
        
        str = [NSString stringWithString:string];
    }
    
    NSArray *componennts = [str componentsSeparatedByString:@","];
    NSUInteger count = [componennts count] / 2;
    
    if (coordinateCount != NULL) {
        
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(count *sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i ++) {
        
        coordinates[i].longitude = [[componennts objectAtIndex:2 * i] doubleValue];
        coordinates[i].latitude = [[componennts objectAtIndex:2 * i + 1] doubleValue];
    }
    
    return coordinates;
}




#pragma mark ---- tableView delegate,dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _pois.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
    }
    
    AMapPOI *poi = _pois[indexPath.row];
    
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = poi.address;
    cell.tag = 10000;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.tag == 10000) {
        
        // 为点击的poi点添加标注
        AMapPOI *poi = _pois[indexPath.row];
        
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        
        annotation.title = poi.name;
        annotation.subtitle = poi.address;
        
        [_annotations addObject:annotation];
        [_mapView addAnnotation:annotation];
        
        cell.tag = 10001;
    }
    
}


#pragma mark --- navigation delegate
//// 路径规划成功的回调函数
//- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager{
//    
//    // 导航视图展示
//    [_naviManager presentNaviViewController:_naviViewController animated:YES];
//}
//
//// 导航视图被展示出来的回调函数
//- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController{
//    
//    [super navigationController];
//    
//    [_naviManager startGPSNavi];
//}


@end
