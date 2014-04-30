//
//  RTViewController.h
//  RecorderTest
//
//  Created by Wukaibing on 30/4/14.
//  Copyright (c) 2014 Wukaibing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

@interface RTViewController : UIViewController<UIScrollViewDelegate>{
    AVAudioRecorder *recorder;
    NSTimer *levelTimer;
    double lowPassResults;
    CGPoint previousPoint;
//    UILabel* number;
    BOOL isPeakPowerSelected;
}

@property (strong,nonatomic) IBOutlet UIScrollView* scrollView;
@property (strong,nonatomic) IBOutlet UILabel* number;
@property (nonatomic,strong) IBOutlet UITableView* numberTableView;

-(IBAction)segmentSelected:(id)sender;

@end
