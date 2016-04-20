/*
 *  MaplyMicelloMap.h
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

#import "Foundation/Foundation.h"
#import <WhirlyGlobeComponent.h>

@interface  MaplyMicelloMapEntity : NSObject

@property (readonly, nonatomic, assign) int entityID;
@property (readonly, nonatomic, strong) NSDictionary *_Nonnull properties;
@property (readonly, nonatomic, strong) NSString *_Nullable intAddress;
@property (readonly, nonatomic, assign) double lonDeg;
@property (readonly, nonatomic, assign) double latDeg;

@end

@interface  MaplyMicelloMapLevel : NSObject

@property (readonly, nonatomic, assign) int levelID;
@property (readonly, nonatomic, strong) NSString *_Nonnull name;
@property (readonly, nonatomic, assign) int zLevel;
@property (readonly, nonatomic, assign) bool isMain;
@property (readonly, nonatomic, strong) NSArray *_Nonnull features;

@end

@interface  MaplyMicelloMapDrawing : NSObject

@property (readonly, nonatomic, assign) int drawingID;
@property (readonly, nonatomic, assign) bool isRoot;
@property (readonly, nonatomic, strong) NSString *_Nonnull name;
@property (readonly, nonatomic, strong) NSString *_Nonnull displayName;
@property (readonly, nonatomic, strong) NSString *_Nonnull mapType;
@property (readonly, nonatomic, strong) NSDictionary *_Nonnull levels;
@property (readonly, nonatomic, strong) MaplyMicelloMapLevel *_Nullable mainLevel;

@end

@interface  MaplyMicelloStyleRule : NSObject

- (nullable instancetype)initWithKey:(NSString *__nonnull)key value:(NSObject *__nonnull)value desc:(NSDictionary *__nonnull)desc;

@property (nonatomic, strong) NSString *_Nonnull key;
@property (nonatomic, strong) NSObject *_Nonnull value;
@property (nonatomic, strong) NSDictionary *_Nonnull desc;

@end

@interface  MaplyMicelloMap : NSObject

@property (readonly, nonatomic, strong) NSDictionary *_Nonnull drawings;
@property (readonly, nonatomic, strong) MaplyMicelloMapDrawing *_Nullable rootDrawing;
@property (readonly, nonatomic, strong) NSDictionary *_Nonnull entities;
@property (readonly, nonatomic, assign) double centerLonDeg;
@property (readonly, nonatomic, assign) double centerLatDeg;
@property (readonly, nonatomic, strong) NSArray *_Nonnull zLevels;
@property (readonly, nonatomic, strong) NSDictionary *_Nonnull zLevelsToLevels;
@property (readonly, nonatomic, assign) int zLevel;

@property (nonatomic, strong) UIColor *_Nonnull fillColor;
@property (nonatomic, strong) UIColor *_Nonnull outlineColor;
@property (nonatomic, strong) UIColor *_Nonnull selectedOutlineColor;
@property (nonatomic, assign) float lineWidth;
@property (nonatomic, assign) float selectedLineWidth;


- (nullable instancetype)initWithBaseURL:(NSString *__nonnull)baseURL projectKey:(NSString *__nonnull)projectKey baseDrawPriority:(int)baseDrawPriority;

- (void)startFetchMapWithSuccess:(nonnull void (^)()) successBlock failure:(nullable void(^)(NSError *__nonnull error)) failureBlock;

- (void)addStyleRule:(MaplyMicelloStyleRule *__nonnull)styleRule;
- (void)addDefaultStyleRules;

- (void)setZLevel:(int)zLevel viewC:(MaplyBaseViewController *__nonnull)viewC;

- (MaplyMicelloMapEntity *__nullable)select:(NSObject *__nonnull) selectedObj viewC:(MaplyBaseViewController *__nonnull)viewC;

- (void)clearSelectionViewC:(MaplyBaseViewController *__nonnull)viewC;

@end
