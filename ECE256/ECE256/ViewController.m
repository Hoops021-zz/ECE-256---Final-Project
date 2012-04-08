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


	//[self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
	
	
	/*
	 * If you want to display letter values for pitches, uncomment this code and
	 * add your frequency to pitch mappings in KeyHelper.m
	 */
	
	/*
     KeyHelper *helper = [KeyHelper sharedInstance];
     NSString *closestChar = [helper closestCharForFrequency:newFrequency];
     
     // If the new sample has the same frequency as the last one, we should ignore
     // it. This is a pretty inefficient way of doing comparisons, but it works.
     if (![prevChar isEqualToString:closestChar]) {
     self.prevChar = closestChar;
     if ([closestChar isEqualToString:@"0"]) {
     //	[self toggleListening:nil];
     }
     [self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
     NSString *appendedString = [key stringByAppendingString:closestChar];
     self.key = [NSMutableString stringWithString:appendedString];
     }
     */
	[pool drain];
	pool = nil;
	
}

@end
