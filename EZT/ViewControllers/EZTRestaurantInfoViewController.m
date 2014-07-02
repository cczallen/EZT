//
//  EZTRestaurantInfoViewController.m
//  EZT
//
//  Created by ALLENMAC on 2014/7/2.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import "EZTRestaurantInfoViewController.h"

@implementation EZTRestaurantInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.imgV.contentMode=UIViewContentModeScaleAspectFill;
	[self.imgV setImage:self.img];
	[self.tx1 setText:[self.data description]];
}


#pragma mark <UINavigationControllerDelegate>
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC

												 toViewController:(UIViewController *)toVC {
	if (operation == UINavigationControllerOperationPush) {
		return nil;
	}else {
		return [super navigationController:navigationController
		   animationControllerForOperation:operation
						fromViewController:fromVC
						  toViewController:toVC
				];
	}
}
@end
