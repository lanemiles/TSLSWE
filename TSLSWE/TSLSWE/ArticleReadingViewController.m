//
//  ArticleReadingViewController.m
//  TSLSWE
//
//  Created by Lane Miles on 4/9/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "ArticleReadingViewController.h"

@interface ArticleReadingViewController ()
@property (strong, nonatomic) IBOutlet UILabel *articleTitle;
@property (strong, nonatomic) IBOutlet UILabel *articleSection;
@property (strong, nonatomic) IBOutlet UITextView *articleBody;
@property (strong, nonatomic) IBOutlet UILabel *articleByline;


@end

@implementation ArticleReadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //hard load our data
    _articleBody.text = @"Erin O’Brien, a visiting professor in the Intercollegiate Department of Asian American Studies, has been on the tenure-track job market since 2008. A former Fulbright fellow and community activist based in Los Angeles, O’Brien has taught two to three classes a semester at the 5Cs in the hopes that a permanent position will surface here or elsewhere. \n \nBut like most of her part-time colleagues across the country, O’Brien has had to settle for part-time teaching positions at multiple institutions in order to make ends meet. So far this year, she has taught five classes at three different institutions—the 5Cs and two other public universities—and plans on making around $30,000 before taxes. After taking into account all of her living and transportation expenses, O’Brien said she has very little wiggle room.“I will make $31,200 before taxes. … Is it more than minimum wage? Yes-ish. During the summers I’m on unemployment,” she said. “So do I make ends meet? No. I live paycheck to paycheck, and at the end of the month I have zero dollars in my bank account.\n \nO’Brien is one of the estimated 1.3 million professors—roughly 75 percent of all instructors nationwide—who are non-tenure track professors in the United States. A 2013 report by the American Association of University Professors said that “such positions now make up only 24 percent of the academic work force, with the bulk of the teaching load shifted to adjuncts, part-timers, graduate students and full-time professors not on the tenure track.\"\n\nAccording to O’Brien, one of the greatest issues in the field is lack of security. With courses assigned by the semester, instructors have little foresight as to what courses will be offered and whether or not there will be a need to hire them.\n\n“I don’t know what happens in the fall. I have no idea,” O’Brien said. “But I know that I am not making ends meet. When I apply for a tenure-track job there’s anywhere from 100 to 400 people applying for that job.\"";
    
    _articleTitle.text = @"Uncovering the 20%: Part-Time Faculty At the 5Cs";
    
    _articleSection.text = @"NEWS";
    
    _articleByline.text = @"By CARLOS BALLESTEROS and SEAN GUNTHER";
        
        
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
