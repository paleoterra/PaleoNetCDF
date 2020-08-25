//
//  NCDFErrorHandle.h
//  netcdf
//
//  Created by Tom Moore on Wed Jul 31 2002.
//  Copyright (c) 2001 Argonne National Laboratory. All rights reserved.
//


/*!
	@header
  @class NCDFErrorHandle
@abstract NCDFErrorHandle objects handle errors created by netcdf file operations.
    @discussion One limitation of the netCDF libary is that it doesn't allow for localized error codes
that make sense to the end user.  So, this method stores netCDF error codes that an application
can use in order to present error information to the user.

This class is an error object that stores enough information about an error to provide


information to a programmer and end user.




*/

#import <Foundation/Foundation.h>

//Note: the debug value for this object is Debug_NCDFErrorHandle
@class NCDFError;
@interface NCDFErrorHandle : NSObject {
    NSMutableArray *theErrors;
}

-(id)init;
+(id)defaultErrorHandle;
-(void)addError:(NCDFError *)anError;
-(void)addErrorFromSource:(NSString *)sourceFile className:(NSString *)className methodName:(NSString *)methodName subMethod:(NSString *)subMethod errorCode:(int)errorCode;


-(NCDFError *)lastError;
-(int)errorCount;
-(NCDFError *)errorAtIndex:(int)index;
-(NSArray *)allErrors;
-(void)deleteError:(int)index;
-(void)removeLastError;
-(void)removeAllErrors;

-(NSString *)lastErrorString;
-(NSArray *)lastErrorForAlert;
-(NSArray *)lastErrorLocalizedForAlert;
-(void)logLastError;
-(void)logAllErrors;
@end
/*
0.2.1d1 Changes.

Modified to handle the addition of _errorSourceObjectName in NCDFError.
*/