//
//  FeaturedArticlesTVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/15/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "FeaturedArticlesTVC.h"
#import "ReadArticleVC.h"
#import "ArticleInfoCell.h"

@interface FeaturedArticlesTVC () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation FeaturedArticlesTVC


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    // Do any additional setup after loading the view.
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Top Stories"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    
    [self.navigationItem setBackBarButtonItem:backItem];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = [[NSArray alloc] init];
    // Copying the array you just created to your data array for use in your table.
    self.data = array;
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
            
            
            NSLog(@"%@", error);
            
            if (error == nil) {

            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

  
    });
}

#pragma mark Table View Data Source Methods

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

// This will tell your UITableView what data to put in which cells in your table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifer = @"CellIdentifier";
    
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
    
    NSString *byLine = [NSString stringWithFormat:@"%@ | %@ | %@", section, author, date];
    
    cell.articleTitle.text = title;
    cell.byLine.text = byLine;

    
    return cell;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([[segue destinationViewController] isKindOfClass:[ReadArticleVC class]]) {
        NSString *articleId = [[_data[indexPath.row] valueForKey:@"fields"] valueForKey:@"id"];
        ReadArticleVC *vc = (ReadArticleVC*)[segue destinationViewController];
        vc.articleId = articleId;
    }
    
    
}


@end
