//
//  NCDFHandle.h
//  netcdf
//
//  Created by tmoore on Wed Feb 13 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

// to deprecate methods, use __attribute__ ((deprecated));

#import <Foundation/Foundation.h>
#import <netcdf.h>

//added 0.2.1d1
@class NCDFErrorHandle,NCDFError,NCDFDimension,NCDFAttribute,NCDFVariable;

/*!
@header
 @class NCDFHandle
 @abstract NCDFHandle is the primary class of working with netcdf files
 @discussion NCDFHandle is the primary interface for a netcdf file.  It will automatically discover the contents for a netcdf file for you.  It also allows you to change the overall file structure by adding or removing attributes, dimensions, and variables.  Only one NCDFHandle should exist per netcdf file.  Although a handle may exist, the actual netcdf file is not open except when the handle is conducting a file operation.  It also manages some temporary work files created during the file editing process for protection of the original file.
 */
@interface NCDFHandle : NSObject {
    NSMutableArray *theVariables;
    NSMutableArray *theGlobalAttributes;
    NSMutableArray *theDimensions;
    NSString *filePath;
    NCDFErrorHandle *theErrorHandle;
	NSLock *handleLock;
	NSNumber *_theCompareValue;
	int32_t netcdfVersion;
}

//*****************************INITIALIZATION METHODS***********************************
/*!
  @method initWithFileAtPath
  @abstract Initializes a new NCDFHandle for an existing file.
  @param thePath the path to an existing netcdf file.
  @result An instance of NCDFHandle or nil if failed.
  @discussion This method is the standard method for creating an NCDFHandle.  An example would look like:<P>NCDFHandle *newHandle = [[NCDFHandle alloc] initWithFileAtPath:filePath];<P>If the new NCDFHandle failed and returned a nil, then an NCDFError is created.<P>VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(id)initWithFileAtPath:(NSString *)thePath ;

/*!
  @method initByCreatingFileAtPath
  @abstract Creates a new empty netcdf file and initializes a new NCDFHandle for the new file.
  @param thePath the path requested for a netcdf file.
  @result An instance of NCDFHandle or nil if failed.
  @discussion This method is the standard method for creating an netcdf file and a NCDFHandle. If creating the file should fail, an NCDFError will usually be created. <P>VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(id)initByCreatingFileAtPath:(NSString *)thePath;
-(id)initByCreatingFileAtPath:(NSString *)thePath withSettings:(int)settings;

+(id)handleWithNewFileAtPath:(NSString *)thePath;
+(id)handleWithNew64BitFileAtPath:(NSString *)thePath;
#ifdef DNCDF4
+(id)handleWithNewNetCDF4FileAtPath:(NSString *)thePath;
+(id)handleWithNewClassicNetCDF4FileAtPath:(NSString *)thePath;
#endif



/*!
	@functiongroup Internal Use Only
*/

//*****************************SETUP METHODS***********************************

/*!
  @method theFilePath
  @abstract Accessor for the NCDFHandle's file path.

  @discussion This method allows access to the path for the current netcdf file. <P>VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(NSString *)theFilePath;
/*!
  @method refresh
  @abstract Force reset of the NCDFHandle metadata.
  @discussion This method triggers the reset of all netcdf metadata.  This method should be called when there is reason to believe that the NCDFHandle is no longer in sync with the netcdf file.  Typically this can occur when changing the contents of a netcdf file.  Some methods will automatically call this method.<P>VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(void)refresh;

	/*!
    @method handleLock
    @abstract Returns an NSLock object for the handle.
	*/
-(NSLock *)handleLock;

//*****************************ACCESSORS***********************************

	/*!
	@functiongroup Working With Dimensions
	 */

/*!
  @method getDimensions
  @abstract Retrieves all NCDFDimensions.

  @discussion This method returns all netcdf dimensions for a file in a NSMutableArray.  NSMutableArrays are used so that applications can maintain connection with this array even after the NCDFHandle makes a refresh call.<P>VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(NSMutableArray *)getDimensions;
/*!
  @method getGlobalAttributes
  @abstract Retrieves all NCDFAttributes for global attributes.

  @discussion This method returns all netcdf global attributes for a file in a NSMutableArray.  NSMutableArrays are used so that applications can maintain connection with this array even after the NCDFHandle makes a refresh call. <P>VALIDATION NOTES: Tested extensively and appears to function as expected.
*/
-(NSMutableArray *)getGlobalAttributes;

	/*!
	@functiongroup Working With Variables
	 */

/*!
  @method getVariables
  @abstract Retrieves all NCDFVariables for variables.
  @discussion This method returns all netcdf variables for a file in a NSMutableArray.  NSMutableArrays are used so that applications can maintain connection with this array even after the NCDFHandle makes a refresh call.<P>VALIDATION NOTES: Tested extensively and appears to function as expected.
*/

-(NSMutableArray *)getVariables;
/*!
  @method theErrorHandle
  @abstract Retrieves a pointer to the default NCDFErrorHandle.
  @discussion This method returns the default error handle.  This can be obtained by this method and directly from the error handle itself.  <P>VALIDATION NOTES: Tested extensively and appears to function as expected.
*/

-(NCDFErrorHandle *)theErrorHandle;

//*****************************DIMENSIONS***********************************
/*!
  @method createNewDimensionWithName:size:
  @abstract Creates a new dimension in the netcdf file.
  @param dimName an NSString with the dimension name.
  @param length the length of the dimension in units.
  @discussion This method creates a new dimension.  If fails, returns a NO and creates a NCDFError.  If successful, the NCDFHandle resyncs to file.
*/
-(BOOL)createNewDimensionWithName:(NSString *)dimName size:(size_t)length;
/*!
  @method createNewDimensionWithPropertyList:
  @abstract Creates a new dimension in the netcdf file from a property list.
  @param propertyList a NSDictionary containing a propertylist files for a NCDFDimension.  See NCDFDimension for documentation.
  @discussion This method creates a new dimension.  This method calls createNewDimensionWithName and thus will generate a NCDFError and resync to file.
*/

-(BOOL)createNewDimensionWithPropertyList:(NSDictionary *)propertyList;
/*!
  @method createNewDimensionsFromDimensionArray:
  @abstract Creates multiple new dimensions from an array of NCDFDimensions.
  @param newDimensionArray NSArray of NCDFDimension objects.
  @discussion This method creates multiple dimensions.  If fails, returns a NO and creates a NCDFError.  This method will not overwrite existing dimensions.  If a dimension exists with a name of a dimension in the array, then no attempt will be made to overwrite the old dimension.  Method will resync to file on completion.

*/
-(NSArray *)createNewDimensionsFromDimensionArray:(NSArray *)newDimensionArray;

/*!
  @method deleteDimensionWithName:
  @abstract Deletes a dimension from the netcdf file.
  @param dimName NSString name of the dimension.
  @discussion This method deletes a dimension based on a given dimension name.  If fails, returns a NO and creates a NCDFError.  This method works by creating an empty temporary netcdf file and recreating the old file within the new file minus the deleted dimension.  When complete, the new file is moved to the path of the old file.  The NCDFHandle will then resync to file.
*/
-(BOOL)deleteDimensionWithName:(NSString *)dimName;

/*!
  @method resizeDimensionWithName:size:
  @abstract Resizes a dimension from the netcdf file.
  @param resizeDimName NSString name of the dimension.
 @param newSize integer with the new size of the dimension.
 @discussion This method resizes a dimension based on a given dimension name.  If fails, retunewSizea NO and creates a NCDFError.  This method works by creating an empty temporary netcdf file and recreating the old file within the new file except the dimension length is the newSize.  When complete, the new file is moved to the path of the old file.  The NCDFHandle will then resync to file.  Note, resizing an unlimited dimension may have unexpected results.  A new size to anything but 0 for an unlimited dimension may damage dependent variables.
*/
-(BOOL)resizeDimensionWithName:(NSString *)resizeDimName size:(int)newSize;



//*****************************GLOBAL ATTRIBUTES***********************************

/*!
  @method createNewGlobalAttributeWithName:dataType:values:
  @abstract Creates a new global attribute.
  @param attName NSString name of the attribute.
 @param theType netcdf data type (i.e., NC_BYTE, NC_CHtheType.
  @param theValues A NSArray of values.  If the type is NC_CHAR, it should have only one string object.  Otherwise, it should contain 1 or more NSNumber objects
  @discussion Creates a new global variable.  If successful, the method resyncs the NCDFHandle to the file.
*/
-(BOOL)createNewGlobalAttributeWithName:(NSString *)attName dataType:(nc_type)theType values:(NSArray *)theValues;
/*!
  @method createNewGlobalAttributeWithPropertyList:
  @abstract Creates a new global attribute using a property list dictionary.
  @param propertyList NSDictionary containing an attribute description.  See NCDFAttribute for field names.
  @discussion Creates a new global variable.  If successful, the method resyncs the NCDFHandle to the file.

  Required Fields:
    NCDFAttributePropertyListFieldNC_TYPE
    NCDFAttributePropertyListFieldAttributeName
    NCDFAttributePropertyListFieldValues
*/

-(BOOL)createNewGlobalAttributeWithPropertyList:(NSDictionary *)propertyList;
/*!
  @method deleteGlobalAttributeWithName:
  @abstract Deletes a global attribute.
  @param attName NSString of a global attribute name.
  @discussion Deletes a global variable.  If successful, the method resyncs the NCDFHandle to the file.
*/
-(BOOL)deleteGlobalAttributeWithName:(NSString *)attName;

/*!
  @method createNewGlobalAttributeWithArray:
  @abstract Creates global attributes from a list of attributes.
  @param theNewAttributes NSArray of NCDFAttribute objects.
  @discussion Adds multiple global attributes to a file. It does not add attributes with the same name as existing attributes.  The returned array allows you to determine which attributes were not written.

*/
-(NSArray *)createNewGlobalAttributeWithArray:(NSArray *)theNewAttributes;


//*****************************VALIDATION OF TEXT***********************************

/*!
  @method parseNameString:
  @abstract Parses a new name string to ensure compliance with netcdf naming standards.
  @param theString NSString of the name string.
  @discussion Ensures that a name string is valid for writing to file.  This method is called whenever a new name is being written to file.  Also see NCDFNameFormatter for GUI-based formatting.
*/
-(NSString *)parseNameString:(NSString *)theString;


//*****************************VariablesT***********************************
/*!
  @method createNewVariableWithName:type:dimNameArray:
  @abstract Creates a new variable.
  @param variableName NSString of the name string.
  @param theType The netcdf data type (NC_BYTE,NC_CHAR, etc)
  @param selectedDims An array of NCDFDimensions in order of significance.
  @discussion Basic method for creating a new variable.  Resyncs to file on completion. Also posts NCDFError if error occurs.
*/
-(BOOL)createNewVariableWithName:(NSString *)variableName type:(nc_type)theType dimNameArray:(NSArray *)selectedDims;

/*!
  @method createNewVariableWithPropertyList:
  @abstract Creates a new variable based on a property list.
  @param propertyList NSDictionary containing a variable property list.  See NCDFVariable for fields.
  @discussion Creating a new variable with property list.  Resyncs to file on completion. Also posts NCDFError if error occurs.

  required fields:
        NCDFVariablePropertyListFieldDimensionNames
        NCDFVariablePropertyListFieldVariableName
*/
-(BOOL)createNewVariableWithPropertyList:(NSDictionary *)propertyList;
/*!
  @method deleteVariableWithName:
  @abstract Deletes a variable from the netcdf file.
  @param deleteVariableName NSString object with the name of the variable to be deleted.
  @discussion Deleteing a variable by name.  Resyncs to file on completion. Also posts NCDFError if error occurs.

*/
-(BOOL)deleteVariableWithName:(NSString *)deleteVariableName;

/*!
  @method deleteVariablesWithNames:
  @abstract Deletes a series of variables.
  @param nameArray NSArray object containing NSString objects containing variable names.
  @discussion Deleteing a variable by name.  Resyncs to file on completion. Also posts NCDFError if error occurs.  Method will return NO on any error.

*/
-(BOOL)deleteVariablesWithNames:(NSArray *)nameArray;

/*!
  @method retrieveVariableByName:
  @abstract Access a variable by name.
  @param aName NSString object containing a name of a variable.

  @discussion This method is to access an individual variable by name.

*/
-(NCDFVariable *)retrieveVariableByName:(NSString *)aName;

/*!
  @method retrieveDimensionByName:
  @abstract Access a dimension by name.
  @param aName NSString object containing a name of a dimension.
  @discussion This method is to access an individual dimension by name.
*/
-(NCDFDimension *)retrieveDimensionByName:(NSString *)aName;

/*!
  @method retrieveUnlimitedDimension
  @abstract Access the unlimited dimension, if exists.
  @discussion This method is to identify and access an unlimited dimension.
*/
-(NCDFDimension *)retrieveUnlimitedDimension;

/*!
  @method retrieveUnlimitedVariable
  @abstract Access the unlimited dimension variable, if exists.
  @discussion This method is to identify and access an unlimited dimension variable.

*/
-(NCDFVariable *)retrieveUnlimitedVariable;

/*!
  @method retrieveDimensionByIndex:
  @abstract Access to a dimension by index number.
  @discussion The netcdf C library handles variable dimensions by index number.  The netcdf library number and the NCDFHandle index number should be the same and are interchangable.  Thus, NCDFDimensions can be retrieved by their index numbers.

*/
-(NCDFDimension *)retrieveDimensionByIndex:(int)index;

/*!
  @method extendUnlimitedVariableBy:
  @abstract Extend the length of the unlimited dimension via the dimension variable.
  @param units The numbers of values to extend the unlimited dimension length.
  @discussion This function provides a simple method to make all variables that are dependent on a unlimited dimension longer.  By adding to this length, all variables that use the unlimited variable with increase in size automatically.

*/
-(BOOL)extendUnlimitedVariableBy:(int)units;
	/*!
    @method htmlDescription
    @abstract Returns a description of the variable and all of its attributes in an html form.
    @discussion  This method is to provide a method to export the metadata of a netcdf file into a HTML document.
	*/

-(NSString *)htmlDescription;

	/*!
	 @method retrieveGlobalAttributeByName:
	 @abstract Allows access to global attributes by name.
     @param aName NSString object containing the desired name of the global attribute desired.
	 @discussion Retrieves NCDFAttribute object that global to the netcdf file  by attribute name.
	 */
-(NCDFAttribute *)retrieveGlobalAttributeByName:(NSString *)aName;
	/*!
    @method compareUnlimitedValue:
     @aaNameact Compares 2 NCDFHandle objects based on their initial unlimited dimension value.
	 @param object NCDFHandle


	 @discussion Compares the initial unlimited dimension value of "object" against the reciever.  This method is for sorting the order of NCDFHandles based on the unlimited dimension variable.  Only checks the first value.
	 */
-(NSComparisonResult)compareUnlimitedValue:(id)object;

	/*!
     @method compareValue
	 @abstract Returns the initial unlimited dimension variable's first value as an NSNUmber object.
	 @discussion Returns the initial unlimited dimension variable's first value as an NSNUmber object.  This method is for sorting the order of NCDFHandles based on the unlimited dimension variable.
	 */
-(NSNumber *)compareValue;
	/*!
     @method createCompareValue
	 @abstract Private method for creating the comparison value.
	 @discussion Private method for creating the comparison value.  The value represents the first step along the unlimited dimension.  If no unlimited dimension exists, it will create a NAN NSNumber object.
	 */
-(void)createCompareValue;
-(int)ncidForReadOnly;
-(void)closeNCID:(int)ncid;
-(int)ncidWithOpenMode:(int)openMode status:(int32_t *)status;
@end
