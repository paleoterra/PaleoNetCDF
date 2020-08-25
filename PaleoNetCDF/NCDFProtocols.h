//
//  NCDFProtocols.h
//  netcdf
//
//  Created by tmoore on Wed Jun 23 2007.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <netcdf.h>

@class NCDFAttribute,NCDFSlab;
@protocol NCDFImmutableVariableProtocol

//variable metadata
-(NSString *)variableName;
-(NSString *)variableType;
-(nc_type)variableNC_TYPE;
-(NSString *)variableDimDescription;
-(NSString *)dataTypeWithDimDescription;
-(NSArray *)getVariableAttributes;
-(BOOL)isDimensionVariable;
-(int)sizeUnitVariable;
-(int)sizeUnitVariableForType;
-(int)currentVariableSize;
-(int)currentVariableByteSize;
-(NSArray *)lengthArray;
-(BOOL)isUnlimited;
-(int)unlimitedVariableLength;
-(NSArray *)dimensionNames;
-(NSArray *)allVariableDimInformation;
-(NCDFAttribute *)variableAttributeByName:(NSString *)name;
-(int)variableID;
-(int)attributeCount;


//variable data
-(NSData *)readAllVariableData;
-(id)getSingleValue:(NSArray *)coordinates;
-(NSData *)getValueArrayAtLocation:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths;
-(NCDFSlab *)getSlabForStartCoordinates:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths;
-(NCDFSlab *)getAllDataInSlab;
@end

@protocol NCDFImmutableDimensionProtocol

-(NSString *)dimensionName;
-(size_t)dimLength;
-(BOOL)isUnlimited;
@end
