//
//  VTViewController.m
//  TestHeli002
//
//  Created by Developer on 05/06/14.
//  Copyright (c) 2014 VT. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "VTViewController.h"

@interface VTViewController ()
{
    NSTimer* timer;
    NSArray* movingObstacles;
    NSArray* staticObstacles;
    NSArray* allObstacles;
    
    int y;
    BOOL isStart;
    BOOL isEnd;
    int ramdomPos;
    
    NSInteger score;
    
    int middle;
    CGPoint startPos;
    
    long highScore;
    
    AVAudioPlayer *audioPlayer;
    
    SystemSoundID soundCrash, soundObstacle;
}

@end

@implementation VTViewController

-(void)collision
{
    for (UIView* v in allObstacles) {
        if(CGRectIntersectsRect(_heli.frame, v.frame)) { [self endGame]; }
    }
}

-(void) newGame
{
    isStart = YES;
    isEnd = NO;
    
    score = 0;
    
    highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HIGH_SCORE"];
    
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)score];
    self.Intro3.text = [NSString stringWithFormat:@"High Score: %ld", (long)highScore];
    
    _heli.image = [UIImage imageNamed:@"HeliUP.png"];
    _heli.center = startPos;
    _heli.hidden = NO;

    [self toggelObstWithBool:YES];
    self.Intro1.hidden = NO;
    self.Intro2.hidden = NO;
    self.Intro3.hidden = NO;
}

-(void) endGame
{
    _heli.image = [UIImage imageNamed:@"HeliCrash.png"];
    [timer invalidate];
    [audioPlayer stop];
    
    AudioServicesPlaySystemSound(soundCrash);

    isEnd = YES;
    
    highScore = score > highScore ? score : highScore;
    [[NSUserDefaults standardUserDefaults] setInteger:highScore forKey:@"HIGH_SCORE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSelector:@selector(newGame) withObject:nil afterDelay:5];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    middle = _top1.frame.size.width * 6.5;
    
    startPos = CGPointMake(_heli.center.x, _heli.center.y);
    
    movingObstacles = [NSArray arrayWithArray:[self.view subviews]];
    movingObstacles = [movingObstacles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d", 99]];
    staticObstacles = [NSArray arrayWithArray:[self.view subviews]];
    staticObstacles = [staticObstacles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d", 88]];
    allObstacles = [staticObstacles arrayByAddingObjectsFromArray:movingObstacles];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Helicopter" ofType:@"mp3"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    
    path = [[NSBundle mainBundle]pathForResource:@"Crash" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath: path]), &soundCrash);

    path = [[NSBundle mainBundle]pathForResource:@"Clink" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath: path]), &soundObstacle);
    
    audioPlayer.delegate = self;
    
    [self newGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - screen orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - Helicopter

-(void)heliMove
{
    _heli.center = CGPointMake(_heli.center.x, _heli.center.y + y);
    
    for (UIView* v in movingObstacles) {
        [self moveObstacle:v];
    }
    
    [self setObstacle:_obst withX:middle];
    [self setObstacle:_obst2 withX:middle];
    
    [self setTop:_top1 withBottom:_bottom1 withX:middle];
    [self setTop:_top2 withBottom:_bottom2 withX:middle];
    [self setTop:_top3 withBottom:_bottom3 withX:middle];
    [self setTop:_top4 withBottom:_bottom4 withX:middle];
    [self setTop:_top5 withBottom:_bottom5 withX:middle];
    [self setTop:_top6 withBottom:_bottom6 withX:middle];
    [self setTop:_top7 withBottom:_bottom7 withX:middle];
    
    [self collision];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(isStart == YES) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(heliMove) userInfo:nil repeats:YES];
        
        self.Intro1.hidden = YES;
        self.Intro2.hidden = YES;
        self.Intro3.hidden = YES;
        
        [self setObstacle:_obst withX:570];
        [self setObstacle:_obst2 withX:855];
        
        double myPos = 560;
        double stride = _top1.frame.size.width;
        
        [self setTop:_top1 withBottom:_bottom1 withX:myPos];
        myPos += stride;
        [self setTop:_top2 withBottom:_bottom2 withX:myPos];
        myPos += stride;
        [self setTop:_top3 withBottom:_bottom3 withX:myPos];
        myPos += stride;
        [self setTop:_top4 withBottom:_bottom4 withX:myPos];
        myPos += stride;
        [self setTop:_top5 withBottom:_bottom5 withX:myPos];
        myPos += stride;
        [self setTop:_top6 withBottom:_bottom6 withX:myPos];
        myPos += stride;
        [self setTop:_top7 withBottom:_bottom7 withX:myPos];
        
        [self toggelObstWithBool:NO];
        
        [audioPlayer play];

        isStart = NO;
    }
    if(isEnd) { return; }
    y = -7;
    _heli.image = [UIImage imageNamed:@"HeliUP.png"];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(isEnd) { return; }
    y = 7;
    _heli.image = [UIImage imageNamed:@"HeliDN.png"];
    
}

#pragma mark - Obstacles

-(void)setObstacle:(UIView*)o withX:(double)x
{
    if(isStart || o.center.x < 0){
        ramdomPos = arc4random() % 75;
        ramdomPos += 110;
        if( o.center.x < 0) {
            self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)++score];
            AudioServicesPlaySystemSound(soundObstacle);
        }
        o.center = CGPointMake(x, ramdomPos);
    }
}

-(void)toggelObstWithBool:(BOOL)t
{
    for (UIView* v in movingObstacles) {
        v.hidden = t;
    }
}

-(void)setTop:(UIView*)top withBottom:(UIView*)bottom withX:(double)x
{
    if (isStart || top.center.x < -_top1.frame.size.width/2.0)
    {
        ramdomPos = arc4random() % 40;
        top.center = CGPointMake(x, ramdomPos);
        bottom.center = CGPointMake(x, ramdomPos + 280);
    }
}

-(void)moveObstacle:(UIView*)o
{
    o.center = CGPointMake(o.center.x - 10, o.center.y);
}

#pragma mark - AudioPlayer

-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [player play];
}

@end
