//
//  PickSectionTVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/16/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "PickSectionTVC.h"
#import "ReadSectionTVC.h"
#import "SectionCell.h"
#import "TwitterVC.h"

@interface PickSectionTVC ()

@property (strong, nonatomic) NSArray *data;

@end

@implementation PickSectionTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    _data = [[NSArray alloc] initWithObjects:@"Top Stories", @"News", @"Sports", @"Life & Style", @"Opinions", @"Features", @"Twitter",nil];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)shouldHideViewController:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didPressFavorites:(id)sender {
    
    
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
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


- (SectionCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PickSectionCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.name.text = _data[indexPath.row];
//    if ([_data[indexPath.row] isEqualToString:@"News"]) {
//         cell.image = [UIImage imageNamed:@"News"];
//    }
    cell.image.image= [UIImage imageNamed:_data[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 6) {
        [self performSegueWithIdentifier:@"ShowSection" sender:indexPath];
    } else {
        [self performSegueWithIdentifier:@"TWITTER" sender:indexPath];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[NSIndexPath class]]) {
        NSIndexPath *path = (NSIndexPath*) sender;
        NSString *sectionName = _data[path.row];
        NSLog(@"%ld", (long)path.row);
        if (path.row != 6) {
            UINavigationController *nav = segue.destinationViewController;
            
            if ([nav.topViewController isKindOfClass:[ReadSectionTVC class]]) {
                ReadSectionTVC *vc = (ReadSectionTVC *)nav.topViewController;
                vc.sectionName = sectionName;
                vc.title = sectionName;
            }
        } else {
            
        }
        
        
        
    }
    
    
    else {
    
     
        NSString *sectionName = @"Favorites";
        
        UINavigationController *nav = segue.destinationViewController;
        
        if ([nav.topViewController isKindOfClass:[ReadSectionTVC class]]) {
            ReadSectionTVC *vc = (ReadSectionTVC *)nav.topViewController;
            vc.sectionName = sectionName;
            vc.title = sectionName;
        }
    }
    
    
}


@end
