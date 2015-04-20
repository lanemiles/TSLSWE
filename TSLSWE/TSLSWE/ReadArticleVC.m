//
//  ReadArticleVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/15/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "ReadArticleVC.h"
#import <AVFoundation/AVFoundation.h>

@interface ReadArticleVC ()
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *articleTitle;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSString *authorNames;
@property (strong, nonatomic) NSString *articleBody;
@property (strong, nonatomic) NSString *articleDate;
@property (strong, nonatomic) NSString *articleURL;
@property bool hasFavorited;

@property (strong, nonatomic) UIActivityViewController *activityViewController;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@end

@implementation ReadArticleVC
- (IBAction)didPressShare:(UIBarButtonItem *)sender {
    
    NSString *str = @"I just read this great article in the TSL and thought you might like it too! \n";
    NSURL *url = [NSURL URLWithString:_articleURL];
    
    
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[str, url] applicationActivities:nil];
    
    [self presentViewController:self.activityViewController animated:YES completion:nil];
}
- (IBAction)didFavoriteArticle:(id)sender {
    
    UIBarButtonItem *send = (UIBarButtonItem*) sender;
    
    if (_hasFavorited) {
        
        NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        NSString *urlStr = [NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/removeFavorite/%@/%@", uuid, _articleId];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        
        dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
        dispatch_async(concurrentQueue, ^{
            
            NSError *err;
            NSString *data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star"] style:UIBarButtonItemStylePlain target:self action:@selector(didFavoriteArticle:)];
                pause.style = UIBarButtonItemStylePlain;
                pause.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
                NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
                
                temp[0] = pause;
                NSArray *good = [temp copy];
                
                
                
                [_toolbar setItems:good];
                _hasFavorited = false;
                
            });
            
            
        });
        
    } else {
        
        NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        NSString *urlStr = [NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/addFavorite/%@/%@", uuid, _articleId];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        
        dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
        dispatch_async(concurrentQueue, ^{
            
            NSError *err;
            NSString *data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"starfilled"] style:UIBarButtonItemStylePlain target:self action:@selector(didFavoriteArticle:)];
                pause.style = UIBarButtonItemStylePlain;
                pause.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
                NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
                
                temp[0] = pause;
                NSArray *good = [temp copy];
                
                
                [_toolbar setItems:good];
                
            });
            
            
        });
        
    }
    
   

    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [_speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [self getArticleDataWithIDNumber: _articleId];
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];

    
    
    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];

}

- (IBAction)speakText:(UIBarButtonItem *)sender {
    NSString *string = _textView.text;
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    
    utterance.rate = .20;

    
    if (!_speechSynthesizer.isPaused && !_speechSynthesizer.isSpeaking) {
        [_speechSynthesizer speakUtterance:utterance];
        UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(speakText:)];
        pause.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
        pause.style = UIBarButtonItemStylePlain;
        
        NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
        [temp removeLastObject];
        [temp addObject:pause];
        NSArray *good = [temp copy];
        [_toolbar setItems:good];
    } else if (_speechSynthesizer.isPaused) {
        [_speechSynthesizer continueSpeaking];
        
        UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(speakText:)];
        pause.style = UIBarButtonItemStylePlain;
        pause.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
        
        NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
        [temp removeLastObject];
        [temp addObject:pause];
        NSArray *good = [temp copy];
        
        
        [_toolbar setItems:good];
    } else {
        [_speechSynthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        
        UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(speakText:)];
        pause.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
        pause.style = UIBarButtonItemStylePlain;
        
        NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
        [temp removeLastObject];
        [temp addObject:pause];
        NSArray *good = [temp copy];
        
        
        [_toolbar setItems:good];
    }
    
    

    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getArticleDataWithIDNumber: (NSString*) articleId {
        dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
        dispatch_async(concurrentQueue, ^{
            NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/articles/%@/%@", uuid, articleId]];
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
                _articleURL = [temp valueForKey:@"url"];
                
                
                NSString *favorited = [temp valueForKey:@"favorited"];
                if ([favorited isEqualToString:@"false"]) {
                    _hasFavorited = false;
                } else {
                    _hasFavorited = true;
                }

                
                if (error == nil) {
                    
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setText];
                if (_hasFavorited) {
                    UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"starfilled"] style:UIBarButtonItemStylePlain target:self action:@selector(didFavoriteArticle:)];
                    pause.style = UIBarButtonItemStylePlain;
                    pause.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
                    NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
                    
                    temp[0] = pause;
                    NSArray *good = [temp copy];
                    
                    
                    [_toolbar setItems:good];
                }
            });
            
            
        });
}


- (void) setText {
    
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];

    
 
    NSString *text = [NSString stringWithFormat:@"%@\n\n%@\n%@\n%@\n\n%@",
                      _articleTitle, [_sectionName uppercaseString], _articleDate, _authorNames, _articleBody];
    
    // If attributed text is supported (iOS6+)
    
    // Define general attributes for the entire text
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text];
    
    // Article Title attributes
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:(22 + offset)];
    NSRange articleTitleRange = [text rangeOfString:_articleTitle];
    [attributedText setAttributes:@{NSFontAttributeName: titleFont}
                            range:articleTitleRange];
    
    // Section text attributes
    UIFont *sectionFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:(12 + offset)];
    NSRange sectionRange = [text rangeOfString:[_sectionName uppercaseString]];
    [attributedText setAttributes:@{NSFontAttributeName: sectionFont}
                            range:sectionRange];
    
    // Date text attributes
    UIFont *dateFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:(12 + offset)];
    NSRange dateRange = [text rangeOfString:_articleDate];
    [attributedText setAttributes:@{NSFontAttributeName: dateFont}
                            range:dateRange];
    
    
    // Authors text attributes
    UIFont *authorFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:(12 + offset)];
    NSRange authorRange = [text rangeOfString:_authorNames];
    [attributedText setAttributes:@{NSFontAttributeName: authorFont}
                            range:authorRange];
    
    // Article body text attributes
    UIFont *bodyFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:(16 + offset)];
    NSRange bodyRange = [text rangeOfString:_articleBody];
    [attributedText setAttributes:@{NSFontAttributeName: bodyFont}
                            range:bodyRange];
    
    
    self.textView.attributedText = attributedText;
    
    

}
- (IBAction)fontSizeIncrease:(UIBarButtonItem *)sender {
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
    offset = offset + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:offset forKey:@"FontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setText];
}
- (IBAction)fontSizeDecrease:(UIBarButtonItem *)sender {
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
    offset = offset - 1;
    [[NSUserDefaults standardUserDefaults] setInteger:offset forKey:@"FontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setText];
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
