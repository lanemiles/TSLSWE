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

//the text view which holds all displaying text
@property (strong, nonatomic) IBOutlet UITextView *textView;

//properties of the article that go in the textview
@property (strong, nonatomic) NSString *articleTitle;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSString *authorNames;
@property (strong, nonatomic) NSString *articleBody;
@property (strong, nonatomic) NSString *articleDate;
@property (strong, nonatomic) NSString *articleURL;

//if they have favorited
@property bool hasFavorited;

//share screen
@property (strong, nonatomic) UIActivityViewController *activityViewController;

//toolbar
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

//speech synth for reading
@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;

//spinner for loading
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

//boolean for not spinning when coming back from UIActivityIndicator
@property bool shouldNotSpin;

@end

@implementation ReadArticleVC

#pragma mark - View Controller Life Cycle Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //set up the spinner
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.backgroundColor = [UIColor whiteColor];
    _spinner.color = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
    
    
    //set up the speech synth
    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    
    //set up tap to hide controls
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls:)];
    [self.view addGestureRecognizer:gesture];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    //start the spinner if needed
    if (!_shouldNotSpin) {
        _spinner.center=self.view.center;
        [self.view addSubview:_spinner];
        [_spinner startAnimating];
    }
    
    //else, we just came back from the UIActivityThing and should spin next time
    else {
        _shouldNotSpin = NO;
    }
    
    
    //start the async data grab
    [self getArticleDataWithIDNumber: _articleId];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:YES];
    
    //if speaking, stop
    [_speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Share Methods
- (IBAction)didPressShare:(UIBarButtonItem *)sender {
    
    //set the string to be displayed with URL
    NSString *str = @"I just read this great article in the TSL and thought you might like it too!\n";
    
    //set the URL on the TSL's real website
    NSURL *url = [NSURL URLWithString:_articleURL];
    
    //create and show the share screen
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[str, url] applicationActivities:nil];
    
    _shouldNotSpin = YES;
    
    [self presentViewController:self.activityViewController animated:YES completion:nil];
    
}

#pragma mark - Favorite Methods
- (IBAction)didFavoriteArticle:(id)sender {
    
    //will need this for the URLs
    NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    
    //if they have favorited, we want to unfavorite, and change icon to not filled
    if (_hasFavorited) {
        
        //create our URL for removing the favorite
        NSString *urlStr = [NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/removeFavorite/%@/%@", uuid, _articleId];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        //want to do this in the background, so create the queue
        dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
        
        //get the queue
        dispatch_async(concurrentQueue, ^{
            
            //go do the GET request
            NSError *err;
            [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
            
            //get the main queue for UI updating
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //update the star to be empty
                UIBarButtonItem *notFilledIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star"] style:UIBarButtonItemStylePlain target:self action:@selector(didFavoriteArticle:)];
                notFilledIcon.style = UIBarButtonItemStylePlain;
                notFilledIcon.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
                
                //override toolbar items
                NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
                temp[0] = notFilledIcon;
                NSArray *good = [temp copy];
                [_toolbar setItems:good];
                
                //set has favorited to be false
                _hasFavorited = false;
                
            });
            
            
        });
        
    }
    
    //if they have not favorited, we want to favorite the article
    else {
        
        //create our URL for adding the favorite
        NSString *urlStr = [NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/addFavorite/%@/%@", uuid, _articleId];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        //want to do this in the background
        dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
        
        //get the queue
        dispatch_async(concurrentQueue, ^{
            
            //do the GET request
            NSError *err;
            [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
            
            //get the main queue for UI updating
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //set favorite icon to be filled
                UIBarButtonItem *filledIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"starfilled"] style:UIBarButtonItemStylePlain target:self action:@selector(didFavoriteArticle:)];
                filledIcon.style = UIBarButtonItemStylePlain;
                filledIcon.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
                
                //override toolbar items
                NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
                temp[0] = filledIcon;
                NSArray *good = [temp copy];
                [_toolbar setItems:good];
                
                //set favorited to be true
                _hasFavorited = true;
                
            });
            
            
        });
        
    }
    
}


#pragma mark - Speak Text Methods
- (IBAction)speakText:(UIBarButtonItem *)sender {
    
    //set the text to be the article and metadata
    NSString *string = _textView.text;
    
    //create the utterance
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    utterance.rate = .20;
    
    //will need this to update the button
    UIBarButtonItem *newButton;
    
    //if we haven't started playing at all yet
    if (!_speechSynthesizer.isPaused && !_speechSynthesizer.isSpeaking) {
        
        //start reading
        [_speechSynthesizer speakUtterance:utterance];
        
        //make the button a pause icon
        newButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(speakText:)];
        newButton.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
        newButton.style = UIBarButtonItemStylePlain;
        
    }
    
    //if it is currently paused, we want to restart playing from where we left out
    else if (_speechSynthesizer.isPaused) {
        
        //continue speaking
        [_speechSynthesizer continueSpeaking];
        
        
        //turn the icon back into a play button
        newButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(speakText:)];
        newButton.style = UIBarButtonItemStylePlain;
        newButton.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
        
    }
    
    //else, we are currently playing and need to pause
    else {
        
        //pause immediately
        [_speechSynthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        
        //and turn button into a play button
        newButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(speakText:)];
        newButton.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
        newButton.style = UIBarButtonItemStylePlain;
    }
    
    //override toolbar icon
    NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
    [temp removeLastObject];
    [temp addObject:newButton];
    NSArray *good = [temp copy];
    [_toolbar setItems:good];
    
}

#pragma mark - Get Article Data
- (void) getArticleDataWithIDNumber: (NSString*) articleId {
    
    //we want to do this in a non-blocking thread
    dispatch_queue_t concurrentQueue = dispatch_queue_create("JSONQueue", NULL);
    
    //get the thread
    dispatch_async(concurrentQueue, ^{
        
        //get the URL for the article given our device
        //need our device to know if we have favorited it or not
        NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tslswe.pythonanywhere.com/articles/%@/%@", uuid, articleId]];
        
        //get the JSON
        NSError *err;
        NSString *test = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        
        //convert to NSData
        NSData *jsonData = [test dataUsingEncoding:NSUTF8StringEncoding];
        
        //if we have data
        if(jsonData != nil) {
            
            //unserialize the data
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
            
            //parse the JSON and set ivars
            NSDictionary *temp = [result valueForKey:@"fields"];
            _articleTitle = [temp valueForKey:@"headline"];
            _sectionName = [temp valueForKey:@"section"];
            
            //turn author list into a string
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
            
            //get the rest of the data
            _articleDate = [temp valueForKey:@"pub_date"];
            _articleBody = [temp valueForKey:@"article_body"];
            _articleURL = [temp valueForKey:@"url"];
            
            //determine if has favorited
            NSString *favorited = [temp valueForKey:@"favorited"];
            if ([favorited isEqualToString:@"false"]) {
                _hasFavorited = false;
            } else {
                _hasFavorited = true;
            }
            
        }
        
        //get the main thread to do UI updating
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //set the text given what we parsed
            [self setText];
            
            //if we have favorited the article, set to be filled
            if (_hasFavorited) {
                UIBarButtonItem *filledIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"starfilled"] style:UIBarButtonItemStylePlain target:self action:@selector(didFavoriteArticle:)];
                filledIcon.style = UIBarButtonItemStylePlain;
                filledIcon.tintColor = [UIColor colorWithRed:.054 green:.478 blue:.733 alpha:1];
                
                //override the toolbar items
                NSMutableArray *temp = [NSMutableArray arrayWithArray:_toolbar.items];
                temp[0] = filledIcon;
                NSArray *good = [temp copy];
                [_toolbar setItems:good];
                
            }
            
            //and stop spinning
            [_spinner stopAnimating];
            
        });
        
    });
}


#pragma mark - Set Text Methods
- (void) setText {
    
    //get the user font size preference
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
    
    //our uitextview is really just showing 5 strings concatenated with a bunch of newlines added
    NSString *text = [NSString stringWithFormat:@"%@\n\n%@\n%@\n%@\n\n%@",
                      _articleTitle, [_sectionName uppercaseString], _articleDate, _authorNames, _articleBody];
    
 
    //create the attributed string
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
    
    
    //set the textview text to our new attributed string
    self.textView.attributedText = attributedText;
    
}

#pragma mark - Adjusting Font Size Methods
- (IBAction)fontSizeIncrease:(UIBarButtonItem *)sender {
    
    //get default, increment, and save back
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
    offset = offset + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:offset forKey:@"FontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //update text with new size
    [self setText];
}
- (IBAction)fontSizeDecrease:(UIBarButtonItem *)sender {
    
    //get default, decrement, and save back
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
    offset = offset - 1;
    [[NSUserDefaults standardUserDefaults] setInteger:offset forKey:@"FontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //update text with new size
    [self setText];
}


#pragma mark - Toggle Showing/Hiding Controls
- (void)toggleControls:(UITapGestureRecognizer *)gesture {
    
    //hide and show the navigation controls on the top
    BOOL navHidden = self.navigationController.navigationBar.hidden;
    [self.navigationController setNavigationBarHidden:!navHidden animated:YES];
    
    //hide and show the toolbar at the bottom
    BOOL toolbarHidden = self.toolbar.hidden;
    //if not hidden, hide the toolbar
    if (!toolbarHidden) {
        self.textView.frame =CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height+44);
        self.toolbar.hidden = YES;
    }
    
    //if hidden, show the toolbar again
    else {
        self.textView.frame =CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height);
        self.toolbar.hidden = NO;
    }
    
}


@end
