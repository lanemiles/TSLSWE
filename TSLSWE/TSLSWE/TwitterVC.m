//
//  TwitterVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/20/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "TwitterVC.h"

@interface TwitterVC () <UIWebViewDelegate>

//web view to show mobile Twitter
@property (strong, nonatomic) IBOutlet UIWebView *webView;

//spinner while loading
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation TwitterVC


#pragma mark - View Controller Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];

    //get the TSL's twitter URL
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/tslnews"];
    
    //load it into the webView
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    
    //create the spinner
    //we use the clear background so if its too slow it's less bad
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.backgroundColor = [UIColor clearColor];
    _spinner.color = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
   
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    //start the spinner
    _spinner.center=self.view.center;
    [_spinner startAnimating];
    [self.view addSubview:_spinner];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - WebView Delegate Methods
//when the website loads, stop the spinner
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self performSelector:@selector(stopSpinning) withObject:nil afterDelay:.5];
}

//we use this so we can call after delay to make transition prettier
- (void) stopSpinning {
    [_spinner stopAnimating];
}

@end
