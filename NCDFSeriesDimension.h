//
//  NCDFSeriesDimension.h
//  netcdf
//
//  Created by Tom Moore on 6/16/07.
//  Copyright 2007 PaleoTerra. All rights reserved.
//
/*!
@header
 @class NCDFSeriesDimension
 @abstract NCDFSeriesDimension objects for defining dimensionality of data variables. 
 @discussion NCDFSeriesDimension is an immutable class designed to allow a programmer to access netcdf data over multiple files using standard notation.  This class allows for dimensions to span files.
 */
#import <Cocoa/Cocoa.h>

@class NCDFDimension;
@interface NCDFSeriesDimension : NSObject {
    NSString *_dimName;
    size_t _length;
    NSMutableArray *_unlimitedLengthArray;
	BOOL _isUnlimited;
}

/*! 
@method -(id)initWithDimension:(NCDFDimension *)aDim
@abstract Initializing using a NCDFDimension exisiting in the root NCDFHandle.
@param aDim NCDFDimension object.  Typically the root NCDFHandle from NCDFSeriesHandle.
@discussion Initializes a new NCDFSeriesDimension.  This initialization method is NOT for unlimited variables - limited variables only.  This initializer will not span files.
*/
-(id)initWithDimension:(NCDFDimension *)aDim;

	/*! 
	@method -(id)initWithUnlimitedDimension:(NCDFDimension *)aDim withHandleArray:(NSArray *)theHandles
	@abstract Initializing using a NCDFDimension exisiting in the root NCDFHandle.
	@param aDim NCDFDimension object.  Typically the root NCDFHandle from NCDFSeriesHandle.
	@param theHandles An NSArray of NCDFHandles owned by the NCDFSeriesHandle object.  
	@discussion Initializes a new NCDFSeriesDimension.  This method is only for unlimited dimensions. The dimension information will be adjusted to span multiple files.
	*/
-(id)initWithUnlimitedDimension:(NCDFDimension *)aDim withHandleArray:(NSArray *)theHandles;


	/*! 
	@method -(id)initWithDimension:(NCDFDimension *)aDim withHandleArray:(NSArray *)theHandles
	@abstract Initializing using a NCDFDimension exisiting in the root NCDFHandle.
	@param aDim NCDFDimension object.  Typically the root NCDFHandle from NCDFSeriesHandle.
	@param theHandles An NSArray of NCDFHandles owned by the NCDFSeriesHandle object.  
	@discussion Initializes a new NCDFSeriesDimension.  This method is for use when it is unknown whether the dimension is unlimited or limited.  If unlimited, the dimension information will be adjusted to span multiple files.
	*/
-(id)initWithDimension:(NCDFDimension *)aDim withHandleArray:(NSArray *)theHandles;

	/*! 
	@method -(NSString *)dimensionName
	@abstract Returns the receiver's dimension name.

	*/
-(NSString *)dimensionName;

	/*! 
	@method -(size_t)dimLength
	@abstract Returns the receiver's dimension length.
	@discussion Returns the length of the dimension.  If the dimension is unlimited, the length will span all files.
	*/
-(size_t)dimLength;

	/*! 
	@method -(BOOL)isUnlimited
	@abstract Returns a boolean whether the dimension is unlimited.
	
	*/
-(BOOL)isUnlimited;

	/*! 
	@method -(NSArray *)rangeArrayForStart:(int)start andLength:(int)length
	@abstract Returns an array with NSRange objects for unlimited dimensions describing the start and length information for each file.
	@param start start location - can be 0 to n-1
	@param length edge length  - can be 1 to n 
	@discussion Returns an array with NSRange objects describing a selection for each file for later reading. This method is for unlimited dimensions only.
	*/
-(NSArray *)rangeArrayForStart:(int)start andLength:(int)length;

	/*! 
	@method -(NSArray *)rangeArrayForRange:(NSRange)aRange
	@abstract Returns an array with NSRange objects for unlimited dimensions describing the start and length information for each file.
	@param aRange uses a NSRange object instead of two int values in -(NSArray *)rangeArrayForStart:(int)start andLength:(int)length
	@discussion Returns an array with NSRange objects describing a selection for each file for later reading. This method is for unlimited dimensions only.
	*/
-(NSArray *)rangeArrayForRange:(NSRange)aRange;

@end
