//
//  NCDFSlab.h
//  netcdf
//
//  Created by Tom Moore on 6/11/07.
//  Copyright 2007 PaleoTerra. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "netcdf.h"

@interface NCDFSlab : NSObject {
	nc_type theType;
	size_t *dimensionLengths;
	int dimCount;
	NSData *theData;
}

-(id)initSlabWithData:(NSData *)data withType:(nc_type)type withLengths:(NSArray *)lengths;

-(void)setNCType:(nc_type)type;
-(nc_type)type;

-(void)setData:(NSData *)data;
-(NSData *)data;
-(NSData *)subSlabStart:(NSArray *)startPositions lengths:(NSArray *)lengths;

-(NSArray *)dimensionLengths;
-(void)setDimensionLengths:(NSArray *)theLengths;

-(int)startPositionForNextStepFrom:(NSMutableArray *)current fromStart:(NSArray *)startCoords withLengths:(NSArray *)lengths;
-(int)positionFromCoordinates:(NSArray *)coordinates;
@end
