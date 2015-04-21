//
//  ArticleInfoCell.h
//  TSLSWE
//
//  Created by Lane Miles on 4/19/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleInfoCell : UITableViewCell

//article title
@property (strong, nonatomic) IBOutlet UILabel *articleTitle;

// section | authors | date
@property (strong, nonatomic) IBOutlet UILabel *byLine;

@end
