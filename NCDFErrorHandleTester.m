//
//  NCDFErrorHandleTester.m
//  netcdf
//
//  Created by Tom Moore on Wed Jul 31 2002.
//  Copyright (c) 2001 Argonne National Laboratory. All rights reserved.
//

#import "NCDFErrorHandleTester.h"
#import "NCDFError.h"
#import "NCDFErrorHandle.h"
#import "netcdf.h"

@implementation NCDFErrorHandleTester

-(void)setUp
{
    NCDFErrorHandle *theHandle = [NCDFErrorHandle defaultErrorHandle];
    NCDFError *theError = [[NCDFError alloc] initErrorFromClass:[self className] fromMethod:@"testAddError" fromSubmethod:@"init error" withError:NC_EGLOBAL];
    [theHandle addError:theError];
    [theError release];
    theError = [[NCDFError alloc] initErrorFromClass:[self className] fromMethod:@"testAddError" fromSubmethod:@"init error" withError:NC_EMAXNAME];
    [theHandle addError:theError];
    [theError release];
    theError = [[NCDFError alloc] initErrorFromClass:[self className] fromMethod:@"testAddError" fromSubmethod:@"init error" withError:NC_ECHAR];
    [theHandle addError:theError];
    [theError release];
}



-(void)testgetLastError
{
    NCDFErrorHandle *theHandle = [NCDFErrorHandle defaultErrorHandle];
    NCDFError *lastError = [theHandle lastError];
    if(lastError)
       [lastError logString];
}


-(void)testErrorCount
{
    NCDFErrorHandle *theHandle = [NCDFErrorHandle defaultErrorHandle];
    int i,j;
    i = [theHandle errorCount];
    j = 3;
    should(i==j);
}
/*
-(void)testErrorAtIndex
{
    NCDFErrorHandle *theHandle = [NCDFErrorHandle defaultErrorHandle];
    NCDFError *theError = [theHandle errorAtIndex:1];
    if([theError errorNCDFCode] != NC_EGLOBAL)
        should(NO);
}

-(void)testAllErrors
{
    NCDFErrorHandle *theHandle = [NCDFErrorHandle defaultErrorHandle];
    NSArray *theArray = [theHandle allErrors];
    if([theArray count] != 3)
            should(NO);
}

-(void)testRemoveLastError
{
    NCDFErrorHandle *theHandle = [NCDFErrorHandle defaultErrorHandle];
    [theHandle removeLastError];
    if([theHandle errorCount] != 2)
            should(NO);
    [theHandle addError:[[NCDFError alloc] initErrorFromClass:[self className] fromMethod:@"testAddError" fromSubmethod:@"init error" withError:NC_ECHAR]];
}

-(void)testRemoveAllErrors
{
    NCDFErrorHandle *theHandle = [NCDFErrorHandle defaultErrorHandle];
    [theHandle removeAllErrors];
    if([theHandle errorCount] != 0)
            should(NO);
    [theHandle addError:[[NCDFError alloc] initErrorFromClass:[self className] fromMethod:@"testAddError" fromSubmethod:@"init error" withError:NC_EGLOBAL]];
    [theHandle addError:[[NCDFError alloc] initErrorFromClass:[self className] fromMethod:@"testAddError" fromSubmethod:@"init error" withError:NC_EMAXNAME]];
    [theHandle addError:[[NCDFError alloc] initErrorFromClass:[self className] fromMethod:@"testAddError" fromSubmethod:@"init error" withError:NC_ECHAR]];
}*/
@end
