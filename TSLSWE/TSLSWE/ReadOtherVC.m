//
//  ReadOtherVC.m
//  TSLSWE
//
//  Created by Lane Miles on 4/20/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "ReadOtherVC.h"
#import <AVFoundation/AVFoundation.h>

@interface ReadOtherVC ()

//textview to display text
@property (strong, nonatomic) IBOutlet UITextView *textView;

//bottom toolbar
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

//speech synth for reading
@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;

//text for uitextview
@property (strong, nonatomic) NSString *text;

@end

@implementation ReadOtherVC

#pragma mark - View Controller Life Cycle Methods


//here we initalize our AVSpeechSynthesizer instance variable which is used to read the text outloud
//we need to declare this as an ivar so we can stop it in viewWillDisappear so it doesn't read after we
//leave the page
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
}

//because this page will either be showing the about or contact text, we just check the NSString set
//in the segue
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    if ([_otherName isEqualToString:@"About"]) {
        _text = @"The Student Life, the oldest college newspaper in Southern California, is student-written and managed. It is published weekly by the Associated Students of Pomona College for the Claremont Colleges.\n\nLetters to the Editor can be submitted by mail, e-mail, or in person at Walker Hall room 101. TSL will publish letters under 400 words (although when an issue is particularly salient, we reserve the right to allow letters to run at a longer length) submitted by 4:00 p.m. Wednesday of the week of publication. We will not accept anonymous letters, letters containing profanity, or letters making personal attacks, and we reserve the right to edit spelling, punctuation, and serious grammatical errors. Letters may be signed by a maximum of three persons. All letters become the property of TSL.\n\nStaff\n\nEditor-in-Chief: Julia Thomas\nManaging Editor for Content: Rachel Lang\nManaging Editor for Production: Kevin Tidmarsh\nSenior Design Editors: Helena Shannon, Soyoung Eom\nSenior Development Manager: Zoë Jameson\nSenior Staff Manager: \nSenior Digital Editor: \nSenior Copy Editor: Rhian Moore\n\nNews Editor: Diane Lee\nNews Section Manager: Benji Lu\nLife & Style Editor: Alec Long \nOpinions Editor: Alexa Strabuk \nSports Editors: Sean Cremin, Griffin Ferre\n\nNews Design Editors: Audrey Liu\nLife & Style Design Editor: Mehron Abdi \nOpinions Design Editor: Sophia Fang\nSports Design Editor: Jessica Wang\n\nNews Copy Editor: Dixie Morrison\nLife & Style Copy Editor: Luke Miller \nOpinions Copy Editor: Gloria Liou \nSports Copy Editor: Mattie Toll\n\nPhotography Editor: Rachel Lacey Noll \nPhotography Manager: Tim Hernandez\nVisual Editor: Latina Vidolova \nGraphics Editor: Chloe An \nSocial Media Manager: Maddie Glouner\nDistribution Manager: Lianne Parker\nBusiness Manager: John Kim \nAdvertising Manager: Guan Wang \nWeb Developers: Ziqi Xiong, Kent Shikama, Cai Glencross";
        self.title = @"About";
    } else {
        _text = @"The Student Life\nSmith Campus Center\nPomona College\nClaremont, CA 91711\n\nE-mail: editor@tsl.pomona.edu\n\nPlease e-mail news tips to news@tsl.pomona.edu.\n\nFor advertising inquiries e-mail business@tsl.pomona.edu.\n\nLetters to the Editor can be submitted by mail, e-mail, or in person at Walker Hall room 101. TSL will publish letters under 400 words (although when an issue is particularly salient, we reserve the right to allow letters to run at a longer length) submitted by 4:00 p.m. Wednesday of the week of publication. We will not accept anonymous letters, letters containing profanity, or letters making personal attacks, and we reserve the right to edit spelling, punctuation, and serious grammatical errors. Letters may be signed by a maximum of three persons. All letters become the property of TSL.";
        self.title = @"Contact";
    }
    
    [self setText];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [_speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setting Text Methods
- (void) setText {

    //get the user font size preference
    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
   
    //for attriubted string reasons
    NSString *text = _text;

    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:_text];
    
    //text attributes
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16+offset];
    NSRange textRange = [text rangeOfString:_text];
    [attributedText setAttributes:@{NSFontAttributeName: font}
                            range:textRange];
    
    //set textview text
    _textView.attributedText = attributedText;
    
    //scroll to top
    [self.textView scrollRangeToVisible:NSMakeRange(0,0)];

}


#pragma mark - Speaking Text Methods
- (IBAction)speakText:(UIBarButtonItem *)sender {
    
    //set the text to speak to be the text view text
    NSString *string = _textView.text;
    
    //create utterance
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



@end
