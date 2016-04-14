//
//  ViewController.m
//  WhirlyGlobeMicelloDemo
//
//  Created by Ranen Ghosh on 2016-04-14.
//  Copyright © 2016 Ranen Ghosh. All rights reserved.
//

#import "ViewController.h"
#import "MaplyMicelloMap.h"

@interface ViewController ()

@end

@implementation ViewController
{
    WhirlyGlobeViewController *globeVC;
    MaplyComponentObject *bgObj, *fgObj;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an empty globe and add it to the view
    globeVC = [[WhirlyGlobeViewController alloc] init];
    [self.view addSubview:globeVC.view];
    globeVC.view.frame = self.view.bounds;
    [self addChildViewController:globeVC];
    
    [globeVC setPosition:MaplyCoordinateMakeWithDegrees(-121.942508,37.325095) height:0.0002];
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  objectAtIndex:0];
    NSString *thisCacheDir = [NSString stringWithFormat:@"%@/osmtiles/",cacheDir];
    int maxZoom = 18;
    MaplyRemoteTileSource *tileSource = [[MaplyRemoteTileSource alloc] initWithBaseURL:@"http://otile1.mqcdn.com/tiles/1.0.0/osm/" ext:@"png" minZoom:0 maxZoom:maxZoom];
    tileSource.cacheDir = thisCacheDir;
    MaplyQuadImageTilesLayer *layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    layer.drawPriority = 100;
    layer.handleEdges = true;
    [globeVC addLayer:layer];
    
    NSString *micelloKey = @""; // Insert your Micello project key here.
    NSString *baseURL = @"http://mfs.micello.com/ms/v1/mfile/map/78/mv/-/ev/-/geojson";
    MaplyMicelloMap *micelloMap = [[MaplyMicelloMap alloc] initWithBaseURL:baseURL projectKey:micelloKey];
    
    [micelloMap startFetchMapWithSuccess:^() {
        if (micelloMap.rootDrawing && micelloMap.rootDrawing.mainLevel) {
            [micelloMap startFetchLevel:micelloMap.rootDrawing.mainLevel success:^(MaplyMicelloMapLevel * _Nullable level) {
                
                NSDictionary *desc = @{
                                       kMaplyColor:         [UIColor whiteColor],
                                       kMaplyDrawPriority:  @(200),
                                       kMaplyFilled:        @(YES)
                                       };
                bgObj = [globeVC addVectors:level.features desc:desc];
                
                desc = @{
                         kMaplyColor:           [UIColor blackColor],
                         kMaplyDrawPriority:    @(300),
                         kMaplyFilled:          @(NO),
                         kMaplyVecWidth:        @(3.0)
                         };
                
                fgObj = [globeVC addVectors:level.features desc:desc];
                
            } failure:^(NSError * _Nonnull error) {
            }];
        }
    } failure:^(NSError * _Nonnull error) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
