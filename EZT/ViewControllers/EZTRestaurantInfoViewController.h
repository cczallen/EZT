//
//  EZTRestaurantInfoViewController.h
//  EZT
//
//  Created by ALLENMAC on 2014/7/2.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import "AnimationTransitionBaseViewController.h"

@interface EZTRestaurantInfoViewController : AnimationTransitionBaseViewController

@property (strong, nonatomic) id data;
@property (strong, nonatomic) UIImage *img;

@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UITextView *tx1;

@end
