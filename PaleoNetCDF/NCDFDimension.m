//
//  NCDFDimension.m
//  netcdf
//
//  Created by tmoore on Wed Feb 13 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

#import "NCDFDimension.h"
#import "NCDFHandle.h"
#import "NCDFErrorHandle.h"
#import <netcdf.h>

@implementation NCDFDimension

-(id)initWithFileName:(NSString *)thePath dimID:(int)number name:(NSString *)name length:(size_t)aLength handle:(NCDFHandle *)handle
{
    self = [super init];
    fileName = [thePath copy];
    dimID = number;
    dimName = [name copy];
    length = aLength;//Dimension length is a count.
    theHandle = handle;
    return self;
}

-(id)initNewDimWithName:(NSString *)name length:(size_t)aLength
{
    self = [super init];
    fileName = nil;
    dimID = -1;
    dimName = [name copy];
    length = aLength;//Dimension length is a count.
    theHandle = nil;
    return self;
}

-(id)initWithDimension:(NCDFDimension *)aDim makeUnlimited:(BOOL)limit
{
    if(aDim)
    {
        self = [super init];
        fileName = nil;
        dimID = -1;
        dimName = [[aDim dimensionName] copy];
        if(limit)
            length = NC_UNLIMITED;
        else
            length = [aDim dimLength];//Dimension length is a count.
        theHandle = nil;
        return self;
    }
    else
        return nil;
}

-(NSLock *)handleLock
{
	return [theHandle handleLock];
}

-(NSString *)dimensionName
{
    return dimName;
}

-(size_t)dimLength
{
    return length;
}

-(BOOL)renameDimension:(NSString *)newName
{
    int32_t ncid;
    int32_t status;
    char *theCName;
    if(theErrorHandle==nil)
        theErrorHandle = [theHandle theErrorHandle];
    newName = [self parseNameString:newName];
    ncid = [theHandle ncidWithOpenMode:NC_WRITE status:&status];

    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFDimension" methodName:@"renameDimension" subMethod:@"Opening netCDF file" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFDimension" methodName:@"renameDimension" subMethod:@"redefine mode" errorCode:status];
        return NO;
    }
    theCName = (char *)malloc(sizeof(char)*[newName length]+1);
	[newName getCString:theCName maxLength:[newName length]+1 encoding:NSUTF8StringEncoding];
    status = nc_rename_dim(ncid,dimID,theCName);
    free(theCName);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFDimension" methodName:@"renameDimension" subMethod:@"Renaming dimension" errorCode:status];
        return NO;
    }
    dimName = [newName copy];
    [theHandle closeNCID:ncid];
	[theHandle refresh];
    return YES;
}


-(NSString *)parseNameString:(NSString *)theString
{
    NSString *newString;
    NSMutableString *mutString;
    NSRange theRange;
    NSScanner *theScanner = [NSScanner scannerWithString:theString];
    NSCharacterSet *theSet = [NSCharacterSet whitespaceCharacterSet];
    mutString = [NSMutableString stringWithString:theString];
        theRange.length = 1;
    while(![theScanner isAtEnd])
    {
        [theScanner scanUpToCharactersFromSet:theSet intoString:nil];
        if(![theScanner isAtEnd])
        {
        theRange.location = [theScanner scanLocation];
        [mutString replaceCharactersInRange:theRange withString:@"_"];
        }
    }
    newString = [NSString stringWithString:mutString];
    return newString;
}

-(int)dimensionID
{
    return dimID;
}

-(BOOL)isEqualToDim:(NCDFDimension *)aDimension
{
    if(![dimName isEqualToString:[aDimension dimensionName]])
        return NO;
    if(length != [aDimension dimLength])
        return NO;
    return YES;
}

-(void)setDimLength:(size_t)newLength
{
    length = newLength;
}

-(BOOL)isUnlimited
{
    int32_t ncid,pid,status;
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    ncid = [theHandle ncidWithOpenMode:NC_NOWRITE status:&status];
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFDimension" methodName:@"isUnlimited" subMethod:@"Opening netCDF file" errorCode:status];
        return NO;
    }
    status = nc_inq_unlimdim(ncid,&pid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFDimension" methodName:@"isUnlimited" subMethod:@"Is dimension unlimited?" errorCode:status];
        return NO;
    }
    [theHandle closeNCID:ncid];
    if(dimID==pid)
        return YES;
    return NO;
}

-(NSDictionary *)propertyList
{
    NSDictionary *thePropertyList;
    NSMutableDictionary *theTemp;
    theTemp = [[NSMutableDictionary alloc] init];
    [theTemp setObject:fileName forKey:@"fileName"];
    [theTemp setObject:[NSNumber numberWithInt:dimID] forKey:@"dimID"];
    [theTemp setObject:dimName forKey:@"dimName"];
    if([self isUnlimited])
        [theTemp setObject:[NSNumber numberWithInt:0] forKey:@"length"];
    else
        [theTemp setObject:[NSNumber numberWithInt:(int)length] forKey:@"length"];
    thePropertyList = [NSDictionary dictionaryWithDictionary:theTemp];
    return thePropertyList;
}

-(void)updateDimensionWithDimension:(NCDFDimension *)aDim
{
    dimID = [aDim dimensionID];
    dimName = [[aDim dimensionName] copy];
    length = [aDim dimLength];//Dimension length is a count.
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"NCDFDimension: %@\nID: %zi\nLength: %i\n",[self dimensionName],[self dimLength],[self dimensionID]];
}

-(NSComparisonResult)compare:(id)object
{
	if([object isKindOfClass:[NCDFDimension class]])
	{
		if([self dimensionID] < [(NCDFDimension *)object dimensionID])
			return NSOrderedAscending;
		else
			return NSOrderedDescending;
	}
	else
		return NSOrderedSame;
}

-(void)dealloc
{
    fileName = nil;
    dimName = nil;
    theHandle = nil;
    theErrorHandle = nil;
}
@end
