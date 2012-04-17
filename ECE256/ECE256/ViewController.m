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
#import "Observation.h"
#import "CSVWriter.h"
#import "GryoData.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

#define ACCELEROMETER_SAMPLING_FREQUENCY 90.0
#define MICROPHONE_SAMPLING_FREQUENCY 90.0
#define OBSERVATION_SAMPLING_FREQUENCY 1 
#define FILE_NAME @"TestData.csv"

#define MAX_OBSERVATIONS 3
#define TABLE_CALIBRATION_FACTOR .985


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
@synthesize micData;
@synthesize userTouchedPhone;

@synthesize numOfObservationsLabel;
@synthesize appStatusLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.micData = [[NSMutableArray alloc] initWithCapacity:1];
    
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
     self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/OBSERVATION_SAMPLING_FREQUENCY
                                     target:self
                                   selector:@selector(SampleObservation:)
                                   userInfo:nil
                                    repeats:YES]; 
    
    // Clear old data
    [self.accelerometerData removeAllObjects];
    [self.gryoscopeData removeAllObjects];
    [self.micFFTData removeAllObjects];
    [self.micData removeAllObjects];
    
    observationsCollected = 0;
    [self.numOfObservationsLabel setText:[NSString stringWithFormat:@"%d", observationsCollected]];
    [self.appStatusLabel setText:@"Collecting..."];
    
    [self.motionManager startGyroUpdatesToQueue:opQ withHandler:self.gyroHandler];
    [self.rioRef startListening:self];

}
- (void)frequencyChangedWithValue:(float)newFrequency{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	self.currentFrequency = newFrequency;
    [self.micFFTData addObject:[NSNumber numberWithFloat:newFrequency]];
	[pool drain];
	pool = nil;
	
}

- (void) stopCollecting
{
    // Stop Timer
    [self.timer invalidate];
    self.timer = nil;
    
    [self.motionManager stopGyroUpdates];
    [self.rioRef stopListening];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
    // Add acceleration data to structure
    [self.accelerometerData addObject:acceleration];
}

- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
    
    //const double ALPHA = 0.05;
	//double peakPowerForChannel = pow(10, (ALPHA * [recorder peakPowerForChannel:0]));
    
    [self.micData addObject:[NSNumber numberWithDouble:[recorder peakPowerForChannel:0]]];

	//lowPassResultsOffset = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResultsOffset;	
    
    //lowPassResults = ALPHA * [recorder peakPowerForChannel:0] + (1.0 - ALPHA) * lowPassResults;	
    
	//NSLog(@"%f %f %f" ,[recorder peakPowerForChannel:0], lowPassResults, lowPassResultsOffset);
    // Sending the updateMeters message refreshes the average and peak power meters. The meter use a logarithmic scale, with -160 being complete quiet and zero being maximum input.
    
    //  if (lowPassResults > 0.95)
	// 	NSLog(@"Mic blow detected");
    
}

-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event 
{    
    NSSet *allTouches = [event allTouches];
    if([allTouches count] > 0)
    {
        self.userTouchedPhone = true;
    }
}

- (void) SampleObservation:(NSTimer *) timer 
{
    // If getting data because user touched phone, then ignore
    if(!self.userTouchedPhone && [self tappedOccured:self.accelerometerData])
    {
        // create observation
        Observation *newObservation = [[Observation alloc] init];
        
        NSString* accelObservation = [newObservation processAcclerometer:self.accelerometerData];
        NSString* gryoObservation = [newObservation processGryo:self.gryoscopeData];
        NSString* micFFTObservation = [newObservation processMicFFT:self.micFFTData];
        NSString* micObservation = [newObservation processMic:self.micData];

        
        NSString *observationString = [NSString stringWithFormat:@"%@, %@, %@, %@\n", accelObservation, gryoObservation, micFFTObservation, micObservation];
        
        // Write Observation to file
        [self.fileWriter saveString:observationString];
        //[self.fileWriter writeFeature:newFeature atFile:FILE_NAME];
        
        observationsCollected++;
        [self.numOfObservationsLabel setText:[NSString stringWithFormat:@"%d", observationsCollected]];
        if(observationsCollected == MAX_OBSERVATIONS)
        {
            [self stopCollecting];
            [self.fileWriter writeFile:FILE_NAME];
            [self.appStatusLabel setText:@"DONE!"];
        }
    }
    
    // Clear old data for new frame
    [self.accelerometerData removeAllObjects];
    [self.gryoscopeData removeAllObjects];
    [self.micFFTData removeAllObjects];
    [self.micData removeAllObjects];

    
    self.userTouchedPhone = FALSE;
}

- (bool) tappedOccured:(NSMutableArray *) acceleration
{
    for(int i = 0; i < [acceleration count]; i++)
    {
        //NSLog(@"x: %f", [[acceleration objectAtIndex:i] x]);
        //NSLog(@"y: %f", [[acceleration objectAtIndex:i] y]);
        //NSLog(@"z: %f", [[acceleration objectAtIndex:i] z]);
        if([[acceleration objectAtIndex:i] z] > (-1 * TABLE_CALIBRATION_FACTOR))
        {
            NSLog(@"YEE");
            return true;
        }
    }
    
    return FALSE;
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
    
    [self.micData release];
    self.micData = nil;
    
    [super dealloc];
}

@end
