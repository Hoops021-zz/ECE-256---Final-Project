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



@implementation ViewController

@synthesize	rioRef;
@synthesize currentFrequency;

- (void)viewDidLoad
{
    [super viewDidLoad];
    rioRef = [RIOInterface sharedInstance];
    [rioRef startListening:self];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)frequencyChangedWithValue:(float)newFrequency{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	self.currentFrequency = newFrequency;
    //NSLog (@"%f",    self.currentFrequency);
    //NSLog (@"%f",    newFrequency);
    //NSLog (@"YEEE");
	[pool drain];
	pool = nil;
	
}

@end
