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
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property (strong, nonatomic) NSString *text;

@end

@implementation ReadOtherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [_speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setText {

    long offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
   
    NSString *text = _text;
    
    // If attributed text is supported (iOS6+)
    
    // Define general attributes for the entire text
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:_text];
    
    // Article Title attributes
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16+offset];
    NSRange textRange = [text rangeOfString:_text];
    [attributedText setAttributes:@{NSFontAttributeName: font}
                            range:textRange];
    
    _textView.attributedText = attributedText;
    
    [self.textView scrollRangeToVisible:NSMakeRange(0,0)];

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
