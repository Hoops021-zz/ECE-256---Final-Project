//
//  GryoData.m
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import "GryoData.h"

@implementation GryoData

@synthesize x,y,z;

- (id) initWithData:(CMRotationRate) rotate
{
    if(self = [super init])
    {
        self.x = rotate.x;
        self.y = rotate.y;
        self.z = rotate.z;
    }
    
    return self;
}

@end
