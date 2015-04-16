//
//  ReadArticleVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/15/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "ReadArticleVC.h"

@interface ReadArticleVC ()
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *articleTitle;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSString *authorNames;
@property (strong, nonatomic) NSString *articleBody;
@end

@implementation ReadArticleVC

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [self getArticleDataWithIDNumber: _articleId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getArticleDataWithIDNumber: (NSString*) articleId {
        dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
        dispatch_async(concurrentQueue, ^{
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/articles/%@", articleId]];

            NSData *jsonData = [NSData dataWithContentsOfURL:url];
           
            if(jsonData != nil) {
                NSError *error = nil;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
                
                NSLog(@"%@", result);
                NSLog(@"%@", error);
                
                if (error == nil) {

                }
                
            }

        });
}

- (void) setText {
    NSString *text = [NSString stringWithFormat:@"%@ \n \n %@ \n %@ \n \n %@",
                      _articleTitle, _sectionName, _authorNames, _articleBody];
    
    // If attributed text is supported (iOS6+)
    
    // Define general attributes for the entire text
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text];
    
    // Article Title attributes
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    NSRange articleTitleRange = [text rangeOfString:_articleTitle];
    [attributedText setAttributes:@{NSFontAttributeName: titleFont}
                            range:articleTitleRange];
    
    // Section text attributes
    UIFont *sectionFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    NSRange sectionRange = [text rangeOfString:_sectionName];
    [attributedText setAttributes:@{NSFontAttributeName: sectionFont}
                            range:sectionRange];
    
    
    // Authors text attributes
    UIFont *authorFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    NSRange authorRange = [text rangeOfString:_sectionName];
    [attributedText setAttributes:@{NSFontAttributeName: authorFont}
                            range:authorRange];
    
    // Article body text attributes
    UIFont *bodyFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    NSRange bodyRange = [text rangeOfString:_articleBody];
    [attributedText setAttributes:@{NSFontAttributeName: bodyFont}
                            range:bodyRange];
    
    
    self.textView.attributedText = attributedText;

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
