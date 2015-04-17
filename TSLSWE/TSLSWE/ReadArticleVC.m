//
//  ReadArticleVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/15/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "ReadArticleVC.h"
#import "NSString+HTML1.h"

@interface ReadArticleVC ()
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *articleTitle;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSString *authorNames;
@property (strong, nonatomic) NSString *articleBody;
@property (strong, nonatomic) NSString *articleDate;
@end

@implementation ReadArticleVC

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [self getArticleDataWithIDNumber: _articleId];
        NSLog(@"%@", _articleId);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getArticleDataWithIDNumber: (NSString*) articleId {
        dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
        dispatch_async(concurrentQueue, ^{
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/articles/%@", articleId]];
            NSError *err;
            NSString *test = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];

            NSData *jsonData = [test dataUsingEncoding:NSUTF8StringEncoding];
        
     
            
            if(jsonData != nil) {
                NSError *error = nil;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
                
               
                
                NSDictionary *temp = [result valueForKey:@"fields"];
                _articleTitle = [temp valueForKey:@"headline"];
                _sectionName = [temp valueForKey:@"section"];
                
                
                NSArray *authors = [temp valueForKey:@"authors"];
                NSLog(@"%@", authors);
                NSString *by = @"By ";
                for (int i = 0; i < authors.count; i++) {
                    if (i != authors.count - 1) {
                        by = [by stringByAppendingString:[NSString stringWithFormat:@"%@ and ", authors[i]]];
                    } else {
                        by = [by stringByAppendingString:[NSString stringWithFormat:@"%@", authors[i]]];
                    }
                }
                
                _authorNames = by;
                _articleDate = [temp valueForKey:@"pub_date"];
                _articleBody = [temp valueForKey:@"article_body"];
                
                NSLog(@"%@", error);
                
                if (error == nil) {
                    
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setText];
            });
            
            
        });
}


- (void) setText {
    NSString *text = [NSString stringWithFormat:@"%@ \n \n%@ \n%@ \n%@ \n \n%@",
                      _articleTitle, [_sectionName uppercaseString], _articleDate, _authorNames, _articleBody];
    
    // If attributed text is supported (iOS6+)
    
    // Define general attributes for the entire text
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text];
    
    // Article Title attributes
    UIFont *titleFont = [UIFont fontWithName:@"Georgia-Bold" size:20];
    NSRange articleTitleRange = [text rangeOfString:_articleTitle];
    [attributedText setAttributes:@{NSFontAttributeName: titleFont}
                            range:articleTitleRange];
    
    // Section text attributes
    UIFont *sectionFont = [UIFont fontWithName:@"Georgia" size:14];
    NSRange sectionRange = [text rangeOfString:[_sectionName uppercaseString]];
    [attributedText setAttributes:@{NSFontAttributeName: sectionFont}
                            range:sectionRange];
    
    // Date text attributes
    UIFont *dateFont = [UIFont fontWithName:@"Georgia" size:14];
    NSRange dateRange = [text rangeOfString:_articleDate];
    [attributedText setAttributes:@{NSFontAttributeName: dateFont}
                            range:dateRange];
    
    
    // Authors text attributes
    UIFont *authorFont = [UIFont fontWithName:@"Georgia" size:14];
    NSRange authorRange = [text rangeOfString:_authorNames];
    [attributedText setAttributes:@{NSFontAttributeName: authorFont}
                            range:authorRange];
    
    // Article body text attributes
    UIFont *bodyFont = [UIFont fontWithName:@"Georgia" size:14];
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
