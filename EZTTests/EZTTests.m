//
//  EZTTests.m
//  EZTTests
//
//  Created by ALLENMAC on 2014/6/22.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EZTService.h"

@interface EZTTests : XCTestCase

@end

@implementation EZTTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testServices {
	[EZTService reqNearByRestaurant:^(NSArray *results) {
		XCTAssertTrue([results isKindOfClass:[NSArray class]], @"results must be NSArray!");
	}];
}

@end
