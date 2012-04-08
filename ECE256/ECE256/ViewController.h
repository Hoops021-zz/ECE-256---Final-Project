//
//  ViewController.h
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIODelegate.h"

@class RIOInterface;

@interface ViewController : UIViewController <RIODelegate>
{
    RIOInterface *rioRef;
    float currentFrequency;
}

@property(nonatomic, assign) RIOInterface *rioRef;
@property(nonatomic, assign) float currentFrequency;


@end
