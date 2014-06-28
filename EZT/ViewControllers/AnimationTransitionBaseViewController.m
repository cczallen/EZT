//
//  AnimationTransitionBaseViewController.m
//  
//
//  Created by ALLENMAC on 2014/6/24.
//
//

#import "AnimationTransitionBaseViewController.h"
#import "ALTransition.h"

static CFTimeInterval _ALShakeMinTimeInterval = 0.4;
@implementation AnimationTransitionBaseViewController {
	BOOL _shaking;
}

#pragma mark - View Cycles
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}



#pragma mark <UINavigationControllerDelegate>
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    // Check if we're transitioning from this view controller to a DSLSecondViewController
    if ([fromVC isEqual:self]) {
        return [[ALTransition alloc] init];
    }
    else {
        return nil;
    }
}


- (void)shakeshake {
}

- (BOOL)_shouldPresentTweaks
{
#if TARGET_IPHONE_SIMULATOR
	return YES;
#else
	return _shaking && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
#endif
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if (motion == UIEventSubtypeMotionShake) {
		_shaking = YES;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _ALShakeMinTimeInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			if ([self _shouldPresentTweaks]) {
				[self shakeshake];
			}
		});
	}
//	[super motionBegan:motion withEvent:event];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if (motion == UIEventSubtypeMotionShake) {
		_shaking = NO;
	}
//	[super motionEnded:motion withEvent:event];
}

@end
