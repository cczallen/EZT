//
//  MPSkewedCell_FontSizeAdjust.m
//  EZT
//
//  Created by ALLENMAC on 2014/6/23.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import "MPSkewedCell_FontSizeAdjust.h"

@implementation MPSkewedCell_FontSizeAdjust

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		/*if (DebugTweakValue(@"MotionEffect_ENABLED", YES)) {
			if ([UIDevice currentDevice].systemVersion.floatValue > 7.0) {
				//motion effect
				CGFloat value = 20;
				self.imageView.bounds = CGRectInset(self.imageView.bounds, -value, -value);
				UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:(UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis)];
				horizontalMotionEffect.minimumRelativeValue = @(-value);
				horizontalMotionEffect.maximumRelativeValue = @(value);
				[self.imageView addMotionEffect:horizontalMotionEffect];
			}
		}*/
	}
    return self;
}

- (void)setText:(NSString *)text {
	[super setText:text];
	
	NSString *subString = [text substringWithRange:[text rangeOfString:@"^.+\n" options:NSRegularExpressionSearch]];
	UIFont *defaultFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:38];
	CGFloat width = [subString sizeWithAttributes:@{NSFontAttributeName: defaultFont}].width;
	if (width > self.width) {
	
		CGFloat percentage = width /self.width;
		percentage += 0.2;
		CGFloat newSize = MAX(19, defaultFont.pointSize /percentage);
		self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:newSize];	//HelveticaNeue-Thin HelveticaNeue-ultralight
	}
}

@end
