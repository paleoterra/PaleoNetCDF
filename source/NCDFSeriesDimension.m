//
//  NCDFSeriesDimension.m
//  netcdf
//
//  Created by Tom Moore on 6/16/07.
//  Copyright 2007 PaleoTerra. All rights reserved.
//

#import "NCDFNetCDF.h"


@implementation NCDFSeriesDimension

-(id)initWithDimension:(NCDFDimension *)aDim
{
	[super init];
	if(self)
	{
		_dimName = [[aDim dimensionName] retain];
		_length = [aDim dimLength];
		_unlimitedLengthArray = nil;
		_isUnlimited = NO;
	}
	return self;
}

-(id)initWithUnlimitedDimension:(NCDFDimension *)aDim withHandleArray:(NSArray *)theHandles
{
	[super init];
	
	if(self)
	{
		_dimName = [[aDim dimensionName] retain];
		NSEnumerator *anEnum = [theHandles objectEnumerator];
		NCDFHandle *aHandle;
		size_t aLength;
		_length = 0;
		_unlimitedLengthArray = [[NSMutableArray alloc] init];
		NSRange aRange;
		while(aHandle = [anEnum nextObject])
		{
			aLength = [[aHandle retrieveDimensionByName:_dimName] dimLength];
			aRange.location = _length;
			aRange.length = aLength;
			_length += aLength;
			[_unlimitedLengthArray addObject:[NSValue valueWithRange:aRange]];
		}
		
		_isUnlimited = YES;
	}
	return self;
}

-(id)initWithDimension:(NCDFDimension *)aDim withHandleArray:(NSArray *)theHandles
{
	if([aDim isUnlimited])
		return [self initWithUnlimitedDimension:aDim withHandleArray:theHandles];
	else
		return [self initWithDimension:aDim];
}


-(NSString *)dimensionName
{
	return _dimName;
}

-(size_t)dimLength
{
	return _length;
}

-(BOOL)isUnlimited
{
	return _isUnlimited;
}

-(NSArray *)rangeArrayForStart:(int)start andLength:(int)length
{
	NSRange rangeRequest = NSMakeRange(start,length);
	return [self rangeArrayForRange:rangeRequest];
}

-(NSArray *)rangeArrayForRange:(NSRange)aRange
{
	NSEnumerator *anEnum = [_unlimitedLengthArray objectEnumerator];
	NSRange valueRange,intersectRange;
	NSValue *aValue;
	NSMutableArray *resultArray = [[[NSMutableArray alloc] init] autorelease];
	while(aValue = [anEnum nextObject])
	{
		valueRange = [aValue rangeValue];
		intersectRange = NSIntersectionRange(aRange,valueRange);
		if(intersectRange.length > 0)
		{
			intersectRange.location = intersectRange.location - valueRange.location;
		}
		[resultArray addObject:[NSValue valueWithRange:intersectRange]];
	}
	return [NSArray arrayWithArray:resultArray];
}

-(NSString *)description
{
	NSMutableString *aString = [[[NSMutableString alloc] init] autorelease];
	
	[aString appendFormat:@"NCDFSeriesDimension: \t\t %@\n",_dimName];
	if([self isUnlimited])
	{
		[aString appendString:@"\tisUnlimited:\t\t YES\n"];
		NSEnumerator *anEnum = [_unlimitedLengthArray objectEnumerator];
		NSValue *aValue;
		[aString appendFormat:@"\ttotal length:\t\t%i\n",_length];
		[aString appendString:@"\tFile Ranges:\n"];
		while(aValue = [anEnum nextObject])
		{
			[aString appendFormat:@"\t\t%@\n",NSStringFromRange([aValue rangeValue])];
		}
	}
	else
	{
		[aString appendString:@"\tisUnlimited:\t\t NO\n"];
		[aString appendFormat:@"\tlength:\t\t%i\n",_length];
	}
	return [NSString stringWithString:aString];
}



@end
