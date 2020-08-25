//
//  NCDFSeriesHandle.m
//  netcdf
//
//  Created by Tom Moore on 6/15/07.
//  Copyright 2007 PaleoTerra. All rights reserved.
//


#import "NCDFSeriesHandle.h"
#import "NCDFHandle.h"
#import "NCDFAttribute.h"
#import "NCDFDimension.h"
#import "NCDFVariable.h"
#import "NCDFSeriesDimension.h"
#import "NCDFSeriesVariable.h"

@interface NCDFSeriesHandle (Private)
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

@end

@implementation NCDFSeriesHandle

-(id)initWithOrderedPathSeries:(NSArray *)paths
{
	NSMutableArray *newURL = [[NSMutableArray alloc] init];
	int32_t i;
	for(i=0;i<[paths count];i++)
	{
		[newURL addObject:[NSURL fileURLWithPath:paths[i]]];
	}
	return [self initWithOrderedURLSeries:[NSArray arrayWithArray:newURL]];
}

-(id)initWithOrderedURLSeries:(NSArray *)urls
{
	self = [super init];
	if(self)
	{
		BOOL isValid = YES;
		int32_t i;
		NCDFHandle *aHandle;
		NSString *dirPath;
		_isSingleDirectory = YES;
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];
		for(i=0;i<[urls count];i++)
		{
			if(i==0)
			{
				dirPath = [[urls[i] path] stringByDeletingLastPathComponent];
			}
			if(![[NSFileManager defaultManager] fileExistsAtPath:[urls[i] path]])
			{
				isValid = NO;
				if(![[[urls[i] path] stringByDeletingLastPathComponent] isEqualToString:dirPath])
					_isSingleDirectory = NO;
			}
			if(isValid)
			{
				if((aHandle = [[NCDFHandle alloc] initWithFileAtPath:[urls[i] path]]))
				{
					[tempArray addObject:aHandle];
				}
				else
					isValid = NO;
			}
			if(!isValid)
				break;
		}
		if(!isValid)
		{
			return nil;
		}
		else
		{
			_theURLS = [NSArray arrayWithArray:urls];
			_theHandles = [NSArray arrayWithArray:tempArray];
			[self seedArrays];
			return self;
		}
	}
	return nil;
}

-(id)initWithSeriesFileAtPath:(NSString *)path
{
	return [self initWithSeriesFileAtURL:[NSURL fileURLWithPath:path]];
}

-(id)initWithSeriesFileAtURL:(NSURL *)url
{
	self = [super init];
	if(self)
	{
		NSDictionary *theDict = [NSDictionary dictionaryWithContentsOfURL:url];
		NSArray *theFiles = [theDict objectForKey:@"files"];
		NSMutableArray *tempURLs = [[NSMutableArray alloc] init];
		int32_t i;
		if([[theDict objectForKey:@"isSingleDirectory"] isEqualToString:@"YES"])
		{
			_isSingleDirectory = YES;
			NSString *basePath = [theDict objectForKey:@"directoryPath"];
			for(i=0;i<[theFiles count];i++)
			{
				[tempURLs addObject:[NSURL fileURLWithPath:[basePath stringByAppendingPathComponent:theFiles[i]]]];
			}
		}
		else
		{
			_isSingleDirectory = NO;
			for(i=0;i<[theFiles count];i++)
			{
				[tempURLs addObject:[NSURL fileURLWithPath:theFiles[i]]];
			}
		}
		_theURLS = [NSArray arrayWithArray:tempURLs];
		NSMutableArray *theHandleTemp = [[NSMutableArray alloc] init];
		for(i=0;i<[_theURLS count];i++)
		{
			NCDFHandle *theHandle = [[NCDFHandle alloc] initWithFileAtPath:[[_theURLS objectAtIndex:i] path]];
			[theHandleTemp addObject:theHandle];
		}
		_theHandles = [NSArray arrayWithArray:theHandleTemp];
		[self seedArrays];
	}
	return self;
}


-(id)initWithUnorderedPathSeries:(NSArray *)paths sorted:(BOOL *)sorted
{
	NSMutableArray *newURL = [[NSMutableArray alloc] init];
	int32_t i;
	for(i=0;i<[paths count];i++)
	{
		[newURL addObject:[NSURL fileURLWithPath:paths[i]]];
	}
	return [self initWithUnorderedURLSeries:[NSArray arrayWithArray:newURL] sorted:sorted];
}

-(id)initWithUnorderedURLSeries:(NSArray *)urls sorted:(BOOL *)sorted
{
	self = [super init];
	if(self)
	{
		BOOL isValid = YES;
		int32_t i;
		NCDFHandle *aHandle;
		NSString *dirPath;
		_isSingleDirectory = YES;
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];

		for(i=0;i<[urls count];i++)
		{
			if(i==0)
			{
				dirPath = [[urls[i] path] stringByDeletingLastPathComponent];
			}

			if(![[NSFileManager defaultManager] fileExistsAtPath:[urls[i] path]])
			{
				isValid = NO;
				if(![[[urls[i] path] stringByDeletingLastPathComponent] isEqualToString:dirPath])
					_isSingleDirectory = NO;
			}

			if(isValid)
			{
				if((aHandle = [[NCDFHandle alloc] initWithFileAtPath:[urls[i] path]]))
				{
					[tempArray addObject:aHandle];
				}
				else
					isValid = NO;
			}
			if(!isValid)
				break;
		}
		if(!isValid)
		{
			return nil;
		}
		else
		{
			_theURLS = [NSArray arrayWithArray:urls];
			_theHandles = [NSArray arrayWithArray:tempArray];

			*sorted = [self sortHandles];

			[self seedArrays];
			return self;
		}
	}
	return nil;
}

-(BOOL)sortHandles
{
	NSArray *tempArray = [_theHandles sortedArrayUsingSelector:@selector(compareUnlimitedValue:)];
	int32_t i;

	BOOL theFinalResult = YES;
	for(i=0;i<[tempArray count]-1;i++)
	{
		NSComparisonResult theResult = [tempArray[i] compareUnlimitedValue:[tempArray objectAtIndex:i+1]];
		if(theResult != NSOrderedAscending)
		{
			theFinalResult = NO;
		}
	}

	if(!theFinalResult)
		return theFinalResult;
	NSMutableArray *newURLS = [[NSMutableArray alloc] init];
	for(i=0;i<[tempArray count];i++)
	{

		[newURLS addObject:[_theURLS objectAtIndex:[_theHandles indexOfObject:tempArray[i]]]];
	}

	_theURLS = [NSArray arrayWithArray:newURLS];
	_theHandles = tempArray;
	return theFinalResult;
}

//*WRITING OUT SERIES INFO
-(BOOL)writeSeriesToFile:(NSString *)path
{
	NSURL *aURL = [NSURL fileURLWithPath:path];
	return [self writeSeriesToURL:aURL];
}

-(BOOL)writeSeriesToURL:(NSURL *)url
{
	//two possibilities for storage
	// 1. If every file is within the same directory, save as a relative path (and save the directory path in case the file moves or the save file is located elsewhere)
	// 2. If nc files located in multiple directories, save all paths as full paths
	NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
	int32_t i;
	if(_isSingleDirectory)
	{
		[aDict setObject:@"YES" forKey:@"isSingleDirectory"];
		[aDict setObject:[[[_theURLS objectAtIndex:0] path] stringByDeletingLastPathComponent] forKey:@"directoryPath"];
		NSMutableArray *anArray = [[NSMutableArray alloc] init];
		for(i=0;i<[_theURLS count];i++)
		{
			[anArray addObject:[[[_theURLS objectAtIndex:i] path] lastPathComponent]];
		}
		[aDict setObject:[NSArray arrayWithArray:anArray] forKey:@"files"];
	}
	else
	{
		[aDict setObject:@"NO" forKey:@"isSingleDirectory"];
		NSMutableArray *anArray = [[NSMutableArray alloc] init];
		for(i=0;i<[_theURLS count];i++)
		{
			[anArray addObject:[[_theURLS objectAtIndex:i] path]];
		}
		[aDict setObject:[NSArray arrayWithArray:anArray] forKey:@"files"];
	}
	return [aDict writeToURL:url atomically:YES];
}

-(void)seedArrays
{
	[self seedDimensions];
	[self seedVariables];
}

-(void)seedDimensions
{
	NCDFDimension *aDim;
	NSEnumerator *theEnum = [[self getRootDimensions] objectEnumerator];
	NSMutableArray *_tempDim = [[NSMutableArray alloc] init];;
	while(aDim = [theEnum nextObject])
	{
		[_tempDim addObject:[[NCDFSeriesDimension alloc] initWithDimension:aDim withHandleArray:_theHandles]];
	}
	_theDimensions = [NSArray arrayWithArray:_tempDim];
}

-(void)seedVariables
{
	NCDFVariable *aVar;
	NSEnumerator *theEnum = [[self getRootVariables] objectEnumerator];
	NSMutableArray *_tempVar = [[NSMutableArray alloc] init];;
	while(aVar = [theEnum nextObject])
	{
		[_tempVar addObject:[[NCDFSeriesVariable alloc] initWithVariable:aVar fromHandle:self]];
	}
	_theVariables = [NSArray arrayWithArray:_tempVar];
}

//**** ACCESSORS

-(NSArray *)urls
{
	return _theURLS;
}

-(NSArray *)handles
{
	return _theHandles;
}

-(int)handleCount
{
	return (int)[_theHandles count];
}

-(NCDFHandle *)handleAtIndex:(int)index
{
	return [_theHandles objectAtIndex:index];
}

-(NCDFHandle *)rootHandle
{
	return [_theHandles objectAtIndex:0];
}

-(NSArray *)getRootGlobalAttributes
{
	return [(NCDFHandle *)[self rootHandle] getGlobalAttributes];
}

-(NSArray *)getRootVariables
{
	return [(NCDFHandle *)[self rootHandle] getVariables];
}

-(NSArray *)getRootDimensions
{
	return [(NCDFHandle *)[self rootHandle] getDimensions];
}

-(NSArray *)getRootNonUnlimitedVariables
{
	NSArray *allVars = [self getRootVariables];
	NSEnumerator *theEnum = [allVars objectEnumerator];
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	NCDFVariable *aVar;
	while(aVar = [theEnum nextObject])
	{
		if(![aVar isUnlimited])
			[tempArray addObject:aVar];
	}
	return [NSArray arrayWithArray:tempArray];
}

-(NCDFAttribute *)retrieveRootGlobalAttributeByName:(NSString *)aName
{
	return [[self rootHandle] retrieveGlobalAttributeByName:aName];
}

-(NSArray *)getDimensions
{
	return _theDimensions;
}

-(NSArray *)getVariables
{
	return _theVariables;
}

-(NCDFSeriesVariable *)retrieveVariableByName:(NSString *)aName
{
	NSEnumerator *anEnum = [_theVariables objectEnumerator];
	NCDFSeriesVariable *temp;
	while(temp = [anEnum nextObject])
	{
		if([[temp variableName] isEqualToString:aName])
			break;
	}
	return temp;
}

-(NCDFSeriesDimension *)retrieveDimensionByName:(NSString *)aName
{
	NCDFSeriesDimension *theDim;
	NSEnumerator *anEnum = [_theDimensions objectEnumerator];
	while(theDim = [anEnum nextObject])
	{
		if([[theDim dimensionName] isEqualToString:aName])
			break;
	}
	return theDim;
}

-(NCDFSeriesDimension *)retrieveUnlimitedDimension
{
	NCDFSeriesDimension *theDim;
	NSEnumerator *anEnum = [_theDimensions objectEnumerator];
	while(theDim = [anEnum nextObject])
	{
		if([theDim isUnlimited])
			break;
	}
	return theDim;
}

-(NCDFSeriesVariable *)retrieveUnlimitedVariable
{
	NSEnumerator *anEnum = [_theVariables objectEnumerator];
	NCDFSeriesVariable *temp;
	while(temp = [anEnum nextObject])
	{
		if([temp isUnlimited])
			break;
	}
	return temp;
}

-(void)dealloc
{
    _theURLS = nil;
    _theHandles = nil;
    _theDimensions = nil;
    _theVariables = nil;
}
@end
