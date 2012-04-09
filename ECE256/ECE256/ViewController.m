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
#import "Feature.h"
#import "CSVWriter.h"
#import "GryoData.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

#define ACCELEROMETER_SAMPLING_FREQUENCY 90.0
#define FEATURE_SAMPLING_FREQUENCY 100 
#define FILE_NAME @"TestData.csv"

#define MAX_FEATURES 10

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
@synthesize userTouchedPhone;

@synthesize numOfFeaturesLabel;
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
            [self.gryoscopeData addObject:data];
        };
    }
    else 
    {
        NSLog(@"No gyroscope on device.");
    }
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
     self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/FEATURE_SAMPLING_FREQUENCY
                                     target:self
                                   selector:@selector(SampleFeature:)
                                   userInfo:nil
                                    repeats:YES]; 
    
    // Clear old data
    [self.accelerometerData removeAllObjects];
    [self.gryoscopeData removeAllObjects];
    [self.micFFTData removeAllObjects];
    
    featuresCollected = 0;
    [self.numOfFeaturesLabel setText:[NSString stringWithFormat:@"%d", featuresCollected]];
    [self.appStatusLabel setText:@"Collecting..."];
    
    [self.motionManager startGyroUpdatesToQueue:opQ withHandler:self.gyroHandler];
    [self.rioRef startListening:self];

}
- (void)frequencyChangedWithValue:(float)newFrequency{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	self.currentFrequency = newFrequency;
    NSLog (@"%f",    newFrequency);
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

-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event 
{    
    NSSet *allTouches = [event allTouches];
    if([allTouches count] > 0)
    {
        self.userTouchedPhone = true;
    }
}

- (void) SampleFeature:(NSTimer *) timer 
{
    // If getting data because user touched phone, then ignore
    if(!self.userTouchedPhone)
    {
        // create feature
        // TODO: Need to figure out feature grouping
        Feature *newFeature = [[Feature alloc] init];
        
        NSString* accellFeatures = [newFeature processAcclerometer:self.accelerometerData];
        NSString* gryoFeatures = [newFeature processGryo:self.gryoscopeData];
        NSString* micFFTFeatures = [newFeature processMicFFT:self.micFFTData];
        
        NSString *featureString = [NSString stringWithFormat:@"%@, %@, %@", accellFeatures, gryoFeatures, micFFTFeatures];
        
        // Clear old data for new frame
        [self.accelerometerData removeAllObjects];
        [self.gryoscopeData removeAllObjects];
        [self.micFFTData removeAllObjects];
        
        // Write feature to file
        [self.fileWriter writeString:featureString atFile:FILE_NAME];
        //[self.fileWriter writeFeature:newFeature atFile:FILE_NAME];
        
        featuresCollected++;
        [self.numOfFeaturesLabel setText:[NSString stringWithFormat:@"%d", featuresCollected]];
        if(featuresCollected == MAX_FEATURES)
        {
            [self stopCollecting];
            [self.appStatusLabel setText:@"DONE!"];
        }
    }
    
    self.userTouchedPhone = FALSE;
}

- (bool) AppearsTapped
{
// scan through accleerometer values for x,y,z 
    // see if all values below threshold(ie. 0.0001)
    return true;
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
    
    [super dealloc];
}

@end
