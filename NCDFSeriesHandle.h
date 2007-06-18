//
//  NCDFSeriesHandle.h
//  netcdf
//
//  Created by Tom Moore on 6/15/07.
//  Copyright 2007 PaleoTerra. All rights reserved.
//

/*!
@header
 @class NCDFSeriesHandle
 @abstract Handle for accessing multiple netcdf files that are sequential along the unlimited dimension. 
 @discussion NCDFSeriesHandle provides an interface for using multiple netcdf files.  If all the files have the same dimensions, data types, and represent a continuous sequence of data, this class provides an overall simple way to access the files without directly working with each.  Also, you may store this class to disk.  
 */

#import <Cocoa/Cocoa.h>

@class NCDFHandle,NCDFSeriesDimension,NCDFSeriesVariable;

/*!
@header
 @class NCDFSeriesHandle
 @abstract Handle for accessing multiple netcdf files that are sequential along the unlimited dimension. 
 @discussion NCDFSeriesHandle provides an interface for using multiple netcdf files.  If all the files have the same dimensions, data types, and represent a continuous sequence of data, this class provides an overall simple way to access the files without directly working with each.  Also, you may store this class to disk.  
 */
@interface NCDFSeriesHandle : NSObject {
	NSArray *_theURLS;
	NSArray *_theHandles;
	BOOL _isSingleDirectory;
	NSArray *_theDimensions;
	NSArray *_theVariables;
}


/*! 
@method initWithSeriesFileAtPath:
@abstract Initialize a new NCDFSeriesHandle using stored information on disk.
@param path NSString object containing the path to the NCDFSeriesHandle file
@discussion Initializes a new NCDFSeriesHandle object with a file list stored on disk.
*/
-(id)initWithSeriesFileAtPath:(NSString *)path;

/*! 
@method initWithSeriesFileAtURL:
@abstract Initialize a new NCDFSeriesHandle using stored information on disk.
@param url NSURL object containing the url to the NCDFSeriesHandle file
@discussion Initializes a new NCDFSeriesHandle object with a file list stored on disk.
*/
-(id)initWithSeriesFileAtURL:(NSURL *)url;

/*! 
@method initWithOrderedPathSeries:
@abstract Initialize a new NCDFSeriesHandle using an NSArray of netcdf file paths.
@param paths NSArray object containing paths to netcdf files.
@discussion Initializes a new NCDFSeriesHandle object using an NSArray of file paths.  The array must be ordered correctly since this initialization method does not attempt to correct the order based on the unlimited dimension data. 
*/
-(id)initWithOrderedPathSeries:(NSArray *)paths;

/*! 
@method initWithOrderedURLSeries:
@abstract Initialize a new NCDFSeriesHandle using an NSArray of netcdf urls.
@param paths NSArray object containing urls to netcdf files.
@discussion Initializes a new NCDFSeriesHandle object using an NSArray of urls.  The array must be ordered correctly since this initialization method does not attempt to correct the order based on the unlimited dimension data. Note that urls should be file urls.
*/
-(id)initWithOrderedURLSeries:(NSArray *)urls;

//-(id)initWithUnorderedPathSeries:(NSArray *)paths;
//-(id)initWithUnorderedURLSeries:(NSArray *)urls;

/*! 
@method writeSeriesToFile:
@abstract Write file list to path.
@param path File path.
@discussion Saves a the list of files used in the object to disk as a property list file at path.  
*/
-(BOOL)writeSeriesToFile:(NSString *)path;
/*! 
@method writeSeriesToURL:
@abstract Write file list to path.
@param url File url.
@discussion Saves a the list of files used in the object to disk as a property list file at url.  
*/
-(BOOL)writeSeriesToURL:(NSURL *)url;

/*! 
@method seedArray
@abstract Private method 
*/
-(void)seedArrays;
/*! 
@method seedDimensions
@abstract Private method 
*/
-(void)seedDimensions;
/*! 
@method seedVariables
@abstract Private method 
*/
-(void)seedVariables;

/*! 
@method urls
@abstract Obtain a list of all the netcdf used by the object.
@discussion Provides a list of netcdf file URLs in an NSArray. 
*/
-(NSArray *)urls;
/*! 
@method handles
@abstract Obtain NCDFHandle objects for all the netcdf files owned by the object.
@discussion This method allows the direct access of NCDFHandle files used by the object. 
*/
-(NSArray *)handles;

//accessing handles 


/*! 
@method handleCount
@abstract Provides the count of netcdf owned by the receiver.
@discussion Returns the count of netcdf files owned by the receiver. 
*/
-(int)handleCount;
/*! 
@method handleAtIndex:
@abstract Provides a NCDFHandle object at index.
@discussion Returns the NCDFHandle at index owned by the receiver.
*/
-(NCDFHandle *)handleAtIndex:(int)index;
/*! 
@method rootHandle
@abstract Provides the root NCDFHandle object
@discussion The root handle is an NCDFHandle object that provides static data that are not directly related to the unlimited dimension.  Global attributes are an example.  The root handle is typically the first handle in the receiver.
*/
-(NCDFHandle *)rootHandle;

//accessing roothandle info

/*! 
@method getRootGlobalAttributes
@abstract Provides the global attributes from the root handle.
@discussion The method provides the global attributes for the root handle.  Global attributes can vary from file to file, but obtaining those attributes must be done through NCDFHandle objects.
*/
-(NSArray *)getRootGlobalAttributes;

/*! 
@method getRootVariables
@abstract Provides the variables of the root object.
@discussion The method provides the variables as an NSArray of NCDFVariables for the root handle.  This method is for accessing any variable from the root object.
*/
-(NSArray *)getRootVariables;

/*! 
@method getRootNonUnlimitedVariables
@abstract Provides the variables of the root object that are not unlimited.
@discussion The method provides the variables as an NSArray of non-unlimited NCDFVariables for the root handle.  
*/
-(NSArray *)getRootNonUnlimitedVariables;

/*! 
@method getRootDimensions
@abstract Provides the dimensions of the root object.
@discussion The method provides the variables as an NSArray of NCDFDimension for the root handle.  
*/
-(NSArray *)getRootDimensions;
	

/*! 
@method retrieveRootGlobalAttributeByName:
@abstract Retrieves a root handle global attribute by name.
@discussion The method provides the NCDFAttribute of a global variable by name. Result wil be nil if attribute is not found. 
*/
-(NCDFAttribute *)retrieveRootGlobalAttributeByName:(NSString *)aName;

//accessing series info

/*! 
@method getDimensions
@abstract Retrieves the dimensions of the receiver.
@discussion The method provides an NSArray of NCDFSeriesDimension objects for all the known dimensions. Known dimensions only include those found in the root NCDFHandle object.
*/
-(NSArray *)getDimensions;

/*! 
@method getVariables
@abstract Retrieves the variables of the receiver.
@discussion The method provides an NSArray of NCDFSeriesVariable objects for all variables connected with the unlimited dimensions. All other variables are ignored.
*/
-(NSArray *)getVariables;

/*! 
@method retrieveVariableByName:
@abstract Retrieves a variable from the receiver by name.
@param aName Name of the variable
@discussion The method provides a NCDFSeriesVariable object for a variable with the name aName.  Nil if not found.
*/
-(NCDFSeriesVariable *)retrieveVariableByName:(NSString *)aName;

/*! 
@method retrieveDimensionByName:
@abstract Retrieves a NCDFSeriesDimension from the receiver by name.
@param aName Name of the dimension
@discussion The method provides a NCDFSeriesDimension object for a variable with the name aName.  Nil if not found.
*/
-(NCDFSeriesDimension *)retrieveDimensionByName:(NSString *)aName;
/*! 
@method retrieveUnlimitedDimension
@abstract Retrieves a unlimited NCDFSeriesDimension from the receiver .
@discussion The method provides the unlimited NCDFSeriesDimension object.  Nil if not found.
*/
-(NCDFSeriesDimension *)retrieveUnlimitedDimension;


//-(NCDFVariable *)retrieveUnlimitedVariable;
@end
