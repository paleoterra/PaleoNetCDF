//
//  NCDFSeriesVariable.h
//  netcdf
//
//  Created by Tom Moore on 6/16/07.
//  Copyright 2007 PaleoTerra. All rights reserved.
//
/*!
@header
 @class NCDFSeriesVariable
 @abstract NCDFSeriesVariable objects for accessing netcdf variables over multiple files 
 @discussion NCDFSeriesVariable is an immutable class designed to allow a programmer to access netcdf data over multiple files using standard notation.  This approach simplifies multi-file access by hiding the complexity of accessing each file into one simplified interface.
 */
#import <Cocoa/Cocoa.h>


@interface NCDFSeriesVariable : NSObject {
    NSString *_variableName;
    nc_type _dataType;
	NSString *_typeName;
    NCDFSeriesHandle *_seriesHandle;
	NSArray *_theDims;
	int _unlimitedDimLocation;
}


/*! 
@method -(id)initWithVariable:(NCDFVariable *)aVar fromHandle:(NCDFSeriesHandle *)aHandle
@abstract Initialize a new NCDFSeriesVariable using a NCDFVariable and NCDFSeriesHandle.
@param aVar NCDFVariable object.  Typically the root NCDFHandle from NCDFSeriesHandle.
@discussion Initializes a new NCDFSeriesVariable.  This method should be considered private and should not be instanciated outside of an NCDFSeriesHandle.  This variable class is also limited to variables that use an unlimited dimension, otherwise use a NCDFVariable object derived from a NCDFHandle.
*/
-(id)initWithVariable:(NCDFVariable *)aVar fromHandle:(NCDFSeriesHandle *)aHandle;


//reading

	/*! 
@method -(NSData *)readAllVariableData
	@abstract Read all variable data.
	@discussion Returns all data in a NSData object. The NSData object includes data from all files in order.
	*/
-(NSData *)readAllVariableData;

	/*! 
	@method -(NSString *)variableName
	@abstract Returns variable name.
	@discussion Returns variable name as a NSString object.
	*/
-(NSString *)variableName;

	/*! 
	@method -(NSString *)variableType
	@abstract Returns variable type.
	@discussion Returns variable type as a NSString object.  Type strings include NC_CHAR,NC_INT, and several others.
	*/
-(NSString *)variableType;

	/*! 
	@method -(nc_type)variableNC_TYPE
	@abstract Returns variable type.
	@discussion Returns variable type as a netcdf type (nc_type) value.
	*/
-(nc_type)variableNC_TYPE;

	/*! 
	@method -(NSString *)variableDimDescription
	@abstract Returns a simplified dimension description.
	@discussion Returns a human-readable description string for the dimensions describing the variable using a standard bracketing style: e.g. [time, lat, lon].
	*/
-(NSString *)variableDimDescription;

	/*! 
	@method -(NSString *)dataTypeWithDimDescription
	@abstract Returns a variable type and simplified dimension description.
	@discussion Returns a human-readable description string for the variable type and dimensions.  This is a combination of variableType and variableDimDescription methods.
	*/
-(NSString *)dataTypeWithDimDescription;

	/*! 
	@method -(NCDFAttributes *)getVariableAttributes
	@abstract Returns an array of NCDFAttributes for the variable.
	@discussion Returns an array of NCDFAttributes derived from the root NCDF handle representing the attributes of the receiver.
	*/
-(NSArray *)getVariableAttributes;


	/*! 
	@method -(id)getSingleValue:(NSArray *)coordinates
	@abstract Returns a single value as an id value.
	@param coordinates NSArray object with the coordinates of the data using NSNumber intValues.
	@discussion Returns a single value.  See NCDFVariable getSingleValue method for more information.  This method is transparent to which file contains the data. 
	*/
-(id)getSingleValue:(NSArray *)coordinates;

	/*! 
	@method -(NSData *)getValueArrayAtLocation:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths
	@abstract Returns selected data as an NSData object.
	@param startCoordinates NSArray object with the coordinates of the data using NSNumber intValues. Values range from 0 to dimension length -1 for each dimension (in significance order).
	@param edgeLengths NSArray object with the lengths of the data along dimensions using NSNumber intValues. Values range from 1 to dimension length  for each dimension (in significance order).
	@discussion Returns an NSData object containing all selected data.  The data will automatically span files.
	*/
-(NSData *)getValueArrayAtLocation:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths;

	/*! 
	@method -(BOOL)isDimensionVariable
	@abstract Returns whether the variable represents the values of a dimension
	@discussion If the variable name matches a dimension name, the variable is assumed to be a dimension variable.
	*/
-(BOOL)isDimensionVariable;

	/*! 
	@method -(int)sizeUnitVariable
	@abstract Returns the size of the variable in value counts for a unlimited variable unit.
	@discussion This method returns the size of the variable in counts of values for each unlimited step or, when the variable has no unlimited variable, the count of the entire variable.
	*/
-(int)sizeUnitVariable;

	/*! 
	@method -(int)sizeUnitVariableForType
	@abstract Returns the size of the variable in bytes for a unlimited variable unit.
	@discussion This method returns the size of the variable in bytes for each unlimited step or, when the variable has no unlimited variable, the bytes of the entire variable.
	*/
-(int)sizeUnitVariableForType;

	/*! 
	@method -(int)currentVariableSize
	@abstract Returns the total size of the variable in counts for a unlimited variable unit.
	@discussion This method returns the count size of the variable.
	*/
-(int)currentVariableSize;

	/*! 
	@method -(int)currentVariableSize
	@abstract Returns the total size of the variable in bytes for a unlimited variable unit.
	@discussion This method returns the byte size of the variable.
	*/
-(int)currentVariableByteSize;

	/*! 
	@method -(NSArray *)lengthArray
	@abstract Returns an array with the lengths of each dimension in significance order.
	@discussion This method returns the lengths of each dimension used by a variable. These lengths account for multiple files.
	*/
-(NSArray *)lengthArray;

	/*! 
	@method -(BOOL)isUnlimited
	@abstract Returns a boolean whether the variable uses an unlimited variable
	
	*/
-(BOOL)isUnlimited;

	/*! 
	@method -(BOOL)doesVariableUseDimensionName:(NSString *)aDimName
	@param aDimName the name of the requested dimension.
	@abstract Returns a boolean on whether the variable uses a dimension with the name aDimName.

	*/
-(BOOL)doesVariableUseDimensionName:(NSString *)aDimName;
	/*! 
	@method -(int)unlimitedVariableLength
	@abstract Returns the length of the unlimited dimension used by the variable.

	*/
-(int)unlimitedVariableLength;

	/*! 
	@method -(NSArray *)dimensionNames
	@abstract Returns the names of the dimensions, in significance order, as an array of NSString objects.

	*/
-(NSArray *)dimensionNames;

	/*! 
	@method -(NSArray *)allVariableDimInformation
	@abstract Returns a NSArray containing all of the NCDFSeriesDimensions used by the receiver.

	*/

-(NSArray *)allVariableDimInformation;

	/*! 
	@method -(NCDFAttribute *)variableAttributeByName:(NSString *)name
	@abstract Returns an NCDFAttribute used by the variable from the root handle by name.

	*/
-(NCDFAttribute *)variableAttributeByName:(NSString *)name;

	/*! 
	@method -(NSString *)stringValueForSingleValueCoordinates:(NSArray *)coordinates
	@abstract Obtains a value from the coordinates and formats the result as a NSString and returns.
	@discussion This method is a convienence method for accessing a value and formating into a string.

	*/
-(NSString *)stringValueForSingleValueCoordinates:(NSArray *)coordinates;

	/*! 
	@method -(int)attributeCount
	@abstract Returns the count of the 
	@discussion This method is a convienence method for accessing a value and formating into a string.

	*/
-(int)attributeCount;

	/*! 
	@method -(NCDFSlab *)getSlabForStartCoordinates:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths
	@abstract Returns a slab of data for later access using start coordinates and length coordinates.
	@discussion This method returns an NCDFSlab object containing the requested data.  Accessing data from slabs allows faster data access than through file I/O and affords some thread safety.  This method can span multiple files.

	*/
-(NCDFSlab *)getSlabForStartCoordinates:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths;
	/*! 
	@method -(NCDFSlab *)getAllDataInSlab
	@abstract Returns a slab of data for later access using all data available for the variable..
	@discussion This method returns an NCDFSlab object containing the requested data.  Accessing data from slabs allows faster data access than through file I/O and affords some thread safety.  This method will span all files.

	*/
-(NCDFSlab *)getAllDataInSlab;
@end
