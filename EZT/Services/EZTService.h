//
//  EZTService.h
//  EZT
//
//  Created by ALLENMAC on 2014/6/22.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

typedef void(^ResultsBlock)(NSArray *results);

#define name_KEY          @"name"
#define restaurant_id_KEY @"restaurant_id"
#define latlng_KEY        @"latlng"
#define avg_price_KEY     @"avg_price"
#define thumbURL_KEY      @"thumb1" //thumb1 or thumb1_mini


#import <Foundation/Foundation.h>

@interface EZTService : NSObject

+ (void)reqNearByRestaurants:(ResultsBlock)completion;
+ (void)reqNearByRestaurantsWithStart:(NSUInteger)start andN:(NSUInteger)n completion:(ResultsBlock)completion;

+ (NSUInteger)defaultPageLimits;
+ (NSString *)fullURLFromThumbKey:(NSString *)key;

+ (void)handleError:(NSError *)error;

@end
