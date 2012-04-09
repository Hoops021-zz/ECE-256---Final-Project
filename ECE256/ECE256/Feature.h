//
//  Feature.h
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feature : NSObject
{
    // define variables here
    int featureGrouping;
    
}

@property (nonatomic) int featureGrouping;

- (id) initWithData:(NSMutableArray *) acceleromterData withGryo:(NSMutableArray *) gryoData;

- (NSString *) processAcclerometer:(NSMutableArray *) acceleromterData;

- (NSString *) processGryo:(NSMutableArray *) gryoData;

- (NSString *) ToString;

@end
