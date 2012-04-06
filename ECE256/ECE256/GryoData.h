//
//  GryoData.h
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreMotion/CoreMotion.h>

@interface GryoData : NSObject
{
    double x;
    double y;
    double z;
}

@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double z;

- (id) initWithData:(CMRotationRate) rotate;

@end
