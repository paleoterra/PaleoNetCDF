//
//  NCDFError.m
//  netcdf
//
//  Created by Tom Moore on Tue Jul 30 2002.
//  Copyright (c) 2001 Argonne National Laboratory. All rights reserved.
//

#import "NCDFError.h"
#import "netcdf.h"

@implementation NCDFError

//Initialization
-(id)init
{
    [super init];
    [self setErrorClass:nil];
    [self setErrorMethod:nil];
    [self setSubMethod:nil];
    [self setErrorSourceObjectName:nil];
    [self setNCDFCode:NC_NOERR];
    return self;
}

-(id)initErrorFromSourceName:(NSString *)sourceName theClass:(NSString *)theClass fromMethod:(NSString *)theMethod fromSubmethod:(NSString *)subMethod withError:(int)theError;
{
    [super init];
    [self setErrorSourceObjectName:sourceName];
    [self setErrorClass:theClass];
    [self setErrorMethod:theMethod];
    [self setSubMethod:subMethod];
    [self setNCDFCode:theError];
    return self;
}

-(void)dealloc
{
    if(_errorClass)
        [_errorClass release];
    if(_errorMethod)
        [_errorMethod release];
    if(_errorSubMethod)
        [_errorSubMethod release];
    if(_errorSourceObjectName)
        [_errorSourceObjectName release];
    [super dealloc];
}

-(void)finalize
{
	[super finalize];
}
//Accessors

-(NSString *)errorSourceObjectName
{
    return _errorSourceObjectName;
}

-(void)setErrorSourceObjectName:(NSString *)newName
{
    if(_errorSourceObjectName)
        [_errorSourceObjectName release];
    if(newName)
        _errorSourceObjectName = [newName retain];
    else
        _errorSourceObjectName = [[NSString alloc] init];

}

-(NSString *)errorClass
{
    return _errorClass;
}

-(void)setErrorClass:(NSString *)newClass
{
    if(_errorClass)
        [_errorClass release];
    if(newClass)
        _errorClass = [newClass retain];
    else
        _errorClass = [[NSString alloc] init];
}

-(NSString *)errorMethod
{
    return _errorMethod;
}

-(void)setErrorMethod:(NSString *)newMethod
{
    if(_errorMethod)
        [_errorMethod release];
    if(newMethod)
        _errorMethod = [newMethod retain];
    else
        _errorMethod = [[NSString alloc] init];
}

-(NSString *)errorSubMethod
{
    return _errorSubMethod;
}

-(void)setSubMethod:(NSString *)newSubMethod
{
    if(_errorSubMethod)
        [_errorSubMethod release];
    if(newSubMethod)
        _errorSubMethod = [newSubMethod retain];
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

/*//Coder methods - for NSCopy methods
-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    [coder decodeValueOfObjCType:@encode(int) at:&_errorNCDFCode];
    _errorClass = [[coder decodeObject] retain];
    _errorClass = [[coder decodeObject] retain];
    _errorSubMethod = [[coder decodeObject] retain];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeValueOfObjCType:@encode(int) at:&_errorNCDFCode];
    [coder encodeObject:_errorClass];
    [coder encodeObject:_errorMethod];
    [coder encodeObject:_errorSubMethod];
    return;
}*/

-(NSString *)localizedStringForErrorCode
{
    NSBundle *theBundle = [NSBundle bundleForClass:[self class]];
    NSString *theErrorString = [NSString stringWithCString:nc_strerror(_errorNCDFCode) encoding:NSUTF8StringEncoding];
    NSString *theLocalizedString = 
    [[theBundle localizedStringForKey:theErrorString value:@"Unknown Error" table:@"NCDFError"] retain];
    return [theLocalizedString autorelease];
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
    NSArray *theArray = [[NSArray arrayWithObjects:theErrorString,
                                                _errorSourceObjectName,
                                                 _errorClass,
                                                 _errorMethod,
                                                 _errorSubMethod,
                                                 [NSNumber numberWithInt:_errorNCDFCode],
                                                 nil] retain];
    return [theArray autorelease];
}

-(NSArray *)localizedAlertArray
{
    NSBundle *theBundle = [NSBundle bundleForClass:[self class]];
    NSString *theErrorString = [NSString stringWithCString:nc_strerror(_errorNCDFCode) encoding:NSUTF8StringEncoding];
    NSString *theLocalizedString = 
    [[theBundle localizedStringForKey:theErrorString value:@"Unknown Error" table:@"NCDFError"] retain];
    NSArray *theArray = [[NSArray arrayWithObjects:theLocalizedString,
                                                _errorSourceObjectName,
                                                 _errorClass,
                                                 _errorMethod,
                                                 _errorSubMethod,
                                                 [NSNumber numberWithInt:_errorNCDFCode],
                                                 nil] retain];
    return [theArray autorelease];
}

@end
