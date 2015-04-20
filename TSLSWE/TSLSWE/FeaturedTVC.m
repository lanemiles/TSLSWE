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

@property (strong, nonatomic) NSArray *data;

@end

@implementation FeaturedTVC


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    // Do any additional setup after loading the view.
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Top"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    
    
    
    [self.navigationItem setBackBarButtonItem:backItem];
 
    
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
    
    
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    [self getData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
        NSArray *array = [[NSArray alloc] init];
    self.data = array;
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.refreshControl = [[UIRefreshControl alloc] init];
    //self.refreshControl.backgroundColor = [UIColor blueColor];
    self.refreshControl.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Getting most recent articles"];
    [self.refreshControl addTarget:self
                            action:@selector(getData)
                  forControlEvents:UIControlEventValueChanged];
    

    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void) getData {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
    dispatch_async(concurrentQueue, ^{
        
        NSURL *url = [NSURL URLWithString:@"http://tslswe.pythonanywhere.com/featured"];
        NSError *err;
        NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        NSData *jsonData = [htmlString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        
        
        if(jsonData != nil) {
            NSError *error = nil;
            NSArray *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
            
            
            _data = result;
            
            
            if (error == nil) {
                
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
        
        
    });
}

#pragma mark Table View Data Source Methods

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

// This will tell your UITableView what data to put in which cells in your table.
- (ArticleInfoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifer = @"CellIdentifier1";
    
    ArticleInfoCell *cell = (ArticleInfoCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil) {
        cell = (ArticleInfoCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    // Deciding which data to put into this particular cell.
    // If it the first row, the data input will be "Data1" from the array.
    NSUInteger row = [indexPath row];
    
    NSDictionary *fieldData = [_data[row] valueForKey:@"fields"];
    NSString *title = [fieldData valueForKey:@"headline"];
    
    NSString *section = [fieldData valueForKey:@"section"];
    
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
    
    NSString *date = [fieldData valueForKey:@"pub_date"];
    
    NSString *byLine = [NSString stringWithFormat:@"%@  |  %@  |  %@", section, author, date];
    
    cell.articleTitle.text = title;
    cell.byLine.text = byLine;
    
    
    return cell;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    ArticleInfoCell *cell = (ArticleInfoCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([[segue destinationViewController] isKindOfClass:[ReadArticleVC class]]) {
        NSString *articleId = [[_data[indexPath.row] valueForKey:@"fields"] valueForKey:@"id"];
        ReadArticleVC *vc = (ReadArticleVC*)[segue destinationViewController];
        vc.articleId = articleId;
    }
    
    else if([[segue destinationViewController] isKindOfClass:[ReadSectionTVC class]]) {
        
        ReadSectionTVC *vc = (ReadSectionTVC *)segue.destinationViewController;
        vc.sectionName = @"Favorites";
        vc.title = @"Favorites";
    }
    
    
    
    
    
}

@end
