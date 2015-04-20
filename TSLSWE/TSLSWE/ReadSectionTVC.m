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

@property (strong, nonatomic) NSArray *data;

@end

@implementation ReadSectionTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *data = [[NSArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
      //[self getData];
    
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    //self.refreshControl.backgroundColor = [UIColor blueColor];
    self.refreshControl.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Getting most recent articles"];
    [self.refreshControl addTarget:self
                            action:@selector(getData)
                  forControlEvents:UIControlEventValueChanged];


 
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    // kick off your async refresh!
   
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
     [self getData];
    // Do any additional setup after loading the view.
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
    
    UIBarButtonItem *backItem;
    
    if ([_sectionName isEqualToString:@"Top Stories"]) {
        backItem = [[UIBarButtonItem alloc] initWithTitle:@"Top"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:nil
                                                                    action:nil];
    } else if ([_sectionName isEqualToString:@"Life & Style"]) {
        backItem = [[UIBarButtonItem alloc] initWithTitle:@"L&S"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:nil
                                                                    action:nil];
    } else {
        backItem = [[UIBarButtonItem alloc] initWithTitle:_sectionName
                                                    style:UIBarButtonItemStylePlain
                                                   target:nil
                                                   action:nil];
    }
    
    
    
    
    
    [self.navigationItem setBackBarButtonItem:backItem];
  
}


- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    if( self.refreshControl.isRefreshing)
        [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getData {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
    dispatch_async(concurrentQueue, ^{
        NSURL *url;
        if ([_sectionName isEqualToString:@"Top Stories"]) {
            url = [NSURL URLWithString:@"http://tslswe.pythonanywhere.com/featured"];
        } else if ([_sectionName isEqualToString:@"Favorites"]) {
            
           
            
            NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
             NSString *urlStr = [NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/users/%@", uuid];
            
            url = [NSURL URLWithString:urlStr];
            
        } else {
            NSString *urlStr = [NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/sections/%@", _sectionName];
            urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            url = [NSURL URLWithString:urlStr];
        }

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

#pragma mark - Table view data source

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

// This will tell your UITableView what data to put in which cells in your table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifer = @"ReadSectionCell";
    
    ArticleInfoCell *cell = (ArticleInfoCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil) {
        cell = (ArticleInfoCell*)[[ArticleInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    // Deciding which data to put into this particular cell.
    // If it the first row, the data input will be "Data1" from the array.
    NSUInteger row = [indexPath row];
    
    NSDictionary *fieldData = [_data[row] valueForKey:@"fields"];
    
    NSString *title = [fieldData valueForKey:@"headline"];
    
    
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
    
    NSString *byLine = [NSString stringWithFormat:@"%@ | %@", author, date];
    
    cell.articleTitle.text = title;
    cell.byLine.text = byLine;
    
    return cell;
}


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
    
    
}

@end
