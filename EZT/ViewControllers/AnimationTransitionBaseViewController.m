//
//  AnimationTransitionBaseViewController.m
//  
//
//  Created by ALLENMAC on 2014/6/24.
//
//

#import "AnimationTransitionBaseViewController.h"
#import "ALTransition.h"

@implementation AnimationTransitionBaseViewController

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

@end
