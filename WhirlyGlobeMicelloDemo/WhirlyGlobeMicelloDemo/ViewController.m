//
//  ViewController.m
//  WhirlyGlobeMicelloDemo
//
//  Created by Ranen Ghosh on 2016-04-14.
//  Copyright 2011-2016 mousebird consulting
//

#import "ViewController.h"
#import "MaplyMicelloMap.h"
#import "SimpleAnnotationViewController.h"

@implementation ViewController
{
    WhirlyGlobeViewController *globeVC;
    
    MaplyMicelloMap *micelloMap;
    UISegmentedControl *segCtrl;
    MaplyComponentObject *sanJoseCompObj, *santaClaraCompObj;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an empty globe and add it to the view
    globeVC = [[WhirlyGlobeViewController alloc] init];
    globeVC.delegate = self;
    [self.view addSubview:globeVC.view];
    globeVC.view.frame = self.view.bounds;
    [self addChildViewController:globeVC];
    
    // Add OpenStreetMap basemap
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  objectAtIndex:0];
    MaplyRemoteTileSource *tileSource = [[MaplyRemoteTileSource alloc] initWithBaseURL:@"http://otile1.mqcdn.com/tiles/1.0.0/osm/" ext:@"png" minZoom:0 maxZoom:18];
    tileSource.cacheDir = [NSString stringWithFormat:@"%@/osmtiles/",cacheDir];
    MaplyQuadImageTilesLayer *layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    layer.drawPriority = 100;
    layer.handleEdges = true;
    [globeVC addLayer:layer];
    
    // Add Santa Clara county boundary
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SantaClaraBoundary" ofType:@"geojson"];
    MaplyVectorObject *santaClaraVecObj = [MaplyVectorObject VectorObjectFromGeoJSON:[[NSFileManager defaultManager] contentsAtPath:path]];
    santaClaraCompObj = [globeVC addVectors:@[santaClaraVecObj] desc:@{
                                                               kMaplyVecTexture:    [UIImage imageNamed:@"bgYellow.png"],
                                                               kMaplyDrawPriority:  @(400),
                                                               kMaplyFilled:        @(YES)}];
    
    // Add San Jose boundary
    path = [[NSBundle mainBundle] pathForResource:@"SanJoseBoundary" ofType:@"geojson"];
    MaplyVectorObject *sanJoseVecObj = [MaplyVectorObject VectorObjectFromGeoJSON:[[NSFileManager defaultManager] contentsAtPath:path]];
    sanJoseCompObj = [globeVC addVectors:@[sanJoseVecObj] desc:@{
                                                           kMaplyVecTexture:    [UIImage imageNamed:@"bgBlue.png"],
                                                           kMaplyDrawPriority:  @(500),
                                                           kMaplyFilled:        @(YES)}];
    
    // Add Westfield Valley Fair mall map
    NSString *micelloKey = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"micelloKey" ofType:nil] encoding:NSASCIIStringEncoding error:nil];
    micelloKey = [micelloKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *baseURL = @"http://mfs.micello.com/ms/v1/mfile/map/78/mv/-/ev/-/geojson";
    micelloMap = [[MaplyMicelloMap alloc] initWithBaseURL:baseURL projectKey:micelloKey baseDrawPriority:200];
    
    [micelloMap startFetchMapWithSuccess:^() {
        [micelloMap addDefaultStyleRules];
        [globeVC setPosition:MaplyCoordinateMakeWithDegrees(micelloMap.centerLonDeg, micelloMap.centerLatDeg) height:0.0001];
        
        // Add a segmented control to support switching between map levels.
        if (micelloMap.zLevels.count>1) {
            segCtrl = [[UISegmentedControl alloc] initWithItems:[micelloMap.zLevels valueForKey:@"stringValue"]];
            segCtrl.selectedSegmentIndex = 0;
            segCtrl.frame = CGRectMake(20, 20, 120, 40);
            [segCtrl addTarget:self action:@selector(onSegChange) forControlEvents:UIControlEventValueChanged];
            [globeVC.view addSubview:segCtrl];
        }
        
        if (micelloMap.zLevels.count>0)
            [micelloMap setZLevel:((NSNumber *)micelloMap.zLevels[0]).intValue viewC:globeVC];
        
    } failure:^(NSError * _Nonnull error) {
    }];
}

- (void)onSegChange {
    int zLevel = ((NSNumber *)micelloMap.zLevels[segCtrl.selectedSegmentIndex]).intValue;
    [micelloMap setZLevel:zLevel viewC:globeVC];
}

- (void)globeViewController:(WhirlyGlobeViewController *__nonnull)viewC didSelect:(NSObject *__nonnull)selectedObj {
    
    MaplyMicelloMapEntity *entity = [micelloMap select:selectedObj viewC:viewC];
    if (!entity)
        return;
    
    MaplyAnnotation *annotate = [[MaplyAnnotation alloc] init];
    SimpleAnnotationViewController *svc = [[SimpleAnnotationViewController alloc] initWithName:entity.properties[@"name"] desc:entity.properties[@"description"] hours:entity.properties[@"hours"] location:entity.intAddress phone:entity.properties[@"phone"] website:entity.properties[@"url"]];
    
    // superview needed for Auto Layout and SMCalloutView (used in MaplyAnnotation) to play nice together.
    // https://github.com/nfarina/calloutview/issues/73
    UIView *superview = [[UIView alloc]initWithFrame:svc.view.frame];
    [superview addSubview:svc.view];
    annotate.contentView = superview;
    
    [globeVC clearAnnotations];
    [globeVC addAnnotation:annotate forPoint:MaplyCoordinateMakeWithDegrees(entity.lonDeg, entity.latDeg) offset:CGPointZero];
}

- (void)globeViewController:(WhirlyGlobeViewController *__nonnull)viewC didTapAt:(WGCoordinate)coord {
    [micelloMap clearSelectionViewC:viewC];
    [globeVC clearAnnotations];
}

@end
