//
//  ViewController.m
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import "ViewController.h"

#import "Feature.h"
#import "CSVWriter.h"

@interface ViewController ()

#define ACCELEROMETER_SAMPLING_FREQUENCY 90.0
#define FEATURE_SAMPLING_FREQUENCY 100 

#define FILE_NAME @"TestData.csv"

@end

@implementation ViewController

@synthesize accelerometer;
@synthesize fileWriter;
@synthesize timer;

@synthesize startButton;
@synthesize stopButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = 1.0/ACCELEROMETER_SAMPLING_FREQUENCY;
    self.accelerometer.delegate = self;
    
    self.fileWriter = [[CSVWriter alloc] init];
    
    [self.startButton setEnabled:TRUE];
    [self.stopButton setEnabled:FALSE];
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
    } else 
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
    
    [self.startButton setEnabled:FALSE];
    [self.startButton setEnabled:TRUE];
}

- (IBAction) stopButtonPressed:(id)sender
{
    [self.timer invalidate];
    self.timer = nil;
    
    [self.startButton setEnabled:FALSE];
    [self.startButton setEnabled:TRUE]; 
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
    //acceleration.x, acceleration.y, acceleration.z
}

- (void) SampleFeature:(NSTimer *) timer 
{
    // create feature
    Feature *newFeature = [[Feature alloc] init];
    
    // add values to feature
    
    // reset data collected
    
    // Write feature to file
    [self.fileWriter writeFeature:newFeature atFile:FILE_NAME];
}

- (void) dealloc
{
    [self.fileWriter release];
    self.fileWriter = nil;
    
    [super dealloc];
}

@end
