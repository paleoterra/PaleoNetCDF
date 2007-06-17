//
//  NCDFSlab.h
//  netcdf
//
//  Created by Tom Moore on 6/11/07.
//  Copyright 2007 PaleoTerra. All rights reserved.
//

/*!
@header
 @class NCDFSlab
 @abstract NCDFSlab is a class for storage of netcdf data in memory and accessable via standard dimentional notation.
 @discussion NCDFSlab is an immutable class designed for storage of netcdf data in memory.  This class is for the convenience of accessing in-memory netcdf data, which is particularly useful for threaded applications or other applications that would otherwise repeatedly access the file on disk.  
 */

#import <Cocoa/Cocoa.h>
#import "netcdf.h"

@interface NCDFSlab : NSObject {
	nc_type theType;
	size_t *dimensionLengths;
	int dimCount;
	NSData *theData;
}

/*! 
@method -(id)initSlabWithData:(NSData *)data withType:(nc_type)type withLengths:(NSArray *)lengths
@abstract Initialize a new NCDFSlab using a NSData object and NCDFVariable information.
@param data NSData object obtained through NCDFVariable or NCDFSeriesVariable object.
@param type nc_type of the data.  NC_BYTE,NC_CHAR,NC_SHORT, etc.
@param lengths Lengths along each dimension in significance order.  
@discussion Initializes a new NCDFSlab object.  The lengths describe the shape of the data and the netcdf data type of the data.
*/
-(id)initSlabWithData:(NSData *)data withType:(nc_type)type withLengths:(NSArray *)lengths;


	/*! 
@method -(void)setNCType:(nc_type)type
	@abstract Private method to set the nc_type of the data.
	@param type nc_type of the data.  NC_BYTE,NC_CHAR,NC_SHORT, etc.
	@discussion Sets the nc_type of the data. Should not be called outside of NCDFSlab.
	*/
-(void)setNCType:(nc_type)type;

	/*! 
@method -(nc_type)type
	@abstract Returns the nc_type of the receiver.
	@discussion Returns  nc_type of the data.  NC_BYTE,NC_CHAR,NC_SHORT, etc.
	*/
-(nc_type)type;

	/*! 
	@method -(void)setData:(NSData *)data
	@abstract Private method to set the data.
	@param data NSData object representing the data.
	@discussion Sets the  data. Should not be called outside of NCDFSlab.
	*/
-(void)setData:(NSData *)data;

	/*! 
	@method -(NSData *)data
	@abstract Returns all of the receiver's data
	@discussion Returns the entire data slab stored in the receiver.
	*/
-(NSData *)data;

	/*! 
	@method -(NSData *)subSlabStart:(NSArray *)startPositions lengths:(NSArray *)lengths
	@abstract Returns a subset of the slab's data using standard netcdf notation.
	@param startPositions Start locations for each dimension in significance order.
	@param lengths Edge lengths desired along each dimension in significance order.
	@discussion Returns a subset of data stored in the slab.  All starts and lengths should be relative to the slab, and not the original variable.
	*/
-(NSData *)subSlabStart:(NSArray *)startPositions lengths:(NSArray *)lengths;

	/*! 
	@method -(NSArray *)dimensionLengths
	@abstract Returns the lengths of each dimension in steps in significance order
	@discussion The returned array describes the shape, in length, of the data object.  Use this array to choose subsets of the slab.
	*/
-(NSArray *)dimensionLengths;

	/*! 
	@method -(void)setDimensionLengths:(NSArray *)theLengths
	@abstract Sets the dimension lengths, in steps, for each dimension in significance order.
	@discussion THis method is private and should be be accessed outside of NCDFSlab
	*/
-(void)setDimensionLengths:(NSArray *)theLengths;


	/*! 
	@method -(int)startPositionForNextStepFrom:(NSMutableArray *)current fromStart:(NSArray *)startCoords withLengths:(NSArray *)lengths
	@abstract Private method for determining a position within a NSData object.
	*/
-(int)startPositionForNextStepFrom:(NSMutableArray *)current fromStart:(NSArray *)startCoords withLengths:(NSArray *)lengths;

	/*! 
	@method -(int)positionFromCoordinates:(NSArray *)coordinates
	@abstract Private method for determining a position within a NSData object.
	*/
-(int)positionFromCoordinates:(NSArray *)coordinates;
@end
