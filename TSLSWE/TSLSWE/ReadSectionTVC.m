//
//  SectionTVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/16/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "ReadSectionTVC.h"
#import "ReadArticleVC.h"
#import "ArticleInfoCell.h"

@interface ReadSectionTVC ()

//JSON data
@property (strong, nonatomic) NSArray *data;

@end

@implementation ReadSectionTVC


#pragma mark - View Controller Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initialize array for JSON
    _data = [[NSArray alloc] init];
    
    //set up variable height cells
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //set up spinner
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Getting most recent articles..."];
    [self.refreshControl addTarget:self
                            action:@selector(getData)
                  forControlEvents:UIControlEventValueChanged];
 
}


- (void) viewWillAppear:(BOOL)animated {
   
    [super viewWillAppear:YES];
   
    //start the spinner
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    
    //start asynch refresh
     [self getData];
 
    //style navigation controller
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      
      [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22.0],
      NSFontAttributeName,
      nil]];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    
    //set the back button accordingly so it's not too big
    UIBarButtonItem *backItem;
    
    if ([_sectionName isEqualToString:@"Top Stories"]) {
        backItem = [[UIBarButtonItem alloc] initWithTitle:@"Top" style:UIBarButtonItemStylePlain target:nil action:nil];
    } else if ([_sectionName isEqualToString:@"Life & Style"]) {
        backItem = [[UIBarButtonItem alloc] initWithTitle:@"L&S" style:UIBarButtonItemStylePlain target:nil action:nil];
    } else {
        backItem = [[UIBarButtonItem alloc] initWithTitle:_sectionName style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    [self.navigationItem setBackBarButtonItem:backItem];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source / Delegate Methods
- (void) getData {
    
    //we want to do a non-blocking update
    dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
    
    //get the queue
    dispatch_async(concurrentQueue, ^{
        
        //set URL based on top stories, favorites, or real sections
        NSURL *url;
        
        //in top stories case, we really want what we've deemed featured
        if ([_sectionName isEqualToString:@"Top Stories"]) {
            url = [NSURL URLWithString:@"http://tslswe.pythonanywhere.com/featured"];
        }
        
        //in the favorites case, get what the user has favorited from device UUID
        else if ([_sectionName isEqualToString:@"Favorites"]) {
 
            NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
            NSString *urlStr = [NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/users/%@", uuid];
            
            url = [NSURL URLWithString:urlStr];
            
        }
        
        //otherwise, just a regular TSL section (News, Sports, etc)
        //we have to add the % escapes for Life & Style because of the spaces
        else {
            NSString *urlStr = [NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/sections/%@", _sectionName];
            urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            url = [NSURL URLWithString:urlStr];
        }

        //get the data from the URL
        NSError *err;
        NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        
        //convert to NSData so can parse JSON
        NSData *jsonData = [htmlString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        //if we have data
        if(jsonData != nil) {
            
            //unserialize the JSON
            NSError *error = nil;
            NSArray *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
            
            //set to data ivar
            _data = result;
            
        }
        
        //get main queue to do UI updating
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //update table view
            [self.tableView reloadData];
            
            //stop spinner
            [self.refreshControl endRefreshing];
            
        });
        
        
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}


- (ArticleInfoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get our article info cell
    static NSString *CellIdentifer = @"ReadSectionCell";
    ArticleInfoCell *cell = (ArticleInfoCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifer];

    if (cell == nil) {
        cell = (ArticleInfoCell*)[[ArticleInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    

    //get our data from the JSON based on what row we're in
    NSUInteger row = [indexPath row];
    NSDictionary *fieldData = [_data[row] valueForKey:@"fields"];
    NSString *title = [fieldData valueForKey:@"headline"];
    
    //turn author array into a string
    NSArray *authors = [fieldData valueForKey:@"authors"];
    NSString *by = @"";
    for (int i = 0; i < authors.count; i++) {
        if (i != authors.count - 1) {
            by = [by stringByAppendingString:[NSString stringWithFormat:@"%@ and ", authors[i]]];
        } else {
            by = [by stringByAppendingString:[NSString stringWithFormat:@"%@", authors[i]]];
        }
    }
    NSString *author = by;
    
    //get other data
    NSString *date = [fieldData valueForKey:@"pub_date"];
    NSString *byLine = [NSString stringWithFormat:@"%@ | %@", author, date];
    
    
    //set up the cell
    cell.articleTitle.text = title;
    cell.byLine.text = byLine;
    return cell;
    
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    //always transition to the article reading view so we need to set the ID accordingly
    ArticleInfoCell *cell = (ArticleInfoCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([[segue destinationViewController] isKindOfClass:[ReadArticleVC class]]) {
        NSString *articleId = [[_data[indexPath.row] valueForKey:@"fields"] valueForKey:@"id"];
        ReadArticleVC *vc = (ReadArticleVC*)[segue destinationViewController];
        vc.articleId = articleId;
    }
    
    
}

@end
