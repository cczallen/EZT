//
//  EZTNearByRestaurantsSkewedViewController.m
//  EZT
//
//  Created by ALLENMAC on 2014/6/23.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import "EZTNearByRestaurantsSkewedViewController.h"
#import "MPSkewedCell_FontSizeAdjust.h"
#import "MPSkewedParallaxLayout.h"
#import "UIImageView+WebCache.h"
#import <PromiseKit/PromiseKit.h>
#import <CoreLocation/CoreLocation.h>

static NSString *kCell=@"MPSkewedCell";


@interface EZTNearByRestaurantsSkewedViewController () 
<UICollectionViewDelegateFlowLayout
,UICollectionViewDelegate
,UICollectionViewDataSource
,UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableDictionary *addressDic; //@{@(id): @"address"}
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;;
@property (nonatomic) BOOL isFetching;

- (void)_fetchMoreData;

@end


@implementation EZTNearByRestaurantsSkewedViewController

- (void)reloadData	{
	[EZTService reqNearByRestaurants:^(NSArray *results) {
		self.dataArray = [results mutableCopy];
		self.addressDic = nil;
		self.collectionView.alpha = 0;
		[self.collectionView reloadData];
		[self _updateTitle];
		[UIView animateWithDuration:0.26 animations:^{
			self.collectionView.alpha = 1.0;
		}];
	}];
}

- (void)_fetchMoreData	{
//	[TSMessage showNotificationInViewController:self title:@"loading..." subtitle:nil type:TSMessageNotificationTypeMessage duration:TSMessageNotificationDurationEndless];
	[TSMessage showNotificationInViewController:self
										  title:@"loading..."
									   subtitle:nil
										  image:nil
										   type:TSMessageNotificationTypeMessage
									   duration:TSMessageNotificationDurationEndless
									   callback:nil
									buttonTitle:nil
								 buttonCallback:nil
									 atPosition:TSMessageNotificationPositionBottom//Top
						   canBeDismissedByUser:YES];
	
	if (self.isFetching) {
		return;
	}
	
	dispatchBG(^{
		self.isFetching = YES;
		if (!DebugTweakValue(@"Use stub restaurants", YES)) {
			
			NSUInteger start = self.dataArray.count;
			[EZTService reqNearByRestaurantsWithStart:start andN:[EZTService defaultPageLimits] completion:^(NSArray *results) {
				
				NSArray *newDatas = results;
				NSUInteger __block idx = self.dataArray.count;
				[self.dataArray addObjectsFromArray:newDatas];
				NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:newDatas.count];
				repeat(newDatas.count, ^(size_t i) {
					[indexPaths addObject:[NSIndexPath indexPathForRow:idx++ inSection:0]];
				});
				
				dispatchMain(^{
					[TSMessage dismissActiveNotificationWithCompletion:^{
						[self _updateTitle];
						CGFloat yOffset = 2;
						[self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y -yOffset) animated:YES];
						[self.collectionView performBatchUpdates:^{
							[self.collectionView insertItemsAtIndexPaths:indexPaths];	//[self.collectionView reloadData];
						} completion:^(BOOL finished) {
							[self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y +yOffset) animated:YES];
							self.isFetching = NO;
						}];
					}];
				});
				
			}];
			
		}else {
			//stub
			NSArray *newDatas = [self.dataArray copy];
			dispatchAfter(2, ^{	//simulate an async load
				NSUInteger __block idx = self.dataArray.count;
				[self.dataArray addObjectsFromArray:newDatas];
				NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:newDatas.count];
				repeat(newDatas.count, ^(size_t i) {
					[indexPaths addObject:[NSIndexPath indexPathForRow:idx++ inSection:0]];
				});
				
				dispatchMain(^{
					[TSMessage dismissActiveNotificationWithCompletion:^{
						[self _updateTitle];
						CGFloat yOffset = 2;
						[self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y -yOffset) animated:YES];
						[self.collectionView performBatchUpdates:^{
							[self.collectionView insertItemsAtIndexPaths:indexPaths];	//[self.collectionView reloadData];
						} completion:^(BOOL finished) {
							[self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y +yOffset) animated:YES];
							self.isFetching = NO;
						}];
					}];
				});
			});
		}
	});
}

- (void)_updateTitle {
	self.title = [NSString stringWithFormat:@"Count:%li", (unsigned long)self.dataArray.count];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self _setCollectionView];
	[self reloadData];
	
	UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
}

- (void)_setCollectionView	{
	UICollectionViewFlowLayout *layout;
	if (!DebugTweakValue(@"PARALLAX_ENABLED", YES)) {
		// you can use that if you don't need parallax
		layout=[[UICollectionViewFlowLayout alloc] init];
		layout.itemSize=CGSizeMake(self.view.width, 230);
		layout.minimumLineSpacing=-layout.itemSize.height/3; // must be always the itemSize/3
		//use the layout you want as soon as you recalculate the proper spacing if you made different sizes
	} else {
		layout=[[MPSkewedParallaxLayout alloc] init];
	}
	
	CGRect frame = self.view.bounds;
	NSInteger lineSpacing = 15;
	frame.origin.y += [[UIApplication sharedApplication] statusBarFrame].size.height +lineSpacing;
	frame.size.height -= frame.origin.y;
	UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.delegate=self;
    collectionView.dataSource=self;
    collectionView.backgroundColor=[UIColor whiteColor];
	collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
	collectionView.allowsSelection = NO;
	collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [collectionView registerClass:[MPSkewedCell_FontSizeAdjust class] forCellWithReuseIdentifier:kCell];
    [self.view addSubview:collectionView];
	self.collectionView = collectionView;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MPSkewedCell_FontSizeAdjust* cell = (MPSkewedCell_FontSizeAdjust *) [collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    
	uint myRow = (uint)indexPath.row;
	
	if (myRow == self.dataArray.count -1) {
		//last row
		[self _fetchMoreData];
	}
	
	NSDictionary *data = self.dataArray[myRow];
	id restaurantId = data[restaurant_id_KEY];
	NSString *str = data[name_KEY];
	NSString *strDetail = [NSString stringWithFormat:@"latlnt:%@", data[latlng_KEY]];
	NSString *thumbURL = [EZTService fullURLFromThumbKey:data[thumbURL_KEY]];
	
    NSString *text = [NSString stringWithFormat:@"%@\n%@", str, strDetail];
    
    cell.text=text;
	[cell.imageView setImageWithURL:[NSURL URLWithString:thumbURL]
				   placeholderImage:[UIImage imageNamed:@"imagePlaceholder2"]
							options:(0)
	 ];
	
	if (DebugTweakValue(@"ReverseGeoCode", YES)) {
		if (!self.addressDic) {
			self.addressDic = [NSMutableDictionary dictionaryWithCapacity:self.dataArray.count];
		}
		
		void (^updateCell)(NSUInteger, NSString *) = ^(NSUInteger row, NSString *address){
			if (row == myRow) {
				NSString *newText = [NSString stringWithFormat:@"%@\n%@", str, address];
				cell.text = newText;
			}else	{
				NSLog(@"LOG:  row != myRow]");
			}
		};
		
		NSString __block *address = self.addressDic[restaurantId];
		if (address) {
			updateCell(myRow, address);
		}else	{
			//ReverseGeocode
			NSArray *latlngArray = [data[latlng_KEY] componentsSeparatedByString:@","];
			if (latlngArray) {
				CLLocation *someLocation = [[CLLocation alloc] initWithLatitude:[latlngArray[0] floatValue] longitude:[latlngArray[1] floatValue]];
				[CLGeocoder reverseGeocode:someLocation].then(^(CLPlacemark *firstPlacemark){
					NSArray *addressArray = [firstPlacemark addressDictionary][@"FormattedAddressLines"];
					if ([addressArray count]) {
						address = addressArray[0];
						NSUInteger row = [collectionView indexPathForCell:cell].row;
						self.addressDic[restaurantId] = address;
						updateCell(row, address);
					}
				}).catch(^(NSError *error){
					[EZTService handleError:error];
				});
			}
		}//address
	}
	
    return cell;
}

/*
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	
    NSLog(@"item %li",(long)indexPath.item);
	
    NSInteger bk=choosed;
    
    if(choosed==-1)
        choosed=indexPath.item;
    else choosed=-1;
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
    for (NSInteger i=0; i<30; i++) {
        if (i!=choosed && i!=bk) {
            [arr addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
    }
    
    [collectionView performBatchUpdates:^{
        if (choosed==-1) {
            [collectionView insertItemsAtIndexPaths:arr];
        }else [collectionView deleteItemsAtIndexPaths:arr];
    } completion:^(BOOL finished) {
        
    }];
	
	
}
*/

#pragma mark <UINavigationControllerDelegate>
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
	return self.interactivePopTransition;
}



#pragma mark UIGestureRecognizer handlers
- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
	
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Create a interactive transition and pop the view controller
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Update the interactive transition's progress
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        // Finish or cancel the interactive transition
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
		
        self.interactivePopTransition = nil;
    }
	
}

@end