//
//  NCDFVariable.h
//  netcdf
//
//  Created by tmoore on Wed Feb 13 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

/*!
@header
  @class NCDFVariable
@abstract NCDFVariable objects handle data sets within netcdf files.
    @discussion NCDFVariable objects are the primary interface for working with netcdf data sets.  The datasets are in the form of binary raster data using 0 to many dimensions.  The dimensions refered to by a variable describe the variable's data shape.  Use this class to access and write data from a netcdf file.  
*/



#import <Foundation/Foundation.h>
#import <AppKit/NSPanel.h>
#import "NCDFAttribute.h"

/*!
    @defined NCDFVariablePropertyListType
    @discussion Defines the standard string for copy/paste types for NCDFVariable property lists encoded using NSArchiving.
*/
#define NCDFVariablePropertyListType @"NCDFVariablePropertyListType"

/*!
    @defined NCDFVariablePropertyListFieldFileName
    @discussion Defines the string used for accessing property list fields.  This string accesses the filename.
*/
#define NCDFVariablePropertyListFieldFileName @"fileName"

/*!
    @defined NCDFVariablePropertyListFieldVariableID
    @discussion Defines the string used for accessing property list fields.  This string accesses the variable ID number.
*/
#define NCDFVariablePropertyListFieldVariableID @"variableID"

/*!
    @defined NCDFVariablePropertyListFieldVariableName
    @discussion Defines the string used for accessing property list fields.  This string accesses the variable name.
*/
#define NCDFVariablePropertyListFieldVariableName @"variableName"

/*!
    @defined NCDFVariablePropertyListFieldNC_TYPE
    @discussion Defines the string used for accessing property list fields.  This string accesses the NSNumber object storing the nc_type.
*/
#define NCDFVariablePropertyListFieldNC_TYPE @"nc_type"

/*!
    @defined NCDFVariablePropertyListFieldDimensionNames
    @discussion Defines the string used for accessing property list fields.  This string accesses the array of dimension names.
*/
#define NCDFVariablePropertyListFieldDimensionNames @"dimNames"

/*!
    @defined NCDFVariablePropertyListFieldData
    @discussion Defines the string used for accessing property list fields.  This string accesses the variable data.
*/
#define NCDFVariablePropertyListFieldData @"data"

/*!
    @defined NCDFVariablePropertyListFieldAttributes
    @discussion Defines the string used for accessing property list fields.  This string accesses the attribute property list array.
*/
#define NCDFVariablePropertyListFieldAttributes @"attributes"


@class NCDFHandle,NCDFAttribute,NCDFSlab;
@interface NCDFVariable : NSObject {
    NSString *fileName;
    int varID;
    NSString *variableName;
    nc_type dataType;
    NSArray *dimIDs;
    int numberOfAttributes;
    NSArray *attributes;//NCDFAttributes
    NCDFHandle *theHandle;
    NCDFErrorHandle *theErrorHandle;
}


/*! 
    @method initWithPath:variableName:variableID:type:theDims:attributeCount:handle:
    @abstract Initialize a new NCDFVariable object.
    @param thePath NSString object containing the path to the parent netcdf file
    @param theName NSString object containing the name of the variable
    @param theID Int value representing the variable ID number
    @param theType nc_type of the data
    @param theDims NSArray of dimension ID numbers in significance order
    @param attributeCount The number of attributes owned by variable
    @param handle NCDFHandle object owning the receiver
    @discussion Initializes a new NCDFVariable object.  This should only be called by a NCDFHandle object
*/
-(id)initWithPath:(NSString *)thePath variableName:(NSString *)theName variableID:(int)theID type:(nc_type)theType theDims:(NSArray *)theDims attributeCount:(int)nAtt handle:(NCDFHandle *)handle;

-(NSLock *)handleLock;

-(NSData *)readAllVariableData;

/*! 
    @method variableName:
    @abstract Get variable name.
    @discussion Retrieves the variable name and returns an NSString object.
*/
-(NSString *)variableName;

/*! 
    @method renameVariable:
    @param newName NSString with a new variable name
    @abstract Rename a variable.
    @discussion Replaces a reciever's name with newName.  Will generate an NCDFError if fails and return NO.
*/
-(BOOL)renameVariable:(NSString *)newName;


/*! 
    @method variableType
    @abstract Identify the nc_type used by the variable.
    @discussion Returns the receiver's nc_type in a NSString object form.
*/
-(NSString *)variableType;

/*! 
    @method variableNC_TYPE
    @abstract Identify the nc_type used by the variable.
    @discussion Returns the receiver's nc_type.
*/
-(nc_type)variableNC_TYPE;

/*! 
    @method writeAllVariableData:
    @param dataForWriting NSData object for writing
    @abstract Completely replace an NCDFVariable's data object in file..
    @discussion Simple data replace beginning at position 0 in all dimensions. If the dataForWriting is smaller than the space available, then the data will be replaced for the length of new data.  The remainder will be uneffected.  If dataForWriting is longer than the available space and does not use an unlimited dimension, then data will be filled only up to the end of available space.  If an unlimited dimension is used, then space will be made available.  Posts an NCDFError if fails.
*/
-(void)writeAllVariableData:(NSData *)dataForWriting;

/*! 
    @method variableDimensions
    @abstract Returns a list of dimensions used by the variable.
    @discussion Returns a NSArray object containing NSNumber objects that hold the dimension ID numbers of each dimension used, in significance order.
*/
-(NSArray *)variableDimensions;

/*! 
    @method variableDimDescription
    @abstract Creates a summary description of the dimension information.
    @discussion Returns a NSString object containing a string version of the list of dimensions, in significance order, using the standard bracketed format, e.g. [time, lat, lon]
*/
-(NSString *)variableDimDescription;

/*! 
    @method dataTypeWithDimDescription
    @abstract Creates a summary description of the dimension and nc_type information.
    @discussion Returns a NSString object containing a string version of the nc_type with a list of dimensions, in significance order, using the standard bracketed format, e.g. [timen, lat, lon]
*/
-(NSString *)dataTypeWithDimDescription;

/*! 
    @method createNewVariableAttributeWithName:dataType:values
    @abstract Creates a new variable attribute.
    @param attName NSString with the new attribute name
    @param theType nc_type of the values
    @param theValues an Array of values 1 NSString object if NC_CHAR, otherwise multiple NSNumber objects as needed.
    @discussion Creates a new attribute owned by the receiver.  
*/
-(BOOL)createNewVariableAttributeWithName:(NSString *)attName dataType:(nc_type)theType values:(NSArray *)theValues;

/*! 
    @method createNewVariableAttributePropertyList:
    @abstract Creates a new variable attribute.
    @discussion Creates a new attribute owned by the receiver.  Uses the standard property list format defined in NCDFAttribute.
    
        
    Required fields:<P>
    NCDFAttributePropertyListFieldAttributeName<P>
    NCDFAttributePropertyListFieldNC_TYPE<P>
    NCDFAttributePropertyListFieldValues
*/
-(BOOL)createNewVariableAttributePropertyList:(NSDictionary *)propertyList;

/*! 
    @method getVariableAttributes
    @abstract Returns an array of attributes.
    @discussion Returns an array of NCDFAttributes owned by the receiver.

    
*/
-(NSArray *)getVariableAttributes;

/*! 
    @method deleteVariableAttributeByName:
    @param name a NSString object containing the name of the variable
    @abstract Delete a variable attribute.
    @discussion Deletes a variable attribute by name from the receiver's file, forcing a NCDFHandle refresh.  Once deleted, the variable attribute is unrecoverable.  This method uses a temporary file during the process.  Creates an NSError if fails and will return a NO.
*/
-(BOOL)deleteVariableAttributeByName:(NSString *)name;

/*! 
    @method parseNameString:
    @param theString a NSString object
    @abstract Parses the string for compliance to netcdf attribute, dimension, and variable naming rules.  If the string does not comply, it is converted to a compatible string.
*/
-(NSString *)parseNameString:(NSString *)theString;

/*! 
    @method writeSingleValue:withValue
    @abstract Write a single value of variable data.
    @param coordinates An integer array with an NSNumber objects representing the position along each dimension in significance order of a datum.
    @discussion Writes a single value at position coordinates.  Use a NSData object (if NC_BYTE), NSString object (if NC_CHAR), or NSNumber object.   Returns YES if successful.

*/
-(BOOL)writeSingleValue:(NSArray *)coordinates withValue:(id)value;

/*! 
    @method writeValueArrayAtLocation:edgeLengths:
    @abstract Write a subset of variable data.
    @param startCoordinates An integer array with an NSNumber object representing the start position along each dimension in significance order.
    @param edgeLengths An integer array with an NSNumber object representing the number of units to be written along each dimension in significance order.
    @discussion The method is the fundimental data writing method for NCDFVariable.  Returns a YES if successful.

*/
-(BOOL)writeValueArrayAtLocation:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths withValue:(NSData *)dataObject;

/*! 
    @method getSingleValue:
    @abstract Access a single value of variable data.
    @param coordinates An integer array with an NSNumber objects representing the position along each dimension in significance order of a datum.
    @discussion Returns a NSData object (if NC_BYTE), NSString object (if NC_CHAR), or NSNumber object containing the data or nil if unsuccessful.

*/
-(id)getSingleValue:(NSArray *)coordinates;


/*! 
    @method getValueArrayAtLocation:edgeLengths:
    @abstract Access a subset of variable data.
    @param startCoordinates An integer array with an NSNumber object representing the start position along each dimension in significance order.
    @param edgeLengths An integer array with an NSNumber object representing the number of units to be read along each dimension in significance order.
    @discussion The method is the fundimental data reading method for NCDFVariable.  Returns a NSData object containing the data or nil if unsuccessful.

*/
-(NSData *)getValueArrayAtLocation:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths;


/*! 
    @method isDimensionVariable:
    @abstract Returns whether a receiver is a dimension variable.
    @discussion A dimension variable is a variable that has the same name as a dimension.  If the variable name matches that of any dimension, the method returns YES.  Otherwise returns NO.

*/
-(BOOL)isDimensionVariable;

/*! 
    @method sizeUnitVariable:
    @abstract Get the NCDFVariables data unit size in units.
    @discussion Returns the unit size in units for the receiver.  A "unit size" includes a value count based on all dimensions except for any unlimited dimension.  

*/
-(int)sizeUnitVariable;

/*! 
    @method sizeUnitVariableForType:
    @abstract Get the NCDFVariables data unit size in bytes.
    @discussion Returns the unit size in bytes for the receiver.  A "unit size" includes a value count based on all dimensions except for any unlimited dimension.  

*/
-(int)sizeUnitVariableForType;

/*! 
    @method currentVariableSize:
    @abstract Get the NCDFVariables data size in units.

*/
-(int)currentVariableSize;

/*! 
    @method currentVariableByteSize:
    @abstract Get the NCDFVariables data size in bytes.

*/
-(int)currentVariableByteSize;

/*! 
    @method lengthArray:
    @abstract Find the dimension lengths used by the variable.
    @discussion This method returns a NSArray containing dimension lengths in significance order as NSNumber objects.
*/
-(NSArray *)lengthArray;

/*! 
    @method isUnlimited:
    @abstract Determine if the NCDFVariable data structure uses an unlimited dimension.
    @discussion  This method determines if the receiver uses an unlimited dimension.  Returns YES if true.
*/
-(BOOL)isUnlimited;

/*! 
    @method isCompatibleWithVariable:
    @param aVar A NCDFVariable object
    @abstract Examine whether a receiver's data shape is the same as another NCDFVariable object.
    @discussion  This method examines the reciever's data and aVar's data two see whether they have the same: nc_type, unit data size, and full data size.
*/
-(BOOL)isCompatibleWithVariable:(NCDFVariable *)aVar;

/*! 
    @method doesVariableUseDimensionName:
    @param aDimNae A NSString representing a dimension name
    @abstract Query a NCDFVariable if it uses a dimension.
    @discussion  This method will return YES if the receiver uses the dimension with a name equal to aDimName.
*/
-(BOOL)doesVariableUseDimensionName:(NSString *)aDimName;

/*! 
    @method doesVariableUseDimensionID:
    @param aDimID An integer representing a dimension ID number
    @abstract Query a NCDFVariable if it uses a dimension.
    @discussion  This method will return YES if the receiver uses the dimension with an ID number of aDimID.
*/
-(BOOL)doesVariableUseDimensionID:(int)aDimID;

/*! 
    @method createAttributesFromAttributeArray:
    @param newAttributes an array of NCDFAttributes
    @abstract Creates new attributes from an NSArray.
    @discussion  This method will create new attributes from an array of NCDFAttributes.

    PROGRAMMING NOTES - THis method should be modified to add error checking and NCDFError handling.
*/
-(BOOL)createAttributesFromAttributeArray:(NSArray *)newAttributes;

/*! 
    @method unlimitedVariableLength
    @abstract Returns the current length of an unlimited variable.
    @discussion  This method returns the current length of the unlimited Dimension variable.  If the receiver is NOT the dimension variable, then it will return -1.

*/
-(int)unlimitedVariableLength;

/*! 
    @method propertyList
    @abstract Returns an NSDictionary object with the NCDFVariable information stored in property list-compatible objects.
    @discussion  Returns a property list dictionary for the NCDFVariable.
    
    Fields:<P>
    NCDFVariablePropertyListFieldFileName - NSString containing the path of the parent file.<P>
    NCDFVariablePropertyListFieldVariableID - variable ID number<P>
    NCDFVariablePropertyListFieldVariableName - NSString object storing the variable name<P>
    NCDFVariablePropertyListFieldNC_TYPE - NSNumber object (integer) containing the nc_type<P>
    NCDFVariablePropertyListFieldDimensionNames - An NSArray containing only the NSDimension names (in significance order)<P>
    NCDFVariablePropertyListFieldData - NSData containing all variable data<P>
    NCDFVariablePropertyListFieldAttributes - An NSArray of NCDFAttribute property lists<P>
    

*/
-(NSDictionary *)propertyList;


/*! 
    @method dimensionNames
    @abstract Returns an array of NCDFDimension names as NSStrings.
    @discussion  Returns an array of NCDFDimension names used by the NCDFVariable.  The order within the array represents the dimension significance.  A dim at position 0 will have the highest significance.

*/
-(NSArray *)dimensionNames;

/*! 
    @method allVariableDimInformation
    @abstract Returns an array of NCDFDimensions.
    @discussion  Returns an array of NCDFDimensions used by the NCDFVariable.  The order within the array represents the dimension significance.  A dim at position 0 will have the highest significance.

*/
-(NSArray *)allVariableDimInformation;

/*! 
    @method reverseAndStoreDataAlongDimensionName:
    @param theDimName NSString object with an dimension name
    @abstract Reverses data along a dimension and writes to file.
    @discussion  Flips the order of the data along a dimension.  For example, values stored at 0,1,2,3,4,5 would be reversed to 5,4,3,2,1.  Returns YES if successfully written to file.

*/
-(BOOL)reverseAndStoreDataAlongDimensionName:(NSString *)theDimName;

/*! 
    @method reverseDataAlongDimensionName:
    @param theDimName NSString object with an dimension name
    @abstract Reverses data along a dimension.
    @discussion  Flips the order of the data along a dimension.  For example, values stored at 0,1,2,3,4,5 would be reversed to 5,4,3,2,1.

*/
-(NSData *)reverseDataAlongDimensionName:(NSString *)theDimName;

/*! 
    @method shiftAndStoreDataAlongDimensionName:shift
    @param theDimName NSString object with an dimension name
    @param theShift A int value desribing the direction and count of the shift
    @abstract Shifts data along a dimension and stores the result.
    @discussion  Shifts data along a dimension according the theShift value.  If theShift is positive, values stored at 0 are moved to a higher position, such as 1.  Values at the end of the dimension are rotated back to the begining.  For example, data at postion 9 with dim length of 10 (0 - 9) would be moved to position 0 if theShift value = 1.  Returns YES if writing is successful.

*/
-(BOOL)shiftAndStoreDataAlongDimensionName:(NSString *)theDimName shift:(int)theShift;

/*! 
    @method shiftDataAlongDimensionName:shift
    @param theDimName NSString object with an dimension name
    @param theShift A int value desribing the direction and count of the shift
    @abstract Shifts data along a dimension
    @discussion  Shifts data along a dimension according the theShift value.  If theShift is positive, values stored at 0 are moved to a higher position, such as 1.  Values at the end of the dimension are rotated back to the begining.  For example, data at postion 9 with dim length of 10 (0 - 9) would be moved to position 0 if theShift value = 1.

*/
-(NSData *)shiftDataAlongDimensionName:(NSString *)theDimName shift:(int)theShift;

/*! 
    @method variableAttributeByName:
    @param name NSString object with an attribute name
    @abstract Access a NCDFVariable's attribute by name.
    @discussion  Returns a NCDFAttribute object owned by the variable.

*/
-(NCDFAttribute *)variableAttributeByName:(NSString *)name;

	/*! 
	@method htmlDescription:
    @abstract Returns a description of the variable and all of its attributes in an html form.
    @discussion  This method is to provide a method to export the metadata of a netcdf file into a HTML document.
	*/
-(NSString *)htmlDescription;

-(NSString *)typeDescription;

-(NSString *)stringValueForSingleValueCoordinates:(NSArray *)coordinates;
-(int)variableID;
-(int)attributeCount;
-(void)updateVariableWithVariable:(NCDFVariable *)aVar;
-(NCDFSlab *)getSlabForStartCoordinates:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths;
-(NCDFSlab *)getAllDataInSlab;
@end
