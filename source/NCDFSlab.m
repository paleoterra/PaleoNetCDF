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
		NSLog(@"data length %i",[data length]);
		[self setNCType:type];
		[self setDimensionLengths:lengths];
	}
	return self;
}

-(void)dealloc
{
	//NSLog(@"deallocing slab");
	free(dimensionLengths);
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
	//I'll use a lot of error checking with asserts here.  Make sure that I don't have any overruns.
	NSAssert(([startPositions count] == dimCount), ([NSString stringWithFormat:@"Incorrect startPositions dimensions count: %i instead of %i",[startPositions count],dimCount]));
	NSAssert(([lengths count] == dimCount), ([NSString stringWithFormat:@"Incorrect lengths dimensions count: %i instead of %i",[lengths count],dimCount]));
	int i, temp;
	for(i=0;i<dimCount;i++)
	{
		temp = [[startPositions objectAtIndex:i] intValue];
		NSAssert(( temp < dimensionLengths[i]), ([NSString stringWithFormat:@"startPositions out of range: dim %i, %i of %i",i,temp,dimensionLengths[i]]));
		NSAssert(( [[lengths objectAtIndex:i] intValue] > 0), ([NSString stringWithFormat:@"length for dim %i, is zero",i]));
		temp = temp + [[lengths objectAtIndex:i] intValue] ;//problem line
		NSAssert(( temp <= dimensionLengths[i]), ([NSString stringWithFormat:@"lengths out of range: dim %i, max value %i of %i",i,temp,dimensionLengths[i]]));
	}
	//assertion checks should be done at this point.  If we got to here we have ensured that:
	//	1. start values are all within the range of the data set
	//	2. that start values coupled with lengths are within the range for each dimension
	
	//determin total number of steps for reading.
	int steps = 1;
	// if dim count = 1, then 1 step;
	if(dimCount != 1)
	{
		for (i=(dimCount - 2);i>-1;i--) //note that we don't count the most significant dim because we'll read all those data at once
		{
			steps *= [[lengths objectAtIndex:i] intValue];
		}
	}
	
	//now we know the total count of steps;
	NSRange readRange;
	
	readRange.length = sizeof(theType) * [[lengths lastObject] intValue];
	
	NSMutableData *theMutData = [[NSMutableData alloc] init];
	NSMutableArray *current = [[NSMutableArray alloc] init];
	[current addObjectsFromArray:startPositions];
	//NSLog(@"current before sending");
	//NSLog([current description]);
	for(i=0;i<steps;i++)
	{
		//he we need to cycle through each step, and calculate the beginning of the data read and then read the data into the mutable data object.
		
		readRange.location = [self startPositionForNextStepFrom:current fromStart:startPositions withLengths:lengths] * sizeof(theType);
		//NSLog(@"size: %i, range %@",sizeof(theType),NSStringFromRange(readRange));
		[theMutData appendData:[theData subdataWithRange:readRange]];
		
	}
	return [NSData dataWithData:theMutData];
}

-(NSArray *)dimensionLengths
{
	NSMutableArray *theArray = [[NSMutableArray alloc] init];
	int i;
	for(i=0;i<dimCount;i++)
	{
		[theArray addObject:[NSNumber numberWithInt:dimensionLengths[i]]];
	}
	return [NSArray arrayWithArray:theArray];
}

-(void)setDimensionLengths:(NSArray *)theLengths
{
	dimensionLengths = (size_t *)malloc(sizeof(size_t)*[theLengths count]);
	int i;
	dimCount = [theLengths count];
	for(i=0;i<dimCount;i++)
	{
		dimensionLengths[i] = (size_t)[[theLengths objectAtIndex:i] intValue];
	}
}

-(int)startPositionForNextStepFrom:(NSMutableArray *)current fromStart:(NSArray *)startCoords withLengths:(NSArray *)lengths
{
	int count = [current count];
	NSMutableArray *theArray = [[NSMutableArray alloc] init];
	int i;
	int newPoint,  startPosition ;
	int carryover;
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
	//now we have all the new start positions
	//time to get the start position in terms of value count
	//NSLog(@"end");
	//NSLog([current description]);
	
	return startPosition;
}

-(int)positionFromCoordinates:(NSArray *)coordinates
{
	int i,j;
	int temp = 0;
	int startPosition = 0;
	for(i=0;i<[coordinates count];i++)
	{
		
		temp = [[coordinates objectAtIndex:i] intValue];
		for(j=i+1;j<[coordinates count];j++)
		{
			temp *= dimensionLengths[j];
		}
		startPosition += temp;
		//NSLog(@"temp %i: %i",i,temp);
	}
	//NSLog(@"start Position: %i", startPosition);
	return startPosition;
}
@end
