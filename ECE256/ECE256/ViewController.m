//
//  ViewController.m
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import "ViewController.h"
#import "RIOInterface.h"
#import "KeyHelper.h"
#import "CSVWriter.h"
#import "GryoData.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

#define ACCELEROMETER_SAMPLING_FREQUENCY 100.0
#define MICROPHONE_SAMPLING_FREQUENCY 100.0
#define OBSERVATION_SAMPLING_FREQUENCY 2
#define FILE_NAME @"TestData.csv"

#define MAX_OBSERVATIONS 200


@end

@implementation ViewController

@synthesize	rioRef;
@synthesize currentFrequency;
@synthesize motionManager;
@synthesize gyroHandler;
@synthesize opQ;
@synthesize accelerometer;
@synthesize fileWriter;
@synthesize timer;
@synthesize accelerometerData;
@synthesize gryoscopeData;
@synthesize micFFTData;
@synthesize micPeakData;
@synthesize micAvgData;
@synthesize userTouchedPhone;
@synthesize tapState;
@synthesize tapStateCounter;
@synthesize tableCalibFactor;

@synthesize numOfObservationsLabel;
@synthesize appStatusLabel;
@synthesize calibrationLabel;

@synthesize clearButton;
@synthesize writeButton;
@synthesize startStopButton;
@synthesize calibrationSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableCalibFactor = -1.027;
    [self.calibrationLabel setText:[NSString stringWithFormat:@"%.3f", tableCalibFactor]];

    
    // INIT Microphone FFT
    self.rioRef = [RIOInterface sharedInstance];
    
    // INIT Acclerometer paramters
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = 1.0/ACCELEROMETER_SAMPLING_FREQUENCY;
    self.accelerometer.delegate = self;
    
    // INIT CSV file writing
    self.fileWriter = [[CSVWriter alloc] init];
    
    // INIT Data structures for each frame
    self.accelerometerData = [[NSMutableArray alloc] initWithCapacity:1];
    self.gryoscopeData = [[NSMutableArray alloc] initWithCapacity:1];
    self.micFFTData = [[NSMutableArray alloc] initWithCapacity:1];
    self.micPeakData = [[NSMutableArray alloc] initWithCapacity:1];
    self.micAvgData = [[NSMutableArray alloc] initWithCapacity:1];

    
    // INIT Gryo paramters
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.gyroUpdateInterval = 1.0/ACCELEROMETER_SAMPLING_FREQUENCY;
    if (self.motionManager.gyroAvailable) 
    {
        opQ = [[NSOperationQueue currentQueue] retain];
        self.gyroHandler = ^ (CMGyroData *gyroData, NSError *error) 
        {
            CMRotationRate rotateData = gyroData.rotationRate;
            GryoData *data = [[GryoData alloc] initWithData:rotateData];
            //NSLog(@"%.12f - %.12f - %.12f", rotateData.x, rotateData.y, rotateData.z);
            if(tapState)
                [self.gryoscopeData addObject:data];
        };
    }
    else 
    {
        NSLog(@"No gyroscope on device.");
    }
    
    // INIT Microphone
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
    
  	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
  	if (recorder) {
  		[recorder prepareToRecord];
  		recorder.meteringEnabled = YES;
  		[recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: (1/MICROPHONE_SAMPLING_FREQUENCY) target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES]; // Samples audio ~30 times a second
  	} else
  		NSLog(@"Error");
    
    tapState = NO;
    tapStateCounter = 0;
    [self startCollecitng];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else 
    {
        return YES;
    }
}

- (void) startCollecitng
{
//     self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/OBSERVATION_SAMPLING_FREQUENCY
//                                     target:self
//                                   selector:@selector(sampleObservation:)
//                                   userInfo:nil
//                                    repeats:YES]; 
    
    // Clear old data
    [self.accelerometerData removeAllObjects];
    [self.gryoscopeData removeAllObjects];
    [self.micFFTData removeAllObjects];
    [self.micPeakData removeAllObjects];
    [self.micAvgData removeAllObjects];

    
    observationsCollected = 0;
    [self.numOfObservationsLabel setText:[NSString stringWithFormat:@"%d", observationsCollected]];
    [self.appStatusLabel setText:@"Collecting..."];
    
    [self.motionManager startGyroUpdatesToQueue:opQ withHandler:self.gyroHandler];
    [self.rioRef startListening:self];

}

- (void) stopCollecting
{
    // Stop Timer
    [self.timer invalidate];
    self.timer = nil;
    
    [self.motionManager stopGyroUpdates];
    [self.rioRef stopListening];
}

- (void)frequencyChangedWithValue:(float)newFrequency{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	self.currentFrequency = newFrequency;
    if(tapState)
        [self.micFFTData addObject:[NSNumber numberWithFloat:newFrequency]];
	[pool drain];
	pool = nil;
	
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
    NSLog(@"%.12f", acceleration.z);
    // Add acceleration data to structure
    //[self.accelerometerData addObject:acceleration];
    [self tappedOccured2:acceleration];
}

- (void)levelTimerCallback:(NSTimer *)timer {
	
    [recorder updateMeters];
    if(tapState)
    {
        [self.micPeakData addObject:[NSNumber numberWithDouble:[recorder peakPowerForChannel:0]]];
        [self.micAvgData addObject:[NSNumber numberWithDouble:[recorder averagePowerForChannel:0]]];
    }

    
}

-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event 
{    
    NSSet *allTouches = [event allTouches];
    if([allTouches count] > 0)
    {
        self.userTouchedPhone = true;
    }
}


//- (void) sampleObservation:(NSTimer *) timer 
- (void) sampleObservation 
{    
    // If getting data because user touched phone, then ignore
    //if(!self.userTouchedPhone && [self tappedOccured:self.accelerometerData])
    if(!self.userTouchedPhone)
    {
        NSMutableString *observation_x = [NSMutableString stringWithCapacity:1];
        NSMutableString *observation_y = [NSMutableString stringWithCapacity:1];
        NSMutableString *observation_z = [NSMutableString stringWithCapacity:1];
        
        [observation_x appendString:@"ACCEL_X,"];
        [observation_y appendString:@"ACCEL_Y,"];
        [observation_z appendString:@"ACCEL_Z,"];

        
        for (int i = 0; i <  [accelerometerData count]; i++) 
        {
            UIAcceleration *acceleration = [accelerometerData objectAtIndex:i];
            [observation_x appendString:[NSString stringWithFormat:@"%.12f",acceleration.x]];
            [observation_y appendString:[NSString stringWithFormat:@"%.12f",acceleration.y]];
            [observation_z appendString:[NSString stringWithFormat:@"%.12f",acceleration.z]];
            
            if (i == [accelerometerData count] - 1) 
            {
                [observation_x appendString:@"\n"];
                [observation_y appendString:@"\n"];
                [observation_z appendString:@"\n"];

            }
            else 
            {
                [observation_x appendString:@","];
                [observation_y appendString:@","];
                [observation_z appendString:@","];
            }

        }
        
        [self.fileWriter saveString:observation_x];
        [self.fileWriter saveString:observation_y];
        [self.fileWriter saveString:observation_z];
        
        observation_x = [NSMutableString stringWithCapacity:1];
        observation_y = [NSMutableString stringWithCapacity:1];
        observation_z = [NSMutableString stringWithCapacity:1];
        
        [observation_x appendString:@"GYRO_X,"];
        [observation_y appendString:@"GYRO_Y,"];
        [observation_z appendString:@"GYRO_Z,"];
        
        
        for (int i = 0; i <  [gryoscopeData count]; i++) 
        {
            GryoData *gyration = [gryoscopeData objectAtIndex:i];
            [observation_x appendString:[NSString stringWithFormat:@"%.12f",gyration.x]];
            [observation_y appendString:[NSString stringWithFormat:@"%.12f",gyration.y]];
            [observation_z appendString:[NSString stringWithFormat:@"%.12f",gyration.z]];
            
            if (i == [gryoscopeData count] - 1) 
            {
                [observation_x appendString:@"\n"];
                [observation_y appendString:@"\n"];
                [observation_z appendString:@"\n"];
                
            }
            else 
            {
                [observation_x appendString:@","];
                [observation_y appendString:@","];
                [observation_z appendString:@","];
            }
            
        }
        
        [self.fileWriter saveString:observation_x];
        [self.fileWriter saveString:observation_y];
        [self.fileWriter saveString:observation_z];
        
        NSMutableString *observation_micPeak = [NSMutableString stringWithCapacity:1];
        NSMutableString *observation_micAvg = [NSMutableString stringWithCapacity:1];

        
        [observation_micPeak appendString:@"MIC_PEAK,"];
        [observation_micAvg appendString:@"MIC_AVG,"];

                
        for (int i = 0; i <  [micPeakData count]; i++) 
        {
            double peak =[[micPeakData objectAtIndex:i] doubleValue];
            double avg = [[micAvgData objectAtIndex:i] doubleValue];

            [observation_micPeak appendString:[NSString stringWithFormat:@"%.12f",peak]];
            [observation_micAvg appendString:[NSString stringWithFormat:@"%.12f",avg]];

            
            if (i == [micPeakData count] - 1) 
            {
                [observation_micPeak appendString:@"\n"];
                [observation_micAvg appendString:@"\n"];
                
            }
            else 
            {
                [observation_micPeak appendString:@","];
                [observation_micAvg appendString:@","];
            }
            
        }
        
        [self.fileWriter saveString:observation_micPeak];
        [self.fileWriter saveString:observation_micAvg];

 
        observationsCollected++;
        [self.numOfObservationsLabel setText:[NSString stringWithFormat:@"%d", observationsCollected]];
        
        if(observationsCollected == MAX_OBSERVATIONS)
        {
            [self writeToFile];
        }
    }
    else 
    {
//        NSString *strX = [NSString string];
//        NSString *strY = [NSString string];
//        NSString *strZ = [NSString string];
//        for(int i = 0; i < [accelerometerData count]; i++)
//        {
//            UIAcceleration * ac = [accelerometerData objectAtIndex:i];
//            strX = [strX stringByAppendingFormat:@"%.12f\n", ac.x];
//            strY = [strY stringByAppendingFormat:@"%.12f\n", ac.y];
//            strZ = [strZ stringByAppendingFormat:@"%.12f\n", ac.z];
//        }
//        
//        [strX writeToFile:[fileWriter getFilePath:@"xData3_null.csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
//        [strY writeToFile:[fileWriter getFilePath:@"yData3_null.csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
//        [strZ writeToFile:[fileWriter getFilePath:@"zData3_null.csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    // Clear old data for new frame
    [self.accelerometerData removeAllObjects];
    [self.gryoscopeData removeAllObjects];
    [self.micFFTData removeAllObjects];
    [self.micPeakData removeAllObjects];
    [self.micAvgData removeAllObjects];


    
    self.userTouchedPhone = FALSE;
}

- (IBAction) sliderValueChanged:(UISlider *)sender 
{  
    tableCalibFactor = [sender value];
    [self.calibrationLabel setText:[NSString stringWithFormat:@"%.3f", tableCalibFactor]];
}

- (void) writeToFile
{
    [self.appStatusLabel setText:@"Writing..."];
    [self.fileWriter writeFile:FILE_NAME];
    [self.appStatusLabel setText:@"DONE!"];
    [self clearData];
}

- (void) clearData
{
    [self stopCollecting];
    [self.accelerometerData removeAllObjects];
    [self.gryoscopeData removeAllObjects];
    [self.micFFTData removeAllObjects];
    [self.micPeakData removeAllObjects];
    [self.micAvgData removeAllObjects];
    [fileWriter clear];
    observationsCollected = 0;
    [self.numOfObservationsLabel setText:[NSString stringWithFormat:@"%d", observationsCollected]];
}

- (IBAction) doClearButton;
{
    [self clearData];

}
- (IBAction) doWriteButton
{
    [self writeToFile];
}

- (bool) tappedOccured:(NSMutableArray *) acceleration
{
    for(int i = 0; i < [acceleration count]; i++)
    {
        //NSLog(@"x: %f", [[acceleration objectAtIndex:i] x]);
        //NSLog(@"y: %f", [[acceleration objectAtIndex:i] y]);
        //NSLog(@"z: %f", [[acceleration objectAtIndex:i] z]);
        if([[acceleration objectAtIndex:i] z] < tableCalibFactor)
        {
            //NSLog(@"YEE - %.12f", [[acceleration objectAtIndex:i] z]);
            return true;
        }
    }
    
    return FALSE;
}

- (void) tappedOccured2:(UIAcceleration *)acceleration 
{
    if(!tapState)
    {
        if([acceleration z] < tableCalibFactor)
        {
               // NSLog(@"Begin Tap - %.12f", [acceleration z]);
                tapState = YES;
                tapStateCounter = 0;
                [self.accelerometerData addObject:acceleration];
        }   
    }
    else 
    {
        tapStateCounter++;
        [self.accelerometerData addObject:acceleration];
        
        if (tapStateCounter == 15)
        {
            tapState = NO;
            tapStateCounter = 0;
            //NSLog(@"End Tap - %.12f", [acceleration z]);
            [self sampleObservation];
        }
    }
}

- (void) dealloc
{
    [self.fileWriter release];
    self.fileWriter = nil;
    
    [motionManager release];
    self.motionManager = nil;
    
    [self.opQ release];
    self.opQ = nil;
    
    [self.accelerometerData release];
    self.accelerometerData = nil;
    
    [self.gryoscopeData release];
    self.gryoscopeData = nil;
    
    [self.micFFTData release];
    self.micFFTData = nil;
    
    [self.micPeakData release];
    self.micPeakData = nil;
    
    [self.micAvgData release];
    self.micAvgData = nil;
    
    [super dealloc];
}

@end
