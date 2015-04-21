//
//  FeaturedTVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/20/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "FeaturedTVC.h"
#import "ArticleInfoCell.h"
#import "ReadArticleVC.h"
#import "ReadSectionTVC.h"

@interface FeaturedTVC ()

//JSON data
@property (strong, nonatomic) NSArray *data;

@end

@implementation FeaturedTVC

#pragma mark - View Controller Life Cycle Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize array for JSON
    NSArray *array = [[NSArray alloc] init];
    self.data = array;
    
    //set up variable height table cells
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    //set up pull to refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Getting most recent articles..."];
    [self.refreshControl addTarget:self
                            action:@selector(getData)
                  forControlEvents:UIControlEventValueChanged];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];

    //override the bar button item for children
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Top"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
 
    
    //style the navigation controller
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
    
    
    //start the spinner spinning and get the data
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    [self getData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source / Delegate Methods
- (void) getData {
    
    //we want to do a non-blocking data load
    dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
    
    //get the queue
    dispatch_async(concurrentQueue, ^{
        
        //get the featured articles
        NSURL *url = [NSURL URLWithString:@"http://tslswe.pythonanywhere.com/featured"];
        NSError *err;
        NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        
        //convert string to NSData
        NSData *jsonData = [htmlString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        //if we have data
        if(jsonData != nil) {
            
            //unserialize the json
            NSError *error = nil;
            NSArray *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
            
            //set the data to the result
            _data = result;
            
        }
        
        //need to get the main queue to update the UI
        dispatch_async(dispatch_get_main_queue(), ^{

            //update the table view
            [self.tableView reloadData];
            
            //stop the spinner
            [self.refreshControl endRefreshing];
            
        });
        
        
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (ArticleInfoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get the articleInfoCell
    static NSString *CellIdentifer = @"CellIdentifier1";
    ArticleInfoCell *cell = (ArticleInfoCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    if (cell == nil) {
        cell = (ArticleInfoCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    

    //set up the cell from the parsed JSON
    NSUInteger row = [indexPath row];
    NSDictionary *fieldData = [_data[row] valueForKey:@"fields"];
    NSString *title = [fieldData valueForKey:@"headline"];
    NSString *section = [fieldData valueForKey:@"section"];
    
    //convert list of authors into string
    NSArray *authors = [fieldData valueForKey:@"authors"];
    NSString *by = @"";
    for (int i = 0; i < authors.count; i++) {
        if (i != authors.count - 1) {
            by = [by stringByAppendingString:[NSString stringWithFormat:@"%@ and ", authors[i]]];
        } else {
            by = [by stringByAppendingString:[NSString stringWithFormat:@"%@", authors[i]]];
        }
    }
    
    //get rest of data
    NSString *author = by;
    NSString *date = [fieldData valueForKey:@"pub_date"];
    NSString *byLine = [NSString stringWithFormat:@"%@  |  %@  |  %@", section, author, date];
    
    //set the cell display
    cell.articleTitle.text = title;
    cell.byLine.text = byLine;
    
    //set the cell font size
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];

    UIFont *titleSize = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16+offset];
    cell.articleTitle.font = titleSize;
    
    UIFont *bySize = [UIFont fontWithName:@"HelveticaNeue-Light" size:13+offset];
    cell.byLine.font = bySize;
    
    return cell;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    //get the sender cell
    ArticleInfoCell *cell = (ArticleInfoCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    //if we are going to read an article, set the articleID
    if ([[segue destinationViewController] isKindOfClass:[ReadArticleVC class]]) {
        NSString *articleId = [[_data[indexPath.row] valueForKey:@"fields"] valueForKey:@"id"];
        ReadArticleVC *vc = (ReadArticleVC*)[segue destinationViewController];
        vc.articleId = articleId;
    }
    
    //else, we might have hit the favorites button, so set that accordingly
    else if([[segue destinationViewController] isKindOfClass:[ReadSectionTVC class]]) {
        
        ReadSectionTVC *vc = (ReadSectionTVC *)segue.destinationViewController;
        vc.sectionName = @"Favorites";
        vc.title = @"Favorites";
    }
    
    //if we hit the menu button, we don't need to do any work here
}

@end
