//
//  NCDFAttribute.h
//  netcdf
//
//  Created by tmoore on Wed Feb 13 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <netcdf.h>

/*!
    @defined NCDFAttributePropertyListType
    @discussion Defines the standard string for copy/paste types for NCDFAttribute property lists encoded using NSArchiving.
*/
#define NCDFAttributePropertyListType @"NCDFAttributePropertyListType"

/*!
    @defined NCDFAttributePropertyListFieldFileName
    @discussion Defines the string used for accessing property list fields.  This string accesses the file name.
*/
#define NCDFAttributePropertyListFieldFileName @"fileName"

/*!
    @defined NCDFAttributePropertyListFieldVariableID
    @discussion Defines the string used for accessing property list fields.  This string accesses the owner variable ID.
*/
#define NCDFAttributePropertyListFieldVariableID @"variableID"

/*!
    @defined NCDFAttributePropertyListFieldAttributeName
    @discussion Defines the string used for accessing property list fields.  This string accesses the attribute name.
*/
#define NCDFAttributePropertyListFieldAttributeName @"attributeName"

/*!
    @defined NCDFAttributePropertyListFieldNC_TYPE
    @discussion Defines the string used for accessing property list fields.  This string accesses the nc_type (NSNumber object).
*/
#define NCDFAttributePropertyListFieldNC_TYPE @"nc_type"

/*!
    @defined NCDFAttributePropertyListFieldLength
    @discussion Defines the string used for accessing property list fields.  This string accesses the length (NSNumber object).
*/
#define NCDFAttributePropertyListFieldLength @"length"

/*!
    @defined NCDFAttributePropertyListFieldValues
    @discussion Defines the string used for accessing property list fields.  This string accesses the values array
*/
#define NCDFAttributePropertyListFieldValues @"values"

@class NCDFHandle,NCDFErrorHandle;

/*!
@header
 @class NCDFAttribute
 @abstract NCDFAttribute objects handle information about netcdf attributes
 @discussion NCDFAttribute objects are the primary control objects for both netcdf global attributes and variable attributes.  NCDFHandles and NCDFVariables are the primary classes that should create NCDFAttribute object.  Attributes contain metadata information about a netcdf file or variable.  
 */
@interface NCDFAttribute : NSObject {
    NSString *fileName;
    int32_t variableID;
    NSString *attName;
    nc_type type;
    size_t length;
    NSMutableArray *theValues;
    NCDFHandle *theHandle;
    NCDFErrorHandle *theErrorHandle;
}


/*! 
    @method initWithPath
    @abstract Initializes an attribute from a file.
    @discussion This method is the standard for creating a NCDFAttribute from file data.  
    @param thePath NSString object containing the path to the netCDF file.
    @param theName NSString name of the attribute
    @param theID The ID of the variable that owns the attribute.  A value of -1 specifies a global attribute.
    @param dataLength The length, in number of units, of the contents of the attribute.
    @param theType Specify the netCDF data type (nc_type).
    @param handle The owning NCDFHandle of the attribute or variable.
*/
-(id)initWithPath:(NSString *)thePath name:(NSString *)theName variableID:(int)theID length:(size_t)dataLength type:(nc_type)theType handle:(NCDFHandle *)handle;

/*! 
    @method initWithName
    @abstract Initializes an new attribute with an assigned name and value.
    @discussion This method should be used when no netCDF file is currently assigned to the attribute.  
    @param theName NSString name of the attribute
    @param dataLength The length, in number of units, of the contents of the attribute.
    @param theType Specify the netCDF data type (nc_type).
    @param newValues NSArray object containing each value to be assigned to the attribute.
    All single byte values, characters, and character strings are stored as an NSString object in the array.  All other values are stored in the array as NSNumber objects.
*/
-(id)initWithName:(NSString *)theName length:(size_t)dataLength type:(nc_type)theType valueArray:(NSArray *)newValues;

	/*! 
    @method handleLock
    @abstract Returns an NSLock object from the owning NCDFHandle object.
	*/
-(NSLock *)handleLock;


/*! 
    @method loadValues
    @abstract Loads the values stored by the attribute.
    @discussion This method accesses attribute information from an existing netcdf file.  Called during initialization.
*/
-(void)loadValues;

/*! 
    @method attributeName
    @abstract Returns the attribute name as a NSString object.
*/
-(NSString *)attributeName;

/*! 
    @method contentDescription
    @abstract returns the contents of the attribute as a NSString object.  For NC_CHAR type, it returns a string, for all others, it returns a string of delimited values.
*/
-(NSString *)contentDescription;

/*! 
    @method stringFromObject:
    @param object either NSData or NSString object containing the attribute data.
    @abstract Called by contentDescription.  Takes either an NSData object (for numbers) or an NSString  object (for NC_CHAR) and converts to an NSString object.  This should not be called by any method other than contentDescription.
*/
-(NSString *)stringFromObject:(id)object;

/*! 
    @method parseNameString:
    @param theString a NSString object
    @abstract Parses the string for compliance to netcdf attribute, dimension, and variable naming rules.  If the string does not comply, it is converted to a compatible string.
*/
-(NSString *)parseNameString:(NSString *)theString;

/*! 
    @method renameAttribute:
    @param newName a NSString object
    @abstract Changes the name of an attribute.  Returns YES if successful.  Generates an NCDFError if not.
*/
-(BOOL)renameAttribute:(NSString *)newName;

/*! 
    @method getAttributeValueArray
    @abstract Returns a NSArray object containing the values held by the attribute.  If a numerical value array, the array will contain one object for each value.  If a NC_CHAR value, the array will only contain one NSString object.
*/
-(NSArray *)getAttributeValueArray;

/*! 
    @method isEqualToAttribute:
    @param anAttribute a NCDFAttribute object
    @abstract Tests whether the reciever and anAttribute are essentially the same attribute. However, it does this by ONLY comparing attribute names.  Values held by the attribute are not compared.  Returns YES if successful. 
*/
-(BOOL)isEqualToAttribute:(NCDFAttribute *)anAttribute;

/*! 
    @method attributeNC_TYPE
    @abstract Returns the nc_type of the attribute values.
*/
-(nc_type)attributeNC_TYPE;

/*! 
    @method attributeLength
    @abstract Returns the length of the attribute value contents.  The length is defined by the number of values stored.
*/
-(size_t)attributeLength;

/*! 
    @method setValueArray:
    @abstract Sets the value array for an attribute.  This should only be called by one of the initialization methods or by the NCDFHandle when creating a new attribute.
*/
-(void)setValueArray:(NSArray *)anArray;

/*! 
    @method attributeOwnerName:
    @abstract Returns the name of the owner of the attribute.
    @discussion  An attribute may be owned by an NCDFHandle or a NCDFVariable.  If it is owned by the NCDFHandle, it will return the following string object: "Global".  However, if owned by a variable, it will return the name of the variable.
*/
-(NSString *)attributeOwnerName;

/*! 
    @method isGlobal
    @abstract Returns whether the attribute is owned by a NCDFHandle.
    @discussion  Returns YES if the owner is a NCDFHandle.  Otherwise, it is not owned or owned by a NCDFVariable.
*/
-(BOOL)isGlobal;

/*! 
    @method ownerVariableID
    @abstract Returns the ID number of the owner.
    @discussion  The ID number returned is the ID number of a variable.  However, if the ID number is equal to NC_GLOBAL, then the owner is the NCDFHandle.
*/
-(int)ownerVariableID;

/*! 
    @method propertyList
    @abstract Returns a NSDictionary containing all relevent attribute information in objects that are compatible with property lists.
    @discussion  Converts the attribute into NSString, NSNumber, etc. objects within an NSDictionary.  It can be used for drag/drop/copy/paste.
    Fields:
    NCDFAttributePropertyListFieldFileName - path string to file.
    NCDFAttributePropertyListFieldVariableID - ID number of owning object
    NCDFAttributePropertyListFieldAttributeName - name of the attribute
    NCDFAttributePropertyListFieldNC_TYPE - the nc_type stored as an NSNumber object (integer) for the value type.
    NCDFAttributePropertyListFieldLength - the number of values stored as an NSNumber object (integer)
    NCDFAttributePropertyListFieldValues - The actual values stored in an array.  All values in single NSNumber objects except for NC_CHAR which are stored in a single NSString object.
*/
-(NSDictionary *)propertyList;

	/*! 
    @method variableID
    @abstract Returns the ID number of the owner.
    @discussion  The ID number returned is the ID number of a variable.  However, if the ID number is equal to NC_GLOBAL, then the owner is the NCDFHandle.  (Same as ownerVariableID method)
	*/
-(int)variableID;

	/*! 
    @method updateAttributeWithAttribute:
    @abstract Updates the receiver with information from a new NCDFAttribute.
    @discussion  This method replaces all the information in an attribute with the information in anAtt, generally used for updated the object from file.  This method should be considered a private method.
	*/
-(void)updateAttributeWithAttribute:(NCDFAttribute *)anAtt;

	/*! 
    @method compare:
    @abstract Compares two NCDFAttribute object's variable ID.
    @discussion  This method can be used to sort NCDFAttribute objects using their variable IDs.  Returns NSOrderedAccending,NSOrderedDecending, or NSOrderedSame.
	*/
-(NSComparisonResult)compare:(id)object;

@end
