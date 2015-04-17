//
//  PickSectionTVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/16/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "PickSectionTVC.h"
#import "ReadSectionTVC.h"

@interface PickSectionTVC ()

@property (strong, nonatomic) NSArray *data;

@end

@implementation PickSectionTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    _data = [[NSArray alloc] initWithObjects:@"Top Stories", @"News", @"Sports", @"Life & Style", @"Opinions", @"Features", nil];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)shouldHideViewController:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PickSectionCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSString *sectionName = cell.textLabel.text;
    
    UINavigationController *nav = segue.destinationViewController;
    
    
    if ([nav.topViewController isKindOfClass:[ReadSectionTVC class]]) {
        ReadSectionTVC *vc = (ReadSectionTVC *)nav.topViewController;
        vc.sectionName = sectionName;
        vc.title = sectionName;
    }
    
}


@end
