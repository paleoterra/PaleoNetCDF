//
//  NCDFErrorTester.m
//  netcdf
//
//  Created by Tom Moore on Tue Jul 30 2002.
//  Copyright (c) 2001 Argonne National Laboratory. All rights reserved.
//

#import "NCDFErrorTester.h"
#import "NCDFError.h"
#import "netcdf.h"

@implementation NCDFErrorTester

-(void)simpleInit
{
    NCDFError *theError = [[NCDFError alloc] init];
    NSNumber *left,*right;
    shouldBeEqual(@"",[theError errorClass]);
    shouldBeEqual(@"",[theError errorMethod]);
    shouldBeEqual(@"",[theError errorSubMethod]);
    left = [NSNumber numberWithInt:0];
    right = [NSNumber numberWithInt:[theError errorNCDFCode]];
    shouldBeEqual(left,right);
    [theError release];
}

-(void)testComplexInitWithNils
{
    NCDFError *theError = [[NCDFError alloc] initErrorFromClass:nil fromMethod:nil fromSubmethod:nil withError:0];
    NSNumber *left,*right;
    shouldBeEqual(@"",[theError errorClass]);
    shouldBeEqual(@"",[theError errorMethod]);
    shouldBeEqual(@"",[theError errorSubMethod]);
    left = [NSNumber numberWithInt:0];
    right = [NSNumber numberWithInt:[theError errorNCDFCode]];
    shouldBeEqual(left,right);
    [theError release];
}

-(void)testErrorCodeLocalizations
{
    NCDFError *theError = [[NCDFError alloc] initErrorFromClass:nil fromMethod:nil fromSubmethod:nil withError:0];
    NSString *left,*right;
    int i, errorCode[30];
    
    
    //seed error codes in array
    errorCode[0] = NC_NOERR;
    errorCode[1] = NC_EBADID;
    errorCode[2] = NC_ENFILE;
    errorCode[3] = NC_EEXIST;
    errorCode[4] = NC_EINVAL;
    errorCode[5] = NC_EPERM;
    errorCode[6] = NC_ENOTINDEFINE;
    errorCode[7] = NC_EINDEFINE;
    errorCode[8] = NC_EINVALCOORDS;
    errorCode[9] = NC_EMAXDIMS;
    errorCode[10] = NC_ENAMEINUSE;
    errorCode[11] = NC_ENOTATT;
    errorCode[12] = NC_EMAXATTS;
    errorCode[13] = NC_EBADTYPE;
    errorCode[14] = NC_EBADDIM;
    errorCode[15] = NC_EUNLIMPOS;
    errorCode[16] = NC_EMAXVARS;
    errorCode[17] = NC_ENOTVAR;
    errorCode[18] = NC_EGLOBAL;
    errorCode[19] = NC_ENOTNC;
    errorCode[20] = NC_ESTS;
    errorCode[21] = NC_EMAXNAME;
    errorCode[22] = NC_EUNLIMIT;
    errorCode[23] = NC_ENORECVARS;
    errorCode[24] = NC_ECHAR;
    errorCode[25] = NC_EEDGE;
    errorCode[26] = NC_ESTRIDE;
    errorCode[27] = NC_EBADNAME;
    errorCode[28] = NC_ERANGE;
    errorCode[29] = NC_ENOMEM;
    for(i=0;i<30;i++)
    {
        left = [NSString stringWithCString:nc_strerror(errorCode[i])];
        [theError setNCDFCode:errorCode[i]];
        right = [theError localizedStringForErrorCode];
        shouldBeEqual(left,right);
    }
    [theError release];
}	
	
-(void)testAlertArrays
{
    NCDFError *theError = [[NCDFError alloc] initErrorFromClass:[self className] fromMethod:@"testAlertArrays" fromSubmethod:@"init" withError:0];
    NSNumber *theNumber = [NSNumber numberWithInt:0];
    NSArray *theArray = [theError alertArray];
    shouldBeEqual(@"No error",[theArray objectAtIndex:0]);
    shouldBeEqual(@"NCDFErrorTester",[theArray objectAtIndex:1]);
    shouldBeEqual(@"testAlertArrays",[theArray objectAtIndex:2]);
    shouldBeEqual(@"init",[theArray objectAtIndex:3]);
    shouldBeEqual(theNumber,[theArray objectAtIndex:4]);
    
    theArray = [theError localizedAlertArray];
    shouldBeEqual(@"No error",[theArray objectAtIndex:0]);
    shouldBeEqual(@"NCDFErrorTester",[theArray objectAtIndex:1]);
    shouldBeEqual(@"testAlertArrays",[theArray objectAtIndex:2]);
    shouldBeEqual(@"init",[theArray objectAtIndex:3]);
    shouldBeEqual(theNumber,[theArray objectAtIndex:4]);
    [theError release];
}
@end
