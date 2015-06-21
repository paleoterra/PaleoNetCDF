//
//  NCDFDimension.h
//  netcdf
//
//  Created by tmoore on Wed Feb 13 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NCDFProtocols.h"
/*!
    @defined NCDFDimensionPropertyListType
    @discussion Defines the standard string for copy/paste types for NCDFDimension property lists encoded using NSArchiving.
*/
#define NCDFDimensionPropertyListType @"NCDFDimensionPropertyListType"

/*!
    @defined NCDFAttributePropertyListFieldFileName
    @discussion Defines the string used for accessing property list fields.  This string accesses the file name.
*/
#define NCDFDimensionPropertyListFieldFileName @"fileName"

/*!
    @defined NCDFAttributePropertyListFieldDimensionID
    @discussion Defines the string used for accessing property list fields.  This string accesses the dimension ID number.
*/
#define NCDFDimensionPropertyListFieldDimensionID @"dimID"

/*!
    @defined NCDFAttributePropertyListFieldDimensionName
    @discussion Defines the string used for accessing property list fields.  This string accesses the dimension name.
*/
#define NCDFDimensionPropertyListFieldDimensionName @"dimName"

/*!
    @defined NCDFAttributePropertyListFieldLength
    @discussion Defines the string used for accessing property list fields.  This string accesses the dimension length (NSNumber).
*/
#define NCDFDimensionPropertyListFieldLength @"length"

@class NCDFHandle,NCDFErrorHandle;


/*!
@header
 @class NCDFDimension
 @abstract NCDFDimension objects handle information about netcdf dimensions
 @discussion
 NCDFDimension is the primary object to access and change an individual netcdf file.  Objects from this class should only be created in a few ways.  First, NCDFHandle is responsible for creating all NCDFDimension objects for a netcdf file.  For copy/paste/drag/drop, use the propertylist command to obtain a copy and implement an NSArchiver.
 */
@interface NCDFDimension : NSObject <NCDFImmutableDimensionProtocol>{
    NSString *fileName;
    int32_t dimID;
    NSString *dimName;
    size_t length;
    NCDFHandle *theHandle;
    NCDFErrorHandle *theErrorHandle;
}

/*!
  @method initWithFileName:dimID:name:length:handle:
  @abstract Initializes a new NCDFDimension for a dimension within a file.
  @param thePath the path to an existing netcdf file.
  @param number the dimension identification number.  This should be handled by NCDFHandle.
  @param name NSString with the dimension name.  If the string is not consistent with netcdf naming rules, it will be parsed.
  @param length The length of the dimension in units.
  @param handle The owning NCDFHandle.
  @discussion This is the standard method for creating a NCDFDimension from a dimension in an existing file.  This method should only be invoked by a parent NCDFHandle.





  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(id)initWithFileName:(NSString *)thePath dimID:(int)number name:(NSString *)name length:(size_t)length handle:(NCDFHandle *)handle;

/*!
  @method initNewDimWithName:length:
  @abstract Initializes a new NCDFDimension object.
  @param name NSString with the dimension name.  If the string is not consistent with netcdf naming rules, it will be parsed.
  @param length The length of the dimension in units.
  @discussion This method is for creating an independent NCDFDimension, that is, one without an owning NCDFHandle object.  It's not recommended that this method is used.





  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(id)initNewDimWithName:(NSString *)name length:(size_t)aLength;

	/*!


    @method handleLock
    @abstract Returns an NSLock object from the owning NCDFHandle object.
	*/
-(NSLock *)handleLock;

/*!
  @method dimensionName
  @abstract Access the dimension name.

  @discussion This method is for accessing the dimension file name.







  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(NSString *)dimensionName;

/*!
  @method dimLength
  @abstract Access the dimension dimLength.





  @discussion This method is for accessing the dimension length.  In the case of unlimited dimensions, it will return the current length of the dimension (check if correct).  This method cannot determine whether a dimension is unlimited.





  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(size_t)dimLength;

/*!
  @method setDimLength
  @abstract Set the dimension dimLength.
  @param newLength Length in units.
  @discussion This method will change the length of the dimension.  In some cases, it may be possible to set the dimension as unlimited by setting the length to 0.  In this case, no unlimited dimensions can exist in the file prior to setting a dimension to unlimited length.





  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(void)setDimLength:(size_t)newLength;

/*!
  @method dimensionID
  @abstract Access the dimension id.
@discussion Dimension ID numbers are how variables define the shape of the datasets.  Thus a variable will refer to a series of dimension ID numbers representing each dimension in the dataset shape.  Hence, a caller cannot set the dimension ID number.







  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(int)dimensionID;

/*!
  @method renameDimension
  @abstract Renames a dimension.
    @discussion Dimensions can be renamed using a NSString object that complies with the netcdf naming standards.  If the string does not meet those standards, the string will be parsed in order to comply







  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(BOOL)renameDimension:(NSString *)newName;

/*!
  @method parseNameString:
  @abstract Parses a new name string to ensure compliance with netcdf naming standards.
  @param theString NSString of the name string.
    @discussion Ensures that a name string is valid for writing to file.  This method is called whenever a new name is being written to file.  Also see NCDFNameFormatter for GUI-based formatting.

  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(NSString *)parseNameString:(NSString *)theString;

/*!
  @method isEqualToDim:
  @abstract Determines if two dimensions are equal.
  @param aDimension
    @discussion The reciever checks whether aDimension has an identical name string and dimension length.  If they do, the method returns YES, otherwise returns NO.

  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(BOOL)isEqualToDim:(NCDFDimension *)aDimension;

/*!
  @method isUnlimited
  @abstract Determines if a dimensions is unlimited.
    @discussion The reciever checks whether it represents an unlimited dimension.  An unlimited dimension is one that is allowed to lengthen automattically as data is appended to the file.

  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(BOOL)isUnlimited;

/*!
  @method propertyList
  @abstract Returns a NSDictionary property list.
    @discussion Returns a NSDictionary representation that can contains only propertyList compatible objects.  A property list will have the following items:
  Fields:<P>
  NCDFDimensionPropertyListFieldFileName<P>
  NCDFDimensionPropertyListFieldDimensionID<P>
  NCDFDimensionPropertyListFieldDimensionName<P>
  NCDFDimensionPropertyListFieldLength<P>





  Note: Using this method to create a new dimension in a file can have unexpected results when working with unlimited dimensions.  Since length represents the actual length of a dimension, using a property list to create the same dimension elsewhere will cause the dimension to be LIMITED in length.  Reset to 0 if unlimited.





  In future versions, a new field will be added to determine if unlimited.
  <P>





  VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(NSDictionary *)propertyList;

	/*!


    @method updateDimensionWithDimension:
    @abstract Updates the receiver with information from a new NCDFDimension.
    @discussion  This method replaces all the information in a dimension with the information in aDim, generally used for updated the object from file.  This method should be considered a private method.
	*/
-(void)updateDimensionWithDimension:(NCDFDimension *)aDim;

	/*!


    @method compare:
    @abstract Compares two NCDFDimension object's variable ID.
    @discussion  This method can be used to sort NCDFDimension objects using their variable IDs.  Returns NSOrderedAccending,NSOrderedDecending, or NSOrderedSame.
	*/
-(NSComparisonResult)compare:(id)object;
@end
