//
//  ALTransition.m
//  EZT
//
//  Created by ALLENMAC on 2014/6/24.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import "ALTransition.h"
#import "ViewController.h"

@implementation ALTransition

#pragma mark - <UIViewControllerAnimatedTransitioning>
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext	{
	return 0.7;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext	{
	
	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

	if ([fromVC isKindOfClass:[ViewController class]]) {
		[self animationPushNearBy:transitionContext];
	} else {
		[self animationPopNearBy:transitionContext];
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
		}
		for (UIView *snap in downSnaps) {
			[snap setY:(fromVC.view.y +fromVC.view.height)];
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

//	[containerView addSubview:toVC.view];
//	[transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//	return;
	
	
	toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
	fromVC.view.alpha = 1.0;
	fromVC.view.x = 0;
	[containerView insertSubview:toVC.view belowSubview:fromVC.view];
//	toVC.view.alpha = 0.5;
//	[UIView animateWithDuration:duration animations:^{
//		toVC.view.alpha = 1;
//	fromVC.view.alpha = 0.0;
//	} completion:^(BOOL finished) {
//		[transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//	}];
//	return;
	NSUInteger tagOffset = 1000;
	
	NSMutableArray *upSnaps = [@[] mutableCopy];
	NSMutableArray *downSnaps = [@[] mutableCopy];
	[toVC.view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		UIView *snap = [subview snapshotViewAfterScreenUpdates:NO];
		snap.frame = [containerView convertRect:subview.frame fromView:subview.superview];
		snap.tag = subview.tag = (idx +tagOffset);
		
		[subview setHidden:YES];
		
		if (subview.center.y < toVC.view.center.y) {
			[upSnaps addObject:snap];
		}else {
			[downSnaps addObject:snap];
		}
	}];
	
	[UIView animateWithDuration:duration /*0.4*/ delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
		
		fromVC.view.alpha = 0;
		fromVC.view.x = fromVC.view.width;
		
//	} completion:^(BOOL finished) {
		
		for (UIView *snap in upSnaps) {
			[containerView addSubview:snap];
			[snap setY:(0 -snap.height)];
//			[snap setX:-1000];
		}
		for (UIView *snap in downSnaps) {
			[containerView addSubview:snap];
			[snap setY:(fromVC.view.y +fromVC.view.height)];
//			[snap setX:-1000];
		}
		
//		[UIView animateWithDuration:duration *0.6 delay:0 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
			
			for (UIView *snap in upSnaps) {
				UIView *subview = [toVC.view viewWithTag:snap.tag];
				snap.frame = [containerView convertRect:subview.frame fromView:subview.superview];
			}
			for (UIView *snap in downSnaps) {
				UIView *subview = [toVC.view viewWithTag:snap.tag];
				snap.frame = [containerView convertRect:subview.frame fromView:subview.superview];
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
//		}];
	}];
}

@end
