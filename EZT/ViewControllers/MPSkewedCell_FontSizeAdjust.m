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
	
	if (!DebugTweakValue(@"ShowText", YES)) {
		return;
	}
	
	BOOL initTextLabel = NO;
	if (!self.textLabel) {
		initTextLabel = YES;
	}
	[super setText:text];
	if (initTextLabel) {
		self.textLabel.autoresizingMask = (
		UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
		UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleWidth |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleHeight );

	}
	
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

- (void)layoutSubviews{
//    [super layoutSubviews];
    UICollectionView *collectionView = (UICollectionView *)[self superview];
	if ([collectionView isKindOfClass:[UICollectionView class]]) {
		CGFloat offset=self.frame.origin.y-[collectionView contentOffset].y;
		CGFloat parallaxValue=offset/self.superview.frame.size.height;
		self.parallaxValue=parallaxValue;
	}
	self.parallaxValue = self.parallaxValue;
}

@end
