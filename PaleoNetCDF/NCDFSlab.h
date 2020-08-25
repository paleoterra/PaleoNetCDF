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
#import <netcdf.h>

@interface NCDFSlab : NSObject {
	nc_type theType;
	size_t *dimensionLengths;
	int32_t dimCount;
	NSData *theData;
}

/*!
@method initSlabWithData:withType:withLengths:
@abstract Initialize a new NCDFSlab using a NSData object and NCDFVariable information.
@param data NSData object obtained through NCDFVariable or NCDFSeriesVariable object.
@param type nc_type of the data.  NC_BYTE,NC_CHAR,NC_SHORT, etc.
@param lengths Lengths along each dimension in significance order.
@discussion Initializes a new NCDFSlab object.  The lengths describe the shape of the data and the netcdf data type of the data.
*/
-(id)initSlabWithData:(NSData *)data withType:(nc_type)type withLengths:(NSArray *)lengths;

	/*!
@method type
	@abstract Returns the nc_type of the receiver.
	@discussion Returns  nc_type of the data.  NC_BYTE,NC_CHAR,NC_SHORT, etc.
	*/
-(nc_type)type;
	/*!
	@method data
	@abstract Returns all of the receiver's data
	@discussion Returns the entire data slab stored in the receiver.
	*/
-(NSData *)data;

	/*!
	@method subSlabStart:lengths:
	@abstract Returns a subset of the slab's data using standard netcdf notation.
	@param startPositions Start locations for each dimension in significance order.
	@param lengths Edge lengths desired along each dimension in significance order.
	@discussion Returns a subset of data stored in the slab.  All starts and lengths should be relative to the slab, and not the original variable.
	*/
-(NSData *)subSlabStart:(NSArray *)startPositions lengths:(NSArray *)lengths;

	/*!
	@method dimensionLengths
	@abstract Returns the lengths of each dimension in steps in significance order
	@discussion The returned array describes the shape, in length, of the data object.  Use this array to choose subsets of the slab.
	*/
-(NSArray *)dimensionLengths;
@end
