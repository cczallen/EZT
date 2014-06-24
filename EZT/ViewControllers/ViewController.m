//
//  ViewController.m
//  EZT
//
//  Created by ALLENMAC on 2014/6/22.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import "ViewController.h"
#import <PromiseKit/PromiseKit.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tv1;
- (IBAction)tweaksAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self.tv1 setText:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Podfile" ofType:@""] encoding:NSUTF8StringEncoding error:nil]];
	if (isSimulator) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			if ([[self.navigationController topViewController] isEqual:self]) {
				[self performSegueWithIdentifier:@"EnterNearBy" sender:nil];
			}
		});
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tweaksAction:(id)sender {

	SEL selector = NSSelectorFromString(@"_presentTweaks");
	id  window = [UIApplication sharedApplication].keyWindow;
	[window performSelector:selector];
}


@end
