//
//  EZTNearByRestaurantViewController.m
//  EZT
//
//  Created by ALLENMAC on 2014/6/22.
//  Copyright (c) 2014年 AllenLee. All rights reserved.
//

#import "EZTNearByRestaurantViewController.h"
#import "UIImageView+WebCache.h"

@implementation EZTNearByRestaurantViewController

- (void)reloadData	{
	[EZTService reqNearByRestaurants:^(NSArray *results) {
		self.dataArray = [results mutableCopy];
		[self.tableView reloadData];
	}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self reloadData];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		[cell.imageView setContentMode:(UIViewContentModeScaleAspectFill)];
		[cell.imageView setBounds:CGRectMake(0, 0, self.tableView.rowHeight, self.tableView.rowHeight)];
    }
	
    // Configure the cell...
	uint myRow = (uint)indexPath.row;
	NSDictionary *data = self.dataArray[myRow];
	NSString *str = data[name_KEY];
	NSString *strDetail = [NSString stringWithFormat:@"平均價位:%@, latlnt:%@", data[avg_price_KEY], data[latlng_KEY]];
	NSString *thumbURL = [EZTService fullURLFromThumbKey:data[thumbURL_KEY]];

	[cell.textLabel setText:str];
	[cell.detailTextLabel setText:strDetail];
	
	[cell.imageView setImageWithURL:[NSURL URLWithString:thumbURL]
				   placeholderImage:[UIImage imageNamed:@"imagePlaceholder"]
							options:(SDWebImageCacheMemoryOnly)
	 ];
    
    return cell;
}

@end
