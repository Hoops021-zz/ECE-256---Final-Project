//
//  CSVWriter.h
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CSVWriter : NSObject
{
    NSMutableArray *lines;
}

- (void) saveString:(NSString *) str;

- (void) writeFile:(NSString *) fileName;

- (NSString *) getFilePath: (NSString*) fileName;

- (void) clear;



@end
