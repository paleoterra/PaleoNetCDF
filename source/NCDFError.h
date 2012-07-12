//
//  NCDFError.h
//  netcdf
//
/*
One limitation of the netCDF libary is that it doesn't allow for localized error codes
that make sense to the end user.  So, this method stores netCDF error codes that an application
can use in order to present error information to the user.

This class is an error object that stores enough information about an error to provide 
information to a programmer and end user.
*/
//  Created by Tom Moore on Tue Jul 30 2002.
//  Copyright (c) 2001 Argonne National Laboratory. All rights reserved.
//


/*!
	@header
  @class NCDFError
@abstract NCDFError objects handle errors created by netcdf file operations.
    @discussion One limitation of the netCDF libary is that it doesn't allow for localized error codes
that make sense to the end user.  So, this method stores netCDF error codes that an application
can use in order to present error information to the user.

This class is an error object that stores enough information about an error to provide 
information to a programmer and end user.  
*/

#import <Cocoa/Cocoa.h>


@interface NCDFError : NSObject {
    NSString *_errorClass;
    NSString *_errorMethod;
    NSString *_errorSubMethod;
    NSString *_errorSourceObjectName;
    int _errorNCDFCode;
}

//Initialization
-(id)init;
-(id)initErrorFromSourceName:(NSString *)sourceName theClass:(NSString *)theClass fromMethod:(NSString *)theMethod fromSubmethod:(NSString *)subMethod withError:(int)theError;


//Accessors
-(NSString *)errorSourceObjectName;
-(void)setErrorSourceObjectName:(NSString *)newName;
-(NSString *)errorClass;
-(void)setErrorClass:(NSString *)newClass;
-(NSString *)errorMethod;
-(void)setErrorMethod:(NSString *)newMethod;
-(NSString *)errorSubMethod;
-(void)setSubMethod:(NSString *)newSubMethod;
-(int)errorNCDFCode;
-(void)setNCDFCode:(int)newCode;

//Coder methods - for NSCopy methods
/*-(id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;*/

//localization
-(NSString *)localizedStringForErrorCode;

//Logging
-(void)logString;

//Arrays of strings to populate Alert Panels.
-(NSArray *)alertArray;
-(NSArray *)localizedAlertArray;


@end


/*
0.2.1d1 Changes.

Added the variable _errorSourceObjectName.  This is added because document-based applications require that the source document of the error be identified.
*/