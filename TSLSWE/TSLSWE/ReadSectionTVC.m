//
//  SectionTVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/16/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "ReadSectionTVC.h"
#import "ReadArticleVC.h"

@interface ReadSectionTVC ()

@property (strong, nonatomic) NSArray *data;

@end

@implementation ReadSectionTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *array = [[NSArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
      [self getData];
 
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    // Do any additional setup after loading the view.
  
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
            
            
            NSLog(@"%@", error);
            
            if (error == nil) {
                
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    // Deciding which data to put into this particular cell.
    // If it the first row, the data input will be "Data1" from the array.
    NSUInteger row = [indexPath row];
    
    NSDictionary *fieldData = [_data[row] valueForKey:@"fields"];
    NSString *title = [fieldData valueForKey:@"headline"];
    
    cell.textLabel.text = title;
    
    return cell;
}


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
