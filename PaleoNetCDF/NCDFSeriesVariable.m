//
//  NCDFSeriesVariable.m
//  netcdf
//
//  Created by Tom Moore on 6/16/07.
//  Copyright 2007 PaleoTerra. All rights reserved.
//

#import "NCDFNetCDF.h"


@implementation NCDFSeriesVariable


-(id)initWithVariable:(NCDFVariable *)aVar fromHandle:(NCDFSeriesHandle *)aHandle
{
	self = [super init];
	if(self)
	{
		int32_t i = 0;
		_variableName = [aVar variableName];
		_dataType = [aVar variableNC_TYPE];


		_typeName = [aVar variableType] ;
		_seriesHandle = aHandle;
		NSEnumerator *temp = [[aVar dimensionNames] objectEnumerator];
		NSString *tempString;
		NSMutableArray *tempDims = [[NSMutableArray alloc] init];
		while(tempString=[temp nextObject])
		{
			[tempDims addObject:[aHandle retrieveDimensionByName:tempString]];
			if([[aHandle retrieveDimensionByName:tempString] isUnlimited])
				_unlimitedDimLocation = i;
			i++;
		}
		_theDims = [NSArray arrayWithArray:tempDims];
	}
	return self;
}

//reading
-(NSData *)readAllVariableData
{
	NSEnumerator *anEnum = [[_seriesHandle handles] objectEnumerator];
	NCDFHandle *aHandle;
	NSMutableData *theData = [[NSMutableData alloc] init];



	while(aHandle = [anEnum nextObject])
	{



		[theData appendData:[[aHandle retrieveVariableByName:_variableName] readAllVariableData]];
	}



	return [NSData dataWithData:theData];
}

-(NSString *)variableName
{
	return _variableName;
}

-(NSString *)variableType
{
	return _typeName;
}

-(nc_type)variableNC_TYPE
{
	return _dataType;
}

-(NSString *)variableDimDescription
{
	int32_t i;
    NSString *theString = @"[";



    for(i=0;i<[_theDims count];i++)
    {
        theString = [theString stringByAppendingString:[[_theDims objectAtIndex:i] dimensionName]];
        if(i+1<[_theDims count])
            theString = [theString stringByAppendingString:@","];
    }
    theString = [theString stringByAppendingString:@"]"];
    return theString;
}


-(NSString *)dataTypeWithDimDescription
{
    NSString *aString;
    aString = [NSString stringWithFormat:@"%@ %@",[self variableType],[self variableDimDescription]];
    return aString;
}

-(NSArray *)getVariableAttributes
{
	return [[[_seriesHandle rootHandle] retrieveVariableByName:_variableName]getVariableAttributes];
}

-(id)getSingleValue:(NSArray *)coordinates
{
	NSNumber *unlim = [coordinates objectAtIndex:_unlimitedDimLocation];
	NSRange aRange;
	aRange.location = [unlim intValue];
	aRange.length = 1;
	NSArray *theResultRanges = [[_theDims objectAtIndex:_unlimitedDimLocation] rangeArrayForRange:aRange];
	int32_t i,fileid = 0;
	for(i=0;i<[theResultRanges count];i++)
	{
		aRange = [[theResultRanges objectAtIndex:i] rangeValue];
		if(aRange.length >0)
		{
			fileid = i;
			break;
		}
	}
	//so I is the file, and range is the position.




	//create new coordinates
	NSMutableArray  *newCoor = [[NSMutableArray alloc] init];
	for(i=0;i<[coordinates count];i++)
	{
		if(i==_unlimitedDimLocation)
			[newCoor addObject:[NSNumber numberWithInt:[[theResultRanges objectAtIndex:fileid] rangeValue].location]];
		else
			[newCoor addObject:[coordinates objectAtIndex:i]];
	}
	return [[[[_seriesHandle handles] objectAtIndex:fileid] retrieveVariableByName:_variableName] getSingleValue:newCoor];
}

-(NSData *)getValueArrayAtLocation:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths
{
	NSRange unlimRange;
	unlimRange.location = [[startCoordinates objectAtIndex:_unlimitedDimLocation] intValue];
	unlimRange.length = [[edgeLengths objectAtIndex:_unlimitedDimLocation] intValue];
	NSArray *theResultRanges = [[_theDims objectAtIndex:_unlimitedDimLocation] rangeArrayForRange:unlimRange];
	NSMutableData *theData = [[NSMutableData alloc] init];
	int32_t i,j;
	for(i=0;i<[theResultRanges count];i++)
	{
		@autoreleasepool {
			NSRange aRange = [[theResultRanges objectAtIndex:i] rangeValue];
			if(aRange.length > 0)
			{
				NSMutableArray *newStartArray = [[NSMutableArray alloc] init];
				NSMutableArray *newLengthArray = [[NSMutableArray alloc] init];
				for(j=0;j<[startCoordinates count];j++)
				{
					if(j==_unlimitedDimLocation)
					{
						[newStartArray addObject:[NSNumber numberWithInt:[[theResultRanges objectAtIndex:i] rangeValue].location]];
						[newLengthArray addObject:[NSNumber numberWithInt:[[theResultRanges objectAtIndex:i] rangeValue].length]];
					}
					else
					{
						[newStartArray addObject:[startCoordinates objectAtIndex:j]];
						[newLengthArray addObject:[edgeLengths objectAtIndex:j]];
					}
				}
				//now we have the new coordinate array for file.  Load data.
				[theData appendData:[[[[_seriesHandle handles] objectAtIndex:i] retrieveVariableByName:_variableName] getValueArrayAtLocation:newStartArray edgeLengths:newLengthArray]];
			}










		}
	}
	return  theData;
}

-(BOOL)isDimensionVariable
{
	return [[[_seriesHandle rootHandle] retrieveVariableByName:_variableName] isDimensionVariable];
}

-(int)sizeUnitVariable
{



    int32_t i;
    int32_t theSize,aLength;







    theSize = 1;
    for(i=0;i<[_theDims count];i++)
    {
        aLength = [[_theDims objectAtIndex:i] dimLength];
        if(![[_theDims objectAtIndex:i] isUnlimited])
            theSize *= aLength;
    }
    return theSize;
}

-(int)sizeUnitVariableForType
{
	int32_t size;



	size = [self sizeUnitVariable];
	switch(_dataType)
	{
        case NC_BYTE:
            break;
        case NC_CHAR:
            break;
        case NC_SHORT:
            size = size *2 ;
            break;
        case NC_INT:
            size = size *4 ;
            break;
        case NC_FLOAT:
            size = size *4 ;
            break;
        case NC_DOUBLE:
            size = size *8 ;
            break;
        default:
            break;
	}
	return size;
}

-(int)currentVariableSize
{
	int32_t i;
    int32_t theSize,aLength;







    theSize = 1;
    for(i=0;i<[_theDims count];i++)
    {
        aLength = [[_theDims objectAtIndex:i] dimLength];
        theSize *= aLength;
    }
    return theSize;
}

-(int)currentVariableByteSize
{
    int32_t size = [self currentVariableSize];
    switch(_dataType)
    {
        case NC_BYTE:
            return size;
            break;
        case NC_CHAR:
            return size;
            break;
        case NC_SHORT:
            return size*2;
            break;
        case NC_INT:
            return size*4;
            break;
        case NC_FLOAT:
            return size*4;
            break;
        case NC_DOUBLE:
            return size*8;
            break;
        default:
            return -1;
            break;







    }
}

-(NSArray *)lengthArray
{
	NSMutableArray *theArray = [[NSMutableArray alloc] init];
	int32_t i;
	for(i=0;i<[_theDims count];i++)
	{
		[theArray addObject:[NSNumber numberWithInt:[[_theDims objectAtIndex:i] dimLength]]];
	}
	return [NSArray arrayWithArray:theArray];
}

-(BOOL)isUnlimited
{
	return YES;
}

-(BOOL)doesVariableUseDimensionName:(NSString *)aDimName
{
	int32_t i;
	BOOL result = NO;
	for(i=0;i<[_theDims count];i++)
	{
		if([[[_theDims objectAtIndex:i] dimensionName] isEqualToString:aDimName])
			result = YES;
	}
	return result;
}

-(int)unlimitedVariableLength
{
	return [[_theDims objectAtIndex:_unlimitedDimLocation] length];
}

-(NSArray *)dimensionNames
{
	NSMutableArray *anArray = [[NSMutableArray alloc] init];
	int32_t i;
	for(i=0;i<[_theDims count];i++)
	{
		[anArray addObject:[[_theDims objectAtIndex:i] dimensionName]];
	}
	return [NSArray arrayWithArray:anArray];
}

-(NSArray *)allVariableDimInformation
{
	return _theDims;
}

-(NCDFAttribute *)variableAttributeByName:(NSString *)name
{
	return [[[_seriesHandle rootHandle] retrieveVariableByName:_variableName]variableAttributeByName:name];
}

-(NSString *)stringValueForSingleValueCoordinates:(NSArray *)coordinates
{
	id result = [self getSingleValue:coordinates];
	switch(_dataType)
	{
			case NC_BYTE:
				return [NSString stringWithFormat:@"%i",[result intValue]];
				break;
			case NC_CHAR:
				return [NSString stringWithFormat:@"%@",result];
				break;
			case NC_SHORT:
				return [NSString stringWithFormat:@"%i",[result intValue]];
				break;
			case NC_INT:
				return [NSString stringWithFormat:@"%i",[result intValue]];
				break;
			case NC_FLOAT:
				return [NSString stringWithFormat:@"%e",[result floatValue]];
				break;
			case NC_DOUBLE:
				return [NSString stringWithFormat:@"%e",[result doubleValue]];
				break;
			default:
				return [NSString stringWithFormat:@"UNKNOWN"];
	}
}

-(int)attributeCount
{
	return [[[_seriesHandle rootHandle] retrieveVariableByName:_variableName] attributeCount];
}

-(NCDFSlab *)getSlabForStartCoordinates:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths
{
	NSData *theTempData = [self getValueArrayAtLocation:startCoordinates edgeLengths:edgeLengths];
	NCDFSlab *theSlab = [[NCDFSlab alloc] initSlabWithData:theTempData withType:_dataType withLengths:edgeLengths] ;
	return theSlab;
}

-(NCDFSlab *)getAllDataInSlab
{
	NSData *theTempData = [self readAllVariableData];
	NCDFSlab *theSlab = [[NCDFSlab alloc] initSlabWithData:theTempData withType:_dataType withLengths:[self lengthArray]];
	return theSlab;
}

-(int)variableID
{
	return [[[_seriesHandle rootHandle] retrieveVariableByName:_variableName] variableID];
}

-(void)dealloc
{
    _variableName = nil;
    _typeName = nil;
    _seriesHandle = nil;
    _theDims = nil;

}
@end
