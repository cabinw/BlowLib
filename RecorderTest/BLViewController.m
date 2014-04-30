//
//  RTViewController.m
//  RecorderTest
//
//  Created by Wukaibing on 30/4/14.
//  Copyright (c) 2014 Wukaibing. All rights reserved.
//

#import "RTViewController.h"

@interface RTViewController ()

@end

@implementation RTViewController
@synthesize scrollView;
@synthesize number;

int gap = 3;
int showWidth = 280;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    previousPoint = CGPointMake(0, 160);
    
//    number = [[UILabel alloc] initWithFrame:CGRectMake(210, 10, 120, 20)];
//    [number setTextColor:[UIColor whiteColor]];
//    [scrollView addSubview:number];
    scrollView.delegate = self;
    
    isPeakPowerSelected = false;
    
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    // iOS7 porting
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    //===============
    
    if (recorder) {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:)
                                                    userInfo: nil repeats: YES];
    }

}
-(void) viewDidAppear:(BOOL)animated{
    scrollView.contentSize = CGSizeMake(320, 200);
}

-(void) drawLineFrom:(CGPoint) startPoint to:(CGPoint)endPoint withColor:(UIColor*) color{
    
    // Line
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    if (color == nil) {
        shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    }else {
        shapeLayer.strokeColor = [color CGColor];
        [self drawCircleInPosition:startPoint];
    }
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [scrollView.layer addSublayer:shapeLayer];
}

-(void) drawCircleInPosition:(CGPoint) position{
    // Set up the shape of the circle
    int radius = 2;
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, radius, radius)
                                             cornerRadius:radius].CGPath;
    // Center the shape in self.view
    circle.position = CGPointMake(position.x-radius/2, position.y-radius/2);
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor redColor].CGColor;
    circle.lineWidth = 2;
    
    // Add to parent layer
    [scrollView.layer addSublayer:circle];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 1.0; // "animate over 10 seconds or so.."
    drawAnimation.repeatCount         = 1.0;  // Animate only once..
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    // Experiment with timing to get the appearence to look the way you want
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // Add the animation to the circle
    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
}

- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
    if (isPeakPowerSelected) {
        lowPassResults = [recorder peakPowerForChannel:0];
    }else{
        lowPassResults = [recorder averagePowerForChannel:0];
    }
//    lowPassResults = [recorder peakPowerForChannel:0];
//    lowPassResults = [recorder averagePowerForChannel:0];
    
    double value = 200 - (160+lowPassResults)+50;
    
    [number setText:[NSString stringWithFormat:@"%f",(160+lowPassResults)+50]];
    
    CGPoint currentPoint = CGPointMake(previousPoint.x+gap, value);
    if ((160+lowPassResults)+50 >= 200) {
        [self drawLineFrom:previousPoint to:currentPoint withColor:[UIColor redColor]];
    }else{
        [self drawLineFrom:previousPoint to:currentPoint withColor:nil];
    }
    
    
//    NSLog(@"current point x: %.0f",currentPoint.x);
//    NSLog(@"content witdth: %0.f",scrollView.contentSize.width);
    
    
    if (currentPoint.x >= showWidth) {
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width+gap, scrollView.contentSize.height);
//        [number setCenter:CGPointMake(number.center.x+gap, number.center.y)];
        [scrollView scrollRectToVisible:CGRectMake(currentPoint.x-showWidth, 0, 320, 200) animated:true];
//        [scrollView setContentOffset:CGPointMake(currentPoint.x-showWidth, 0) animated:YES];
    }
    
    NSLog(@"label x: %f",number.center.x);
    
    previousPoint = currentPoint;
    
    
}

-(IBAction)segmentSelected:(id)sender{
    UISegmentedControl* temp = (UISegmentedControl*) sender;
    if(temp.selectedSegmentIndex == 0){
        isPeakPowerSelected = true;
	}else{
        isPeakPowerSelected = false;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end