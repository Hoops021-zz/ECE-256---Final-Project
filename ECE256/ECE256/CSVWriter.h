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
    
}

- (void) writeFeature:(Feature *) f atFile:(NSString *) fileName;

- (void) writeString:(NSString *) str atFile:(NSString *) fileName;

- (NSString *) getFilePath: (NSString*) fileName;



@end
