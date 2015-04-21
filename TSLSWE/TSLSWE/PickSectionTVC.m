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
#import "ReadOtherVC.h"

@interface PickSectionTVC ()

//section choices
@property (strong, nonatomic) NSArray *data;

@end

@implementation PickSectionTVC


#pragma mark - View Controller Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    //we have a fixed set of sections to pick from
    //we do this as opposed to static cells for ease of transitioning
    _data = [[NSArray alloc] initWithObjects:@"Top Stories", @"News", @"Sports", @"Life & Style", @"Opinions", @"Features", @"Twitter", @"About", @"Contact",nil];
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    //set back button text for section table views
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    
    //stlye the navigation controller
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

#pragma mark - Table View Data Source / Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}


- (SectionCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get the section cell
    SectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PickSectionCell" forIndexPath:indexPath];
    
    //Set up cell display based on row and text from array of options
    cell.name.text = _data[indexPath.row];
    cell.image.image= [UIImage imageNamed:_data[indexPath.row]];
    
    //set the cell font size
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
    
    UIFont *nameSize = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18+offset];
    cell.name.font = nameSize;
    
    return cell;
}

//We have different segues based on which option you want
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if you pick a normal TSL section
    if (indexPath.row < 6) {
        [self performSegueWithIdentifier:@"ShowSection" sender:indexPath];
    }
    
    //if you pick Twitter
    else if (indexPath.row == 6){
        [self performSegueWithIdentifier:@"ShowTwitter" sender:indexPath];
    }
    
    //if you pick About or Contact
    else if (indexPath.row > 6){
        [self performSegueWithIdentifier:@"ShowOther" sender:indexPath];
    }
}

#pragma mark - Navigation

//if they want to hide the menu with the upper left X
- (IBAction)shouldHideViewController:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    //if we are segueing from a table cell
    if ([sender isKindOfClass:[NSIndexPath class]]) {
        NSIndexPath *path = (NSIndexPath*) sender;
        NSString *sectionName = _data[path.row];

        //if going to a section, set section name
        if (path.row < 6) {
            UINavigationController *nav = segue.destinationViewController;
            if ([nav.topViewController isKindOfClass:[ReadSectionTVC class]]) {
                ReadSectionTVC *vc = (ReadSectionTVC *)nav.topViewController;
                vc.sectionName = sectionName;
                vc.title = sectionName;
            }
        }
        
        //if going to About
        else if (path.row  == 7) {
            ReadOtherVC *vc = (ReadOtherVC*)segue.destinationViewController;
            vc.otherName = @"About";
        }
        
        //if going to Contact
        else if (path.row == 8) {
            ReadOtherVC *vc = (ReadOtherVC*)segue.destinationViewController;
            vc.otherName = @"Contact";
        }
        
        //we don't do any setup to show the Twitter
    }
    
    //if we pressed the favorites icon
    //set the sectionName property correctly
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
