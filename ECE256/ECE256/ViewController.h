//
//  ViewController.h
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIODelegate.h"

#import <CoreMotion/CoreMotion.h>
@class RIOInterface;

@class CSVWriter;


@interface ViewController : UIViewController <RIODelegate,UIAccelerometerDelegate>
{
    RIOInterface *rioRef;
    float currentFrequency;
    CMMotionManager *motionManager;
    CMGyroHandler gyroHandler;
    NSOperationQueue *opQ;
    
    UIAccelerometer *accelerometer;
    CSVWriter *fileWriter;
    NSTimer *timer;
    
    NSMutableArray *accelerometerData;
    NSMutableArray *gryoscopeData;
    
    BOOL userTouchedPhone;
    
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *stopButton;
}

@property(nonatomic, assign) RIOInterface *rioRef;
@property(nonatomic, assign) float currentFrequency;
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic) CMGyroHandler gyroHandler;
@property (nonatomic, retain) NSOperationQueue *opQ;

@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (nonatomic, retain) CSVWriter *fileWriter;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) NSMutableArray *accelerometerData;
@property (nonatomic, retain) NSMutableArray *gryoscopeData;

@property (nonatomic) BOOL userTouchedPhone;

@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;

- (IBAction) startButtonPressed:(id)sender;

- (IBAction) stopButtonPressed:(id)sender;

- (void) SampleFeature:(NSTimer *) timer;

@end
