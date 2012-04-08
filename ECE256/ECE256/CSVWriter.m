//
//  CSVWriter.m
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import "CSVWriter.h"

#import "Feature.h"

@implementation CSVWriter

- (void) writeFeature:(Feature *) f atFile:(NSString*) fileName
{
    NSString *line = [f ToString];
    [line writeToFile:[self getFilePath: fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *) getFilePath: (NSString*) fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return [documentDirectory stringByAppendingPathComponent:fileName];
}

@end
