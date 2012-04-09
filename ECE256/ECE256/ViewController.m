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
@synthesize startButton;
@synthesize stopButton;

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
    
    // INIT GUI 
    [self.startButton setEnabled:TRUE];
    [self.stopButton setEnabled:FALSE];
    
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

- (IBAction) startButtonPressed:(id)sender
{
     self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/FEATURE_SAMPLING_FREQUENCY
                                     target:self
                                   selector:@selector(SampleFeature:)
                                   userInfo:nil
                                    repeats:YES]; 
    
    // Update GUI appropriately
    [self.startButton setEnabled:FALSE];
    [self.startButton setEnabled:TRUE];
    
    // Clear old data
    [self.accelerometerData removeAllObjects];
    [self.gryoscopeData removeAllObjects];
    [self.micFFTData removeAllObjects];

    
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

- (IBAction) stopButtonPressed:(id)sender
{
    // Stop Timer
    [self.timer invalidate];
    self.timer = nil;
    
    // Update GUI appropriately
    [self.startButton setEnabled:FALSE];
    [self.startButton setEnabled:TRUE]; 
    
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
        
        // add values to feature
        
        
        // Clear old data for new frame
        [self.accelerometerData removeAllObjects];
        [self.gryoscopeData removeAllObjects];
        [self.micFFTData removeAllObjects];

        
        // Write feature to file
        [self.fileWriter writeFeature:newFeature atFile:FILE_NAME];
    }
    
    self.userTouchedPhone = FALSE;
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
