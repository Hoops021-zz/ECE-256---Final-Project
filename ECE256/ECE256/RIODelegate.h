//
//  RIODelegate.h
//  ECE256
//
//  Created by Brandon Millman on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RIODelegate <NSObject>

@required
- (void)frequencyChangedWithValue:(float)newFrequency;

@end