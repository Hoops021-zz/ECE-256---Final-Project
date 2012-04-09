//
//  CSVWriter.h
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Feature;

@interface CSVWriter : NSObject
{
    NSMutableArray *lines;
}

- (void) writeFeature:(Feature *) f atFile:(NSString *) fileName;

- (void) saveString:(NSString *) str;

- (void) writeFile:(NSString *) fileName;

- (NSString *) getFilePath: (NSString*) fileName;



@end
