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
#import <AVFoundation/AVFoundation.h>

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
    NSMutableArray *micFFTData;
    NSMutableArray *micPeakData;
    NSMutableArray *micAvgData;
    BOOL userTouchedPhone;
    BOOL tapState;
    int tapStateCounter;


    int observationsCollected;
    
    IBOutlet UILabel *numOfObservationsLabel;
    IBOutlet UILabel *appStatusLabel;
    
    AVAudioRecorder *recorder; // Set up AVAudioRecorder instance variable
    NSTimer *levelTimer;

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
@property (nonatomic, retain) NSMutableArray *micFFTData;
@property (nonatomic, retain) NSMutableArray *micPeakData;
@property (nonatomic, retain) NSMutableArray *micAvgData;
@property (nonatomic) BOOL userTouchedPhone;
@property (nonatomic) BOOL tapState;
@property (nonatomic) int tapStateCounter;
@property (nonatomic, retain) IBOutlet UILabel *numOfObservationsLabel;
@property (nonatomic, retain) IBOutlet UILabel *appStatusLabel;


@end
