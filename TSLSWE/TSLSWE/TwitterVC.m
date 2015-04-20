//
//  TwitterVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/20/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "TwitterVC.h"

@interface TwitterVC ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TwitterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/tslnews"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
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
