//
//  FeaturedArticlesTVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/15/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "FeaturedArticlesTVC.h"
#import "ReadArticleVC.h"

@interface FeaturedArticlesTVC () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *data;
@end

@implementation FeaturedArticlesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = [[NSArray alloc] init];
    // Copying the array you just created to your data array for use in your table.
    self.data = array;
    // Do any additional setup after loading the view.
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getData {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
    dispatch_async(concurrentQueue, ^{
        
        NSURL *url = [NSURL URLWithString:@"http://tslswe.pythonanywhere.com/featured/"];
        
        NSData *jsonData = [NSData dataWithContentsOfURL:url];
        
        
        if(jsonData != nil) {
            NSError *error = nil;
            NSArray *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
            if (error == nil) {
                
                _data = result;
                
//                for (NSDictionary *dict in result) {
//
//                    NSLog(@"%@", title);
//                }
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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *articleId = [[_data[indexPath.row] valueForKey:@"fields"] valueForKey:@"id"];
    ReadArticleVC *vc = (ReadArticleVC*)[segue destinationViewController];
    vc.articleId = articleId;
    
}


@end
