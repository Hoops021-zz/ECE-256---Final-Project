//
//  ViewController.h
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSVWriter;

@interface ViewController : UIViewController <UIAccelerometerDelegate>
{
    UIAccelerometer *accelerometer;
    CSVWriter *fileWriter;
    NSTimer *timer;
    
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *stopButton;
}

@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (nonatomic, retain) CSVWriter *fileWriter;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;

- (IBAction) startButtonPressed:(id)sender;

- (IBAction) stopButtonPressed:(id)sender;

- (void) SampleFeature:(NSTimer *) timer;

@end
