//
//  ALTransition.m
//  EZT
//
//  Created by ALLENMAC on 2014/6/24.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import "ALTransition.h"
#import "ViewController.h"
#import "EZTNearByRestaurantsSkewedViewController.h"
#import "EZTRestaurantInfoViewController.h"

@interface ALTransition ()

//ViewController <-> NearBy
- (void)animationPushNearBy:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)animationPopNearBy:(id <UIViewControllerContextTransitioning>)transitionContext;

//NearBy <-> Info
- (void)animationPushRestaurantInfo:(id <UIViewControllerContextTransitioning>)transitionContext;

@end

@implementation ALTransition

#pragma mark - <UIViewControllerAnimatedTransitioning>
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext	{
	if ([self _isPushNearBy:transitionContext]) {
		return 0.7;
	} else if ([self _isPushRestaurantInfo:transitionContext]){
		return 0.9;
	}else {
		return 0.4;
	}
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext	{
	
	if ([self _isPushNearBy:transitionContext]) {
		[self animationPushNearBy:transitionContext];
	} else if ([self _isPushRestaurantInfo:transitionContext]){
		[self animationPushRestaurantInfo:transitionContext];
	} else {
		[self animationPopNearBy:transitionContext];
	}
}

- (BOOL)_isPushNearBy:(id <UIViewControllerContextTransitioning>)transitionContext	{
	
	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	
	if ([fromVC isKindOfClass:[ViewController class]]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)_isPushRestaurantInfo:(id <UIViewControllerContextTransitioning>)transitionContext	{
	
	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	if ([fromVC isKindOfClass:[EZTNearByRestaurantsSkewedViewController class]]
		&& [toVC isKindOfClass:[EZTRestaurantInfoViewController class]]) {
		return YES;
	} else {
		return NO;
	}
}

- (void)animationPushNearBy:(id <UIViewControllerContextTransitioning>)transitionContext	{
	ViewController *fromVC = (ViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	UIView *containerView = [transitionContext containerView];
	NSTimeInterval duration = [self transitionDuration:transitionContext];
	
	NSMutableArray *upSnaps = [@[] mutableCopy];
	NSMutableArray *downSnaps = [@[] mutableCopy];
	for (UIView *subview in fromVC.view.subviews) {
		
		UIView *snap = [subview snapshotViewAfterScreenUpdates:NO];
		snap.frame = [containerView convertRect:subview.frame fromView:subview.superview];
		
		[subview setHidden:YES];
		[containerView addSubview:snap];
		
		if (subview.center.y < fromVC.view.center.y) {
			[upSnaps addObject:snap];
		}else {
			[downSnaps addObject:snap];
		}
	}
	[toVC.view setAlpha:0];
	toVC.view.x = toVC.view.width;
	[containerView addSubview:toVC.view];
	
	
	
	[UIView animateWithDuration:duration *0.6 animations:^{
		for (UIView *snap in upSnaps) {
			[snap setY:(0 -snap.height)];
			[snap setAlpha:0];
		}
		for (UIView *snap in downSnaps) {
			[snap setY:(fromVC.view.y +fromVC.view.height)];
			[snap setAlpha:0];
		}
		
	} completion:^(BOOL finished) {

		[UIView animateWithDuration:duration *0.4 delay:0 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
//		[UIView animateWithDuration:duration *0.35 animations:^{
			[toVC.view setAlpha:1.0];
			toVC.view.x = 0;
		} completion:^(BOOL finished) {
			for (UIView *subview in fromVC.view.subviews) {
				[subview setHidden:NO];
			}
			for (UIView *snap in upSnaps) {
				[snap removeFromSuperview];
			}
			for (UIView *snap in downSnaps) {
				[snap removeFromSuperview];
			}
			[transitionContext completeTransition:![transitionContext transitionWasCancelled]];
		}];
	}];
}

- (void)animationPopNearBy:(id <UIViewControllerContextTransitioning>)transitionContext	{
	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	ViewController *toVC = (ViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

	UIView *containerView = [transitionContext containerView];
	NSTimeInterval duration = [self transitionDuration:transitionContext];
	
	toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
	fromVC.view.alpha = 1.0;
	fromVC.view.x = 0;
	
	NSUInteger tagOffset = 1000;
	
	NSMutableArray *upSnaps = [@[] mutableCopy];
	NSMutableArray *downSnaps = [@[] mutableCopy];
	[toVC.view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		UIView *snap = [subview snapshotViewAfterScreenUpdates:NO];
		snap.frame = subview.frame;	//snap.frame = [containerView convertRect:subview.frame fromView:subview.superview];
		snap.tag = subview.tag = (idx +tagOffset);
		
//		[subview setHidden:YES];
		subview.alpha = 0;
		if (subview.center.y < toVC.view.center.y) {
			[upSnaps addObject:snap];
			[subview setY:-subview.height];
		}else {
			[downSnaps addObject:snap];
			[subview setY:subview.superview.height];
		}
		subview.y *=2;
	}];
	
	[containerView insertSubview:toVC.view belowSubview:fromVC.view];
	
	[UIView animateWithDuration:duration /*0.4*/ delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
		
		fromVC.view.alpha = 0;
		fromVC.view.x = fromVC.view.width;
		
		UIView *subview;
		for (UIView *snap in upSnaps) {
			subview = [toVC.view viewWithTag:snap.tag];
			[subview setFrame:snap.frame];
			subview.alpha = 1;
		}
		for (UIView *snap in downSnaps) {
			subview = [toVC.view viewWithTag:snap.tag];
			[subview setFrame:snap.frame];
			subview.alpha = 1;
		}
		
	} completion:^(BOOL finished) {
		for (UIView *subview in toVC.view.subviews) {
			[subview setHidden:NO];
		}
		for (UIView *snap in upSnaps) {
			[snap removeFromSuperview];
		}
		for (UIView *snap in downSnaps) {
			[snap removeFromSuperview];
		}
		[transitionContext completeTransition:![transitionContext transitionWasCancelled]];
	}];
}



- (void)animationPushRestaurantInfo:(id <UIViewControllerContextTransitioning>)transitionContext	{
	EZTNearByRestaurantsSkewedViewController *fromVC = (EZTNearByRestaurantsSkewedViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	EZTRestaurantInfoViewController *toVC = (EZTRestaurantInfoViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	UIView *containerView = [transitionContext containerView];
	NSTimeInterval duration = [self transitionDuration:transitionContext];

	UIImageView *imageView = [fromVC getSelectedImageViewForAnimation];
	UIView *snapImg = [imageView snapshotViewAfterScreenUpdates:NO];
	snapImg.frame = [containerView convertRect:imageView.frame fromView:imageView.superview];
	[imageView setHidden:YES];

	toVC.view.x = toVC.view.width;
	toVC.imgV.alpha = 0;
	[containerView addSubview:toVC.view];
	[containerView addSubview:snapImg];
NSLog(@"LOG:  [toVC isViewLoaded]: %@", ([toVC isViewLoaded])? @"YES":@"NO" );
	
	[UIView animateWithDuration:duration *0.6 animations:^{

		snapImg.y = 0;
		toVC.view.alpha = 1;
		toVC.view.x = 0;
		
	} completion:^(BOOL finished) {
		
		[UIView animateWithDuration:duration *0.4 delay:0 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
			snapImg.alpha = 0;
			toVC.imgV.alpha = 1;

		} completion:^(BOOL finished) {
			[imageView setHidden:NO];
			[snapImg removeFromSuperview];
			[transitionContext completeTransition:![transitionContext transitionWasCancelled]];
		}];
	}];
}

@end
