//
//  EZTService.m
//  EZT
//
//  Created by ALLENMAC on 2014/6/22.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#define DocDir			[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#import "EZTService.h"
#import <PromiseKit/PromiseKit.h>
#import <SDWebImage/SDWebImageManager.h>
#import <Tweaks/FBTweakInline.h>

@implementation EZTService

+ (NSString *)serverURL {
	return APITweakValue(@"ServerURL", @"http://api-dev.eztable.com/v2/");
}

+ (void)reqNearByRestaurants:(ResultsBlock)completion {
    NSUInteger start = [APITweakValue(@"params_start", @"0") integerValue];
    NSUInteger n     = [self defaultPageLimits];
	[self reqNearByRestaurantsWithStart:start andN:n completion:completion];
}

+ (void)reqNearByRestaurantsWithStart:(NSUInteger)start andN:(NSUInteger)n completion:(ResultsBlock)completion {
	NSArray __block *results = @[];

	void (^ready)(id) = ^(id resultsDic){
		results = [self _parseNearByRestaurant:resultsDic];
		if (completion) {
			completion(results);
		}
	};
		
	id resultsDic = [self _stubDic];
	if (resultsDic) {
		ready(resultsDic);

	}else	{
		
		dispatchMain(^{	//CLLocationManager runs in Main
			[CLLocationManager promise].then(^(CLLocation *currentUserLocation){
				//			id lat = @(25.038274);		id lon = @(121.547862);	//25.038274 , 121.547862
				id lat = @(currentUserLocation.coordinate.latitude);
				id lon = @(currentUserLocation.coordinate.longitude);
				NSString *strURL = [NSString stringWithFormat:@"%@search/search_restaurant_by_latlng/%@/%@/", [self serverURL], lat, lon];
				return strURL;
				
			}).then(^(NSString *strURL){
				// go to background
				return dispatch_promise(^{
					id params =
					@{@"start" : NSStringFromInt(start),
					  @"n" : NSStringFromInt(n),
					  @"fields" : APITweakValue(@"params_fields", @"restaurant_id,name,min_price,max_price,avg_price,thumb1,thumb1_mini"),	//thumb1 or thumb1_mini
					  @"fq" : APITweakValue(@"params_fq", @"avg_price:[300 TO *]")
					  };
					NSLog(@"LOG:  params: %@",params);
					return [NSURLConnection GET:strURL query:params];
				}).then(^(id json){
					ready(json);
				}).catch(^(NSError *error){
					[self handleError:error];
					if (completion) {
						completion(nil);
					}
				});
			});
		});
	}
}

+ (NSUInteger)defaultPageLimits	{
	return [APITweakValue(@"params_n", @"10") integerValue];
}

+ (NSString *)fullURLFromThumbKey:(NSString *)key {
	if (key) {
		return [[NSString stringWithFormat:@"http://www.eztable.com.tw%@", key] urlEncodeUsingEncoding:NSUTF8StringEncoding];
	}
	return @"";
}

/* 若回傳結果status不等於OK，則還會有以下欄位表示錯誤訊息 {
 status: "EZParameterException"
 message: "restaurant does not existed"
 code: 0
 detail: null
 } */
+ (NSArray *)_parseNearByRestaurant:(id)jsonDic {
	if (!jsonDic) {
		return nil;
	}else if ([self _isOK:jsonDic]) {
		return jsonDic[@"data"][@"docs"];
	}else {
		id message = jsonDic[@"message"];
		id code = jsonDic[@"code"];
		// TODO: error message from server
		return @[];
	}
}

+ (BOOL)_isOK:(id)jsonDic	{
	return [jsonDic[@"status"] isEqualToString:@"OK"];
}

+ (void)handleError:(NSError *)error {
	NSLog(@"LOG:  error: %@",error);
	[TSMessage showNotificationWithTitle:error.localizedDescription type:(TSMessageNotificationTypeError)];
}

+ (id)_stubDic {

	if (!DebugTweakValue(@"Use stub restaurants", YES)) {
		return nil;
	}
//	NSString *strJson = @"{\n\t\"data\": {\n\t\t\"docs\": [\n\t\t\t{\n\t\t\t\t\"avg_price\": 2600,\n\t\t\t\t\"latlng\": \"25.040053,121.548127\",\n\t\t\t\t\"max_price\": 4000,\n\t\t\t\t\"min_price\": 1200,\n\t\t\t\t\"name\": \"松露之家 Maison de la Truffe \",\n\t\t\t\t\"restaurant_id\": 1320,\n\t\t\t\t\"score\": 0.19960947,\n\t\t\t\t\"thumb1\": \"/imgs/data1/1351075734_Maison.jpg\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/1351075734_Maison.jpg\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"avg_price\": 575,\n\t\t\t\t\"latlng\": \"25.040224,121.547877\",\n\t\t\t\t\"max_price\": 800,\n\t\t\t\t\"min_price\": 350,\n\t\t\t\t\"name\": \"Dearlicious 愛笛兒精緻熟食店\",\n\t\t\t\t\"restaurant_id\": 1958,\n\t\t\t\t\"score\": 0.21683568,\n\t\t\t\t\"thumb1\": \"/imgs/data1/1392017046_main2.jpg\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/1392017046_main2.jpg\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"avg_price\": 1329,\n\t\t\t\t\"latlng\": \"25.039759,121.549743\",\n\t\t\t\t\"max_price\": 1723,\n\t\t\t\t\"min_price\": 935,\n\t\t\t\t\"name\": \"紅廚PastaWestEast\",\n\t\t\t\t\"restaurant_id\": 868,\n\t\t\t\t\"score\": 0.25135013,\n\t\t\t\t\"thumb1\": \"/imgs/data1/red.png\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/red.png\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"avg_price\": 550,\n\t\t\t\t\"latlng\": \"25.036151,121.546999\",\n\t\t\t\t\"max_price\": 600,\n\t\t\t\t\"min_price\": 500,\n\t\t\t\t\"name\": \"KIKI - 東豐店\",\n\t\t\t\t\"restaurant_id\": 1951,\n\t\t\t\t\"score\": 0.25156906,\n\t\t\t\t\"thumb1\": \"/imgs/data1/1389761292_東豐4 (2) (1).JPG\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/1389761292_%E6%9D%B1%E8%B1%904%20%282%29%20%281%29.JPG\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"avg_price\": 550,\n\t\t\t\t\"latlng\": \"25.040202,121.5493304\",\n\t\t\t\t\"max_price\": 800,\n\t\t\t\t\"min_price\": 300,\n\t\t\t\t\"name\": \" Mia Patisserie 米兒法式甜點\",\n\t\t\t\t\"restaurant_id\": 1957,\n\t\t\t\t\"score\": 0.26047054,\n\t\t\t\t\"thumb1\": \"/imgs/data1/1390454706_MIA PATISSERIE2.jpg\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/1390454706_MIA%20PATISSERIE2.jpg\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"avg_price\": 525,\n\t\t\t\t\"latlng\": \"25.036081,121.549841\",\n\t\t\t\t\"max_price\": 800,\n\t\t\t\t\"min_price\": 250,\n\t\t\t\t\"name\": \"Bianco Taipei 義大利食材餐廳\",\n\t\t\t\t\"restaurant_id\": 1844,\n\t\t\t\t\"score\": 0.31498334,\n\t\t\t\t\"thumb1\": \"/imgs/data1/1381120762_bianco.jpg\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/1381120762_bianco.jpg\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"avg_price\": 1440,\n\t\t\t\t\"latlng\": \"25.041079,121.546895\",\n\t\t\t\t\"max_price\": 2000,\n\t\t\t\t\"min_price\": 880,\n\t\t\t\t\"name\": \"Façön 法熊法式餐廳\",\n\t\t\t\t\"restaurant_id\": 1503,\n\t\t\t\t\"score\": 0.32676232,\n\t\t\t\t\"thumb1\": \"/imgs/data1/1356337798_20121211-_DSC9160南港sg.JPG\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/1356337798_20121211-_DSC9160%E5%8D%97%E6%B8%AFsg.JPG\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"avg_price\": 648,\n\t\t\t\t\"latlng\": \"25.0382558,121.5445359\",\n\t\t\t\t\"max_price\": 776,\n\t\t\t\t\"min_price\": 520,\n\t\t\t\t\"name\": \"FIFI茶酒沙龍-常玉廳\",\n\t\t\t\t\"restaurant_id\": 1014,\n\t\t\t\t\"score\": 0.33509594,\n\t\t\t\t\"thumb1\": \"/imgs/data1/fifi2.jpg\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/fifi2.jpg\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"avg_price\": 718,\n\t\t\t\t\"latlng\": \"25.0382558,121.5445359\",\n\t\t\t\t\"max_price\": 915,\n\t\t\t\t\"min_price\": 521,\n\t\t\t\t\"name\": \"FIFI茶酒沙龍-W Lounge Bar\",\n\t\t\t\t\"restaurant_id\": 1015,\n\t\t\t\t\"score\": 0.33509594,\n\t\t\t\t\"thumb1\": \"/imgs/data1/FiFiWBar.jpg\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/FiFiWBar.jpg\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"avg_price\": 529,\n\t\t\t\t\"latlng\": \"25.0382558,121.5445359\",\n\t\t\t\t\"max_price\": 663,\n\t\t\t\t\"min_price\": 394,\n\t\t\t\t\"name\": \"FIFI茶酒沙龍-Khaki Caf\'e\",\n\t\t\t\t\"restaurant_id\": 1016,\n\t\t\t\t\"score\": 0.33509594,\n\t\t\t\t\"thumb1\": \"/imgs/data1/fifi 1F.jpg\",\n\t\t\t\t\"thumb1_mini\": \"/imgs/data1_240/fifi%201F.jpg\"\n\t\t\t}\n\t\t],\n\t\t\"numFound\": 452,\n\t\t\"start\": 0\n\t},\n\t\"status\": \"OK\"\n}";
	NSString *strJson = @"{\"status\":\"OK\",\"data\":{\"numFound\":452,\"start\":0,\"docs\":[{\"restaurant_id\":1320,\"name\":\"\\u677e\\u9732\\u4e4b\\u5bb6 Maison de la Truffe \",\"min_price\":1200,\"max_price\":4000,\"avg_price\":2600,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1351075734_Maison.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1351075734_Maison.jpg\",\"latlng\":\"25.040053,121.548127\",\"score\":0.19960947},{\"restaurant_id\":1958,\"name\":\"Dearlicious \\u611b\\u7b1b\\u5152\\u7cbe\\u7dfb\\u719f\\u98df\\u5e97\",\"min_price\":350,\"max_price\":800,\"avg_price\":575,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1392017046_main2.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1392017046_main2.jpg\",\"latlng\":\"25.040224,121.547877\",\"score\":0.21683568},{\"restaurant_id\":868,\"name\":\"\\u7d05\\u5edaPastaWestEast\",\"min_price\":935,\"max_price\":1723,\"avg_price\":1329,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/red.png\",\"thumb1\":\"\\/imgs\\/data1\\/red.png\",\"latlng\":\"25.039759,121.549743\",\"score\":0.25135013},{\"restaurant_id\":1951,\"name\":\"KIKI - \\u6771\\u8c50\\u5e97\",\"min_price\":500,\"max_price\":600,\"avg_price\":550,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1389761292_%E6%9D%B1%E8%B1%904%20%282%29%20%281%29.JPG\",\"thumb1\":\"\\/imgs\\/data1\\/1389761292_\\u6771\\u8c504 (2) (1).JPG\",\"latlng\":\"25.036151,121.546999\",\"score\":0.25156906},{\"restaurant_id\":1957,\"name\":\" Mia Patisserie \\u7c73\\u5152\\u6cd5\\u5f0f\\u751c\\u9ede\",\"min_price\":300,\"max_price\":800,\"avg_price\":550,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1390454706_MIA%20PATISSERIE2.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1390454706_MIA PATISSERIE2.jpg\",\"latlng\":\"25.040202,121.5493304\",\"score\":0.26047054},{\"restaurant_id\":1844,\"name\":\"Bianco Taipei \\u7fa9\\u5927\\u5229\\u98df\\u6750\\u9910\\u5ef3\",\"min_price\":250,\"max_price\":800,\"avg_price\":525,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1381120762_bianco.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1381120762_bianco.jpg\",\"latlng\":\"25.036081,121.549841\",\"score\":0.31498334},{\"restaurant_id\":1503,\"name\":\"Fa\\u00e7\\u00f6n \\u6cd5\\u718a\\u6cd5\\u5f0f\\u9910\\u5ef3\",\"min_price\":880,\"max_price\":2000,\"avg_price\":1440,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1356337798_20121211-_DSC9160%E5%8D%97%E6%B8%AFsg.JPG\",\"thumb1\":\"\\/imgs\\/data1\\/1356337798_20121211-_DSC9160\\u5357\\u6e2fsg.JPG\",\"latlng\":\"25.041079,121.546895\",\"score\":0.32676232},{\"restaurant_id\":1014,\"name\":\"FIFI\\u8336\\u9152\\u6c99\\u9f8d-\\u5e38\\u7389\\u5ef3\",\"min_price\":520,\"max_price\":776,\"avg_price\":648,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/fifi2.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/fifi2.jpg\",\"latlng\":\"25.0382558,121.5445359\",\"score\":0.33509594},{\"restaurant_id\":1015,\"name\":\"FIFI\\u8336\\u9152\\u6c99\\u9f8d-W Lounge Bar\",\"min_price\":521,\"max_price\":915,\"avg_price\":718,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/FiFiWBar.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/FiFiWBar.jpg\",\"latlng\":\"25.0382558,121.5445359\",\"score\":0.33509594},{\"restaurant_id\":1016,\"name\":\"FIFI\\u8336\\u9152\\u6c99\\u9f8d-Khaki Caf\'e\",\"min_price\":394,\"max_price\":663,\"avg_price\":529,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/fifi%201F.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/fifi 1F.jpg\",\"latlng\":\"25.0382558,121.5445359\",\"score\":0.33509594},{\"restaurant_id\":1173,\"name\":\"\\u6d77\\u58fd\\u53f8(\\u5fe0\\u5b5d\\u5e97)\",\"min_price\":455,\"max_price\":755,\"avg_price\":605,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/hisushi1.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/hisushi1.jpg\",\"latlng\":\"25.041285,121.54732\",\"score\":0.33923176},{\"restaurant_id\":1743,\"name\":\"PS TAPAS \\u897f\\u73ed\\u7259\\u9910\\u9152\\u9928\",\"min_price\":400,\"max_price\":600,\"avg_price\":500,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1376549239_Interior-1.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1376549239_Interior-1.jpg\",\"latlng\":\"25.0395108,121.5512449\",\"score\":0.36751214},{\"restaurant_id\":2021,\"name\":\"\\u6cf0\\u96c6 Thai Bazaar\",\"min_price\":400,\"max_price\":700,\"avg_price\":550,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1396858393_Thai-Bazaar.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1396858393_Thai-Bazaar.jpg\",\"latlng\":\"25.0411609,121.545965\",\"score\":0.37359157},{\"restaurant_id\":1307,\"name\":\"\\u6d1b\\u795e\\u8ce6\\u9ebb\\u8fa3\\u6975\\u54c1\\u9d1b\\u9d26\",\"min_price\":515,\"max_price\":638,\"avg_price\":577,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1350323171_luoshen.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1350323171_luoshen.jpg\",\"latlng\":\"25.040446,121.544985\",\"score\":0.3772777},{\"restaurant_id\":1676,\"name\":\"\\u597d\\u5ba2\\u9152\\u5427\\u71d2\\u70e4-\\u5fe0\\u5b5d\\u5e97\",\"min_price\":498,\"max_price\":888,\"avg_price\":693,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1368444994_%E5%BF%A0%E5%AD%9D%E5%BA%97%E6%99%AF.JPG\",\"thumb1\":\"\\/imgs\\/data1\\/1368444994_\\u5fe0\\u5b5d\\u5e97\\u666f.JPG\",\"latlng\":\"25.04137,121.546292\",\"score\":0.37885645},{\"restaurant_id\":1539,\"name\":\"\\u624b\\u4e32\\u672c\\u8216\",\"min_price\":300,\"max_price\":900,\"avg_price\":600,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1356723653_IMG_2925%EF%BF%BD%EF%BF%BD%EF%BF%BD%EF%BF%BD%EF%BF%BD%EF%BF%BD.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1356723653_IMG_2925\\ufffd\\ufffd\\ufffd\\ufffd\\ufffd\\ufffd.jpg\",\"latlng\":\"25.037163,121.544282\",\"score\":0.38124132},{\"restaurant_id\":1998,\"name\":\"Jimolulu-A Taste of Hawaii Paradise\\u7f8e\\u5f0f\\u590f\\u5a01\\u5937\",\"min_price\":400,\"max_price\":600,\"avg_price\":500,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1394613286_sofa%20view.JPG\",\"thumb1\":\"\\/imgs\\/data1\\/1394613286_sofa view.JPG\",\"latlng\":\"25.039081,121.552121\",\"score\":0.43835682},{\"restaurant_id\":150,\"name\":\"\\u771f\\u7684\\u597d\\u6d77\\u9bae\\u9910\\u5ef3(\\u53f0\\u5317)\",\"min_price\":1041,\"max_price\":2270,\"avg_price\":1656,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/zhen-de-hao-hai-xian.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/zhen-de-hao-hai-xian.jpg\",\"latlng\":\"25.039158,121.543398\",\"score\":0.4603435},{\"restaurant_id\":2068,\"name\":\"\\u690d\\u70ad\\u6162\\u706b\\u6599\\u7406-\\u5927\\u5b89\\u5e97\",\"min_price\":500,\"max_price\":1000,\"avg_price\":750,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1400486876_12.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1400486876_12.jpg\",\"latlng\":\"25.0344257,121.5460552\",\"score\":0.46502},{\"restaurant_id\":1292,\"name\":\"\\u6c5f\\u5357\\u6625-\\u53f0\\u5317\\u798f\\u83ef\\u5927\\u98ef\\u5e97\",\"min_price\":562,\"max_price\":866,\"avg_price\":714,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/harword11.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/harword11.jpg\",\"latlng\":\"25.038172,121.543182\",\"score\":0.4716258},{\"restaurant_id\":1295,\"name\":\"\\u6d77\\u5c71\\u5ef3-\\u53f0\\u5317\\u798f\\u83ef\\u5927\\u98ef\\u5e97\",\"min_price\":733,\"max_price\":1214,\"avg_price\":974,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/haword44.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/haword44.jpg\",\"latlng\":\"25.038269,121.543161\",\"score\":0.4736052},{\"restaurant_id\":2039,\"name\":\"Pig & Pepper\",\"min_price\":350,\"max_price\":800,\"avg_price\":575,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1398686907_pic2.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1398686907_pic2.jpg\",\"latlng\":\"25.035192,121.544611\",\"score\":0.47404647},{\"restaurant_id\":1170,\"name\":\"\\u5f69\\u8679\\u5ea7-\\u53f0\\u5317\\u798f\\u83ef\\u5927\\u98ef\\u5e97\",\"min_price\":541,\"max_price\":722,\"avg_price\":632,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/Howard_Taipei_Rainbow.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/Howard_Taipei_Rainbow.jpg\",\"latlng\":\"25.0377104,121.5431762\",\"score\":0.47621626},{\"restaurant_id\":1171,\"name\":\"\\u7f85\\u6d6e\\u5bae-\\u53f0\\u5317\\u798f\\u83ef\\u5927\\u98ef\\u5e97\",\"min_price\":691,\"max_price\":904,\"avg_price\":798,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1354860980_%E7%BE%85%E6%B5%AE%E5%AE%AE03.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1354860980_\\u7f85\\u6d6e\\u5bae03.jpg\",\"latlng\":\"25.0377104,121.5431762\",\"score\":0.47621626},{\"restaurant_id\":1439,\"name\":\"\\u5ddd\\u8b5c \\u6e1d\\u6d3e\\u56db\\u5ddd\\u7f8e\\u994c\",\"min_price\":450,\"max_price\":800,\"avg_price\":625,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1354790820_%E5%B7%9D%E8%AD%9C%E6%99%AF%E8%A7%80%E7%85%A7small.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1354790820_\\u5ddd\\u8b5c\\u666f\\u89c0\\u7167small.jpg\",\"latlng\":\"25.039097,121.552523\",\"score\":0.47840774},{\"restaurant_id\":1293,\"name\":\"\\u73cd\\u73e0\\u574a-\\u53f0\\u5317\\u798f\\u83ef\\u5927\\u98ef\\u5e97\",\"min_price\":517,\"max_price\":740,\"avg_price\":629,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/haword22.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/haword22.jpg\",\"latlng\":\"25.038133,121.543075\",\"score\":0.48252404},{\"restaurant_id\":1909,\"name\":\"\\u9e97\\u7dfb\\u5929\\u9999\\u6a13 - \\u592a\\u5e73\\u6d0b\\u767e\\u8ca8SOGO\\u5fe0\\u5b5d\\u5e97\",\"min_price\":500,\"max_price\":1000,\"avg_price\":750,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/1384156981_%E5%A4%A9%E9%A6%99%E6%A8%93.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/1384156981_\\u5929\\u9999\\u6a13.jpg\",\"latlng\":\"25.0418928,121.5446669\",\"score\":0.5152974},{\"restaurant_id\":482,\"name\":\"\\u6676\\u6e6f\\u5319\\u6cf0\\u5f0f\\u4e3b\\u984c\\u9910\\u5ef3 - SOGO\\u5fa9\\u8208\\u5e97\",\"min_price\":476,\"max_price\":759,\"avg_price\":618,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/jing-tang-chi-SOGO.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/jing-tang-chi-SOGO.jpg\",\"latlng\":\"25.041476,121.543239\",\"score\":0.5862453},{\"restaurant_id\":659,\"name\":\"TRASTEVERE\\u7fa9\\u5f0f\\u9910\\u5ef3\",\"min_price\":572,\"max_price\":985,\"avg_price\":779,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/trastevere.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/trastevere.jpg\",\"latlng\":\"25.041476,121.543239\",\"score\":0.5862453},{\"restaurant_id\":810,\"name\":\"\\u9e97\\u7dfb\\u5df4\\u8cfd\\u9e97 - \\u53f0\\u5317\\u4e9e\\u90fdSOGO\\u5fa9\\u8208\\u9928\",\"min_price\":666,\"max_price\":1044,\"avg_price\":855,\"thumb1_mini\":\"\\/imgs\\/data1_240\\/ba-sai-li-ting2.jpg\",\"thumb1\":\"\\/imgs\\/data1\\/ba-sai-li-ting2.jpg\",\"latlng\":\"25.041476,121.543239\",\"score\":0.5862453}]}}";
	id dic = [NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
	return dic;
}

@end
