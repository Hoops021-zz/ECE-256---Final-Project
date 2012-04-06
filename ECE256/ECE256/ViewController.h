//
//  ViewController.h
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIAccelerometerDelegate>
{
    UIAccelerometer *accelerometer;
}

@property (nonatomic, retain) UIAccelerometer *accelerometer;

@end
