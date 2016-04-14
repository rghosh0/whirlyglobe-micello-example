/*
 *  MaplyMicelloMap.m
 *  WhirlyGlobe-MaplyComponent
 *
 *  Created by Ranen Ghosh on 4/12/16.
 *  Copyright 2011-2016 mousebird consulting
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#import "MaplyMicelloMap.h"
#import "MaplyVectorObject.h"

@implementation MaplyMicelloMapEntity

@end



@implementation MaplyMicelloMapLevel

@end

@implementation MaplyMicelloMapDrawing

@end


@implementation MaplyMicelloMap {
    NSString *_baseURL;
    NSString *_projectKey;
    

    NSDictionary *_drawings;
    MaplyMicelloMapDrawing *_rootDrawing;
    
    NSDictionary *_entities;
    
    
}

- (nullable instancetype)initWithBaseURL:(NSString *__nonnull)baseURL projectKey:(NSString *__nonnull)projectKey {
    
    self = [super init];
    if (!self)
        return nil;
    
    _baseURL = baseURL;
    _projectKey = projectKey;
    
    return self;
}

- (void)startFetchMapWithSuccess:(nonnull void (^)()) successBlock failure:(nullable void(^)(NSError *__nonnull error)) failureBlock {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *comMapURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/com-map?key=%@", _baseURL, _projectKey]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:comMapURL completionHandler:
        ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            ^{
                NSError *jsonError;
                NSDictionary *comMapDict;
                if (!error)
                    comMapDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!error && !jsonError) {
                    // Assign drawings and levels
                    NSArray *rawDrawings = comMapDict[@"drawings"];
                    NSMutableDictionary *drawings = [NSMutableDictionary dictionary];
                    MaplyMicelloMapDrawing *rootDrawing;
                    for (NSDictionary *rawDrawing in rawDrawings) {
                        MaplyMicelloMapDrawing *drawing = [[MaplyMicelloMapDrawing alloc] init];
                        drawing.drawingID = ((NSNumber *)rawDrawing[@"id"]).intValue;
                        NSDictionary *dProperties = rawDrawing[@"properties"];
                        if (dProperties[@"is_root"] && ((NSNumber *)dProperties[@"is_root"]).boolValue) {
                            drawing.isRoot = true;
                            rootDrawing = drawing;
                        }
                        drawing.name = (NSString *)dProperties[@"name"];
                        drawing.displayName = (NSString *)dProperties[@"display_name"];
                        drawing.mapType = (NSString *)dProperties[@"map_type"];
                        
                        drawings[@(drawing.drawingID)] = drawing;
                        
                        NSArray *rawLevels = rawDrawing[@"levels"];
                        NSMutableDictionary *levels = [NSMutableDictionary dictionary];
                        for (NSDictionary *rawLevel in rawLevels) {
                            MaplyMicelloMapLevel *level = [[MaplyMicelloMapLevel alloc] init];
                            level.levelID = ((NSNumber *)rawLevel[@"id"]).intValue;
                            NSDictionary *lProperties = rawLevel[@"properties"];
                            level.name = (NSString *)lProperties[@"name"];
                            level.zLevel = ((NSNumber *)lProperties[@"zlevel"]).intValue;
                            if (lProperties[@"main"] && ((NSNumber *)lProperties[@"main"]).boolValue) {
                                level.isMain = true;
                                drawing.mainLevel = level;
                            }
                            
                            levels[@(level.levelID)] = level;
                        }
                        drawing.levels = [NSDictionary dictionaryWithDictionary:levels];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.drawings = [NSDictionary dictionaryWithDictionary:drawings];
                        self.rootDrawing = rootDrawing;
                        [self startFetchEntitiesWithSuccess:successBlock failure:failureBlock];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock([[NSError alloc] initWithDomain:@"MaplyMicelloMap" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Failed to fetch community map JSON file."}]);
                });
            }
        });
    }];
    [task resume];
}

- (void)startFetchEntitiesWithSuccess:(nonnull void (^)()) successBlock failure:(nullable void(^)(NSError *__nonnull error)) failureBlock {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *comEntitiesURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/com-entity?key=%@", _baseURL, _projectKey]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:comEntitiesURL completionHandler:
        ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            ^{
                NSError *jsonError;
                NSDictionary *comEntityDict;
                if (!error)
                    comEntityDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!error && !jsonError) {
                    
                    NSArray *rawEntities = comEntityDict[@"entities"];
                    NSMutableDictionary *entities = [NSMutableDictionary dictionary];
                    for (NSDictionary *rawEntity in rawEntities) {
                        MaplyMicelloMapEntity *entity = [[MaplyMicelloMapEntity alloc] init];
                        entity.entityID = ((NSNumber *)rawEntity[@"id"]).intValue;
                        entity.properties = rawEntity[@"properties"];
                        entities[@(entity.entityID)] = entity;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.entities = [NSDictionary dictionaryWithDictionary:entities];
                        successBlock();
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock([[NSError alloc] initWithDomain:@"MaplyMicelloMap" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Failed to fetch community entity JSON file."}]);
                });
            }
        });
    }];
    [task resume];
}


- (void)startFetchLevel:(MaplyMicelloMapLevel *__nonnull)level success:(nonnull void (^)(MaplyMicelloMapLevel *__nullable level)) successBlock failure:(nullable void(^)(NSError *__nonnull error)) failureBlock {
    
    if (level.features) {
        successBlock(level);
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *comEntitiesURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/geojson-level-geom/%i?key=%@", _baseURL, level.levelID, _projectKey]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:comEntitiesURL completionHandler:
        ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            if (!error && data) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                ^{
                    MaplyVectorObject *vecObj = [MaplyVectorObject VectorObjectFromGeoJSON:data];
                    NSArray *features = [vecObj splitVectors];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        level.features = features;
                        successBlock(level);
                    });
                });
            } else {
                failureBlock([[NSError alloc] initWithDomain:@"MaplyMicelloMap" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Failed to fetch level GeoJSON file."}]);
            }
    }];
    [task resume];
}


@end
