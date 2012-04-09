//
//  CSVWriter.m
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import "CSVWriter.h"

#import "Observation.h"

@implementation CSVWriter

- (id) init
{
    if(self = [super init])
    {
        lines = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void) writeFeature:(Feature *) f atFile:(NSString*) fileName
{
    //NSString *line = [f ToString];
    //[line writeToFile:[self getFilePath: fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void) saveString:(NSString *) str
{
    [lines addObject:str];
    //[str writeToFile:[self getFilePath: fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void) writeFile:(NSString *) fileName
{
    NSString *finalData = @"ACCEL_MIN_X, ACCEL_MIN_Y, ACCEL_MIN_Z, ACCEL_MAX_X, ACCEL_MAX_Y, ACCEL_MAX_Z, ACCEL_SKEWNESS_X, ACCEL_SKEWNESS_Y, ACCEL_SKEWNESS_Z, ACCEL_KURTOSIS_X, ACCEL_KURTOSIS_Y, ACCEL_KURTOSIS_Z, ACCEL_ONE_NORM, ACCELL_INFINITY_NORM, ACCEL_FORBENIUS_NORM, ACCEL_MEAN_X, ACCEL_MEAN_Y, ACCEL_MEAN_Z, GRYO_MIN_X, GRYO_MIN_Y, GRYO_MIN_Z, GRYO_MAX_X, GRYO_MAX_Y, GRYO_MAX_Z, GRYO_SKEWNESS_X, GRYO_SKEWNESS_Y, GRYO_SKEWNESS_Z, GRYO_KURTOSIS_X, GRYO_KURTOSIS_Y, GRYO_KURTOSIS_Z, GRYO_ONE_NORM, GRYOL_INFINITY_NORM, GRYO_FORBENIUS_NORM, GRYO_MEAN_X, GRYO_MEAN_Y, GRYO_MEAN_Z, MICROPHONE_MEAN, MICROPHONE_MIN, MICROPHONE_MAX\n";
    
    for(int i = 0; i < [lines count]; i++)
    {
        finalData = [finalData stringByAppendingString:[lines objectAtIndex:i]];
    }
    
    [finalData writeToFile:[self getFilePath: fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *) getFilePath: (NSString*) fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (void) dealloc
{
    [lines release];
    
    [super dealloc];
}

@end
