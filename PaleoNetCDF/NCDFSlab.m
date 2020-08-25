//
//  NCDFSlab.m
//  netcdf
//
//  Created by Tom Moore on 6/11/07.
//  Copyright 2007 PaleoTerra. All rights reserved.
//

#import "NCDFSlab.h"


@implementation NCDFSlab

-(id)initSlabWithData:(NSData *)data withType:(nc_type)type withLengths:(NSArray *)lengths
{
	self = [super init];
	if(self) {
		[self setData:data];
		NSLog(@"data length %ld",[data length]);
		[self setNCType:type];
		[self setDimensionLengths:lengths];
	}
	return self;
}

-(void)dealloc
{
    free(dimensionLengths);
    theData = nil;
}


-(void)setNCType:(nc_type)type
{
	theType = type;
}

-(nc_type)type
{
	return theType;
}

-(void)setData:(NSData *)data
{
	if(theData)
	{
		theData = nil;
	}
	theData = [data copy];
}
-(NSData *)data
{
	return theData;
}

-(NSData *)subSlabStart:(NSArray *)startPositions lengths:(NSArray *)lengths
{
    NSAssert(([startPositions count] == dimCount), ([NSString stringWithFormat:@"Incorrect startPositions dimensions count: %li instead of %i",[startPositions count],dimCount]));
	NSAssert(([lengths count] == dimCount), ([NSString stringWithFormat:@"Incorrect lengths dimensions count: %li instead of %i",[lengths count],dimCount]));
	int32_t i, temp;
	for(i=0;i<dimCount;i++)
	{
		temp = [[startPositions objectAtIndex:i] intValue];
		NSAssert(( temp < dimensionLengths[i]), ([NSString stringWithFormat:@"startPositions out of range: dim %i, %i of %zi",i,temp,dimensionLengths[i]]));
		NSAssert(( [[lengths objectAtIndex:i] intValue] > 0), ([NSString stringWithFormat:@"length for dim %i, is zero",i]));
		temp = temp + [[lengths objectAtIndex:i] intValue] ;//problem line
		NSAssert(( temp <= dimensionLengths[i]), ([NSString stringWithFormat:@"lengths out of range: dim %i, max value %i of %zi",i,temp,dimensionLengths[i]]));
	}
    int32_t steps = 1;
	if(dimCount != 1)
	{
		for (i=(dimCount - 2);i>-1;i--) //note that we don't count the most significant dim because we'll read all those data at once
		{
			steps *= [[lengths objectAtIndex:i] intValue];
		}
	}

	NSRange readRange;
	readRange.length = sizeof(theType) * [[lengths lastObject] intValue];
	NSMutableData *theMutData = [[NSMutableData alloc] init];
	NSMutableArray *current = [[NSMutableArray alloc] init];
	[current addObjectsFromArray:startPositions];
	for(i=0;i<steps;i++)
	{
		readRange.location = [self startPositionForNextStepFrom:current fromStart:startPositions withLengths:lengths] * sizeof(theType);
		[theMutData appendData:[theData subdataWithRange:readRange]];
	}
	return [NSData dataWithData:theMutData];
}

-(NSArray *)dimensionLengths
{
	NSMutableArray *theArray = [[NSMutableArray alloc] init];
	int32_t i;
	for(i=0;i<dimCount;i++)
	{
		[theArray addObject:[NSNumber numberWithInt:(int)dimensionLengths[i]]];
	}
	return [NSArray arrayWithArray:theArray];
}

-(void)setDimensionLengths:(NSArray *)theLengths
{
	dimensionLengths = (size_t *)malloc(sizeof(size_t)*[theLengths count]);
	int32_t i;
	dimCount = (int)[theLengths count];
	for(i=0;i<dimCount;i++)
	{
		dimensionLengths[i] = (size_t)[[theLengths objectAtIndex:i] intValue];
	}
}

-(int)startPositionForNextStepFrom:(NSMutableArray *)current fromStart:(NSArray *)startCoords withLengths:(NSArray *)lengths
{
	int32_t count = (int)[current count];
	NSMutableArray *theArray = [[NSMutableArray alloc] init];
	int32_t i;
	int32_t newPoint,  startPosition ;
	int32_t carryover;
	startPosition = [self positionFromCoordinates:current];//we get value first and then increment by one
	//NSLog(@"start");
	//NSLog([current description]);
	carryover = 1;
	for(i=(count-2);i>-1;i--)
	{
		newPoint = [[current objectAtIndex:i] intValue] + carryover;
		if(newPoint == ([[startCoords objectAtIndex:i] intValue] + [[lengths objectAtIndex:i] intValue] ))
		{
			newPoint = [[startCoords objectAtIndex:i] intValue];//reset dim
			carryover = 1;
		}
		else
			carryover = 0;
		[theArray insertObject:[NSNumber numberWithInt:newPoint] atIndex:0];
	}
	[theArray addObject:[startCoords lastObject]];
	[current removeAllObjects];
	[current addObjectsFromArray:theArray];
	return startPosition;
}

-(int)positionFromCoordinates:(NSArray *)coordinates
{
	int32_t i,j;
	int32_t temp = 0;
	int32_t startPosition = 0;
	for(i=0;i<[coordinates count];i++)
	{
		temp = [[coordinates objectAtIndex:i] intValue];
		for(j=i+1;j<[coordinates count];j++)
		{
			temp *= dimensionLengths[j];
		}
		startPosition += temp;
	}
	return startPosition;
}
@end
