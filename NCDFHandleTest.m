//
//  NCDFHandleTest.m
//  netcdf
//
//  Created by Tom Moore on Mon Jul 29 2002.
//  Copyright (c) 2001 Argonne National Laboratory. All rights reserved.
//

#import "NCDFHandleTest.h"
#import "NCDFNetCDF.h"

@implementation NCDFHandleTest

//setfilepath tests

/*Note: this setFilePath does not check for valid paths.  It only handles string objects and 
nil objects*/
-(void)testSetFilePathNormalPath
{
    NCDFHandle *theHandle = [[NCDFHandle alloc] initWithPath:@"/Volumes/projects01/programs/netcdf/testNCFiles/aprens_0ka.nc"];
    [theHandle setFilePath:@"/Volumes/projects01/programs/netcdf/testNCFiles/test"];
    shouldBeEqual(@"/Volumes/projects01/programs/netcdf/testNCFiles/test",[theHandle theFilePath]);
    [theHandle release];
    //passed 7/29/2002
}

-(void)testSetFilePathTestNilPath
{
    NCDFHandle *theHandle = [[NCDFHandle alloc] initWithPath:@"/Volumes/projects01/programs/netcdf/testNCFiles/aprens_0ka.nc"];
    [theHandle setFilePath:@""];
    shouldBeEqual(@"",[theHandle theFilePath]);
    [theHandle release];
    //passed 7/29/2002
}


@end
