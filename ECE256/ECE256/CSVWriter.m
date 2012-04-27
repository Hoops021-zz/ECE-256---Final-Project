//
//  CSVWriter.m
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import "CSVWriter.h"

@implementation CSVWriter

- (id) init
{
    if(self = [super init])
    {
        lines = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void) saveString:(NSString *) str
{
    [lines addObject:str];
    //[str writeToFile:[self getFilePath: fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void) writeFile:(NSString *) fileName
{
    NSString *finalData = @"";
    
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

- (void) clear
{
    [lines removeAllObjects];
}

- (void) dealloc
{
    [lines release];
    
    [super dealloc];
}

@end
