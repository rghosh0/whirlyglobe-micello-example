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

@interface  MaplyMicelloMapEntity : NSObject

@property (nonatomic, assign) int entityID;
@property (nonatomic, strong) NSDictionary *properties;

@end

@interface  MaplyMicelloMapLevel : NSObject

@property (nonatomic, assign) int levelID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int zLevel;
@property (nonatomic, assign) bool isMain;

@property (nonatomic, strong) NSArray *features;

@end


@interface  MaplyMicelloMapDrawing : NSObject

@property (nonatomic, assign) int drawingID;
@property (nonatomic, assign) bool isRoot;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *mapType;

@property (nonatomic, strong) NSDictionary *levels;
@property (nonatomic, strong) MaplyMicelloMapLevel *mainLevel;

@end



@interface  MaplyMicelloMap : NSObject

@property (nonatomic, strong) NSDictionary *drawings;
@property (nonatomic, strong) MaplyMicelloMapDrawing *rootDrawing;
@property (nonatomic, strong) NSDictionary *entities;

- (nullable instancetype)initWithBaseURL:(NSString *__nonnull)baseURL projectKey:(NSString *__nonnull)projectKey;

- (void)startFetchMapWithSuccess:(nonnull void (^)()) successBlock failure:(nullable void(^)(NSError *__nonnull error)) failureBlock;

- (void)startFetchLevel:(MaplyMicelloMapLevel *__nonnull)level success:(nonnull void (^)(MaplyMicelloMapLevel *__nullable level)) successBlock failure:(nullable void(^)(NSError *__nonnull error)) failureBlock;

@end
