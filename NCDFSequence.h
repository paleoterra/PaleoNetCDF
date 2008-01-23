//
//  NCDFSequence.h
//  netcdf
//
//  Created by Thomas Moore on 5/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NCDFSequence : NSObject {

}

//creation with known sequence
-(id)netCDFSequenceWithXML:(NSTree *)xml;
-(id)netCDFSequenceWithPathArray:(NSArray *)pathArray;

//add files to sequence
-(id)addNetCDFAtPath:(NSString *)path error:(NSError **)theError;
-(id)insertNetCDFAtPath:(NSString *)path atIndex:(int)index error:(NSError **)theError;
-(id)insertUsingUnlimitedDimensionNetCDFAtPath:(NSString *)path  error:(NSError **)theError;

//remove files from sequence

-(id)removeFileAtIndex:(int)index;

-(NCDFHandle *)netcdfHandleAtIndex:(int)index;


@end
