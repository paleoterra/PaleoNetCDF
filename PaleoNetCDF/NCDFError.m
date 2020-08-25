//
//  NCDFError.m
//  netcdf
//
//  Created by Tom Moore on Tue Jul 30 2002.
//  Copyright (c) 2001 Argonne National Laboratory. All rights reserved.
//

#import "NCDFError.h"
#import <netcdf.h>

@implementation NCDFError

//Initialization
-(id)init
{
    self = [super init];
    [self setErrorClass:nil];
    [self setErrorMethod:nil];
    [self setSubMethod:nil];
    [self setErrorSourceObjectName:nil];
    [self setNCDFCode:NC_NOERR];
    return self;
}

-(id)initErrorFromSourceName:(NSString *)sourceName theClass:(NSString *)theClass fromMethod:(NSString *)theMethod fromSubmethod:(NSString *)subMethod withError:(int)theError;
{
    self = [super init];
    [self setErrorSourceObjectName:sourceName];
    [self setErrorClass:theClass];
    [self setErrorMethod:theMethod];
    [self setSubMethod:subMethod];
    [self setNCDFCode:theError];
    return self;
}

//Accessors

-(NSString *)errorSourceObjectName
{
    return _errorSourceObjectName;
}

-(void)setErrorSourceObjectName:(NSString *)newName
{
    if(newName)
        _errorSourceObjectName = newName;
    else
        _errorSourceObjectName = [[NSString alloc] init];

}

-(NSString *)errorClass
{
    return _errorClass;
}

-(void)setErrorClass:(NSString *)newClass
{
    if(newClass)
        _errorClass = newClass;
    else
        _errorClass = [[NSString alloc] init];
}

-(NSString *)errorMethod
{
    return _errorMethod;
}

-(void)setErrorMethod:(NSString *)newMethod
{
    if(newMethod)
        _errorMethod = newMethod;
    else
        _errorMethod = [[NSString alloc] init];
}

-(NSString *)errorSubMethod
{
    return _errorSubMethod;
}

-(void)setSubMethod:(NSString *)newSubMethod
{
    if(newSubMethod)
        _errorSubMethod = newSubMethod;
    else
        _errorSubMethod = [[NSString alloc] init];
}

-(int)errorNCDFCode
{
    return _errorNCDFCode;
}

-(void)setNCDFCode:(int)newCode
{
    _errorNCDFCode = newCode;
}

-(NSString *)localizedStringForErrorCode
{
    NSBundle *theBundle = [NSBundle bundleForClass:[self class]];
    NSString *theErrorString = [NSString stringWithCString:nc_strerror(_errorNCDFCode) encoding:NSUTF8StringEncoding];
    NSString *theLocalizedString =

    [theBundle localizedStringForKey:theErrorString value:@"Unknown Error" table:@"NCDFError"];
    return theLocalizedString;
}

//Logging
-(void)logString
{
    NSString *theErrorString = [NSString stringWithCString:nc_strerror(_errorNCDFCode) encoding:NSUTF8StringEncoding];
    NSLog(@"Error: %@\nFile: %@\nClass: %@\nMethod %@\nSub-Method %@\nCode: %i\n",theErrorString,_errorSourceObjectName,_errorClass,_errorMethod,_errorSubMethod,_errorNCDFCode);
}

//Arrays of strings to populate Alert Panels.
-(NSArray *)alertArray
{
    NSString *theErrorString = [NSString stringWithCString:nc_strerror(_errorNCDFCode) encoding:NSUTF8StringEncoding];
    NSArray *theArray = [NSArray arrayWithObjects:theErrorString,
                                                _errorSourceObjectName,
                                                 _errorClass,
                                                 _errorMethod,
                                                 _errorSubMethod,
                                                 [NSNumber numberWithInt:_errorNCDFCode],
                                                 nil];
    return theArray;
}

-(NSArray *)localizedAlertArray
{
    NSBundle *theBundle = [NSBundle bundleForClass:[self class]];
    NSString *theErrorString = [NSString stringWithCString:nc_strerror(_errorNCDFCode) encoding:NSUTF8StringEncoding];
    NSString *theLocalizedString =


    [theBundle localizedStringForKey:theErrorString value:@"Unknown Error" table:@"NCDFError"];
    NSArray *theArray = [NSArray arrayWithObjects:theLocalizedString,
                                                _errorSourceObjectName,
                                                 _errorClass,
                                                 _errorMethod,
                                                 _errorSubMethod,
                                                 [NSNumber numberWithInt:_errorNCDFCode],
                                                 nil];
    return theArray;
}

-(void)dealloc
{
    _errorClass = nil;
    _errorMethod = nil;
    _errorSubMethod = nil;
    _errorSourceObjectName = nil;
}
@end
