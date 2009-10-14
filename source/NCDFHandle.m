//
//  NCDFHandle.m
//  netcdf
//
//  Created by tmoore on Wed Feb 13 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

#import "NCDFNetCDF.h"

static NSLock *fileDatabaseLock;



@interface NCDFHandle (PrivateMethods)


/*!
 @method createFileAtPath:
 @abstract Creates a new netcdf file.
 @param thePath path to the target file location.
 @discussion This private method creates a new netcdf file at a path.  It is a convienence method.<P>VALIDATION NOTES: Tested extensively and appears to function as expected.
 */
-(void)createFileAtPath:(NSString *)thePath withSettings:(int)settings;

/*!
 @method setFilePath:
 @abstract Sets the NCDFHandle file path.
 @param thePath the path of a netcdf file.
 @discussion This method is sets the private variable for the NCDFHandle source file path.  This path should not be changed for the duration of the handle's existence and set only during initialization.  Always use a new NCDFHandle for a new path.<P>VALIDATION NOTES: Tested extensively and appears to function as expected.
 */
-(void)setFilePath:(NSString *)thePath;
/*!
 @method initializeArrays
 @abstract This method initializes all the metadata arrays that hold the contents of the netcdf file.
 @discussion This private method empties all the arrays the store all NCDFVariables, NCDFDimensions, and NCDFAttributes.  It should not be called exept by existing initialization methods.<P>VALIDATION NOTES: Tested extensively and appears to function as expected.
 */

/*!
 @functiongroup Internal Use Only
 */

-(void)initializeArrays;
/*!
 @method seedArrays
 @abstract This method retrieves netcdf metadata and stores the data in arrays.
 @discussion This private method places all the metadata describing NCDFAttributes, NCDFDimensions, and NCDFVariables into arrays.  Do not call this method except from existing initialization methods.<P>VALIDATION NOTES: Tested extensively and appears to function as expected.
 */
-(void)seedArrays:(NSArray *)typeArrays;
@end

@implementation NCDFHandle (PrivateMethods)

-(void)setFilePath:(NSString *)thePath
{
    /*Sets the path to the netcdf file.  This method should not be invoked.  This 
	 method does not check for valid paths.*/
    /*Initialization*/
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: setFilePath");
#endif
    if(filePath)
        [filePath release];
    if(thePath)
        filePath = [thePath copy];
    else
        filePath = [[NSString alloc] init];
}


-(void)initializeArrays
{
    /*This method releases all the dimension, attribute and variable data currently held by a NCDFHandle object.  This method should preceed seedArrays.*/
    /*Initialization*/
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: initializeArrays");
#endif
    if(theVariables)
        [theVariables autorelease];
    if(theGlobalAttributes)
        [theGlobalAttributes autorelease];
    if(theDimensions)
        [theDimensions autorelease];
    theVariables = [[NSMutableArray alloc] init];
    theGlobalAttributes = [[NSMutableArray alloc] init];
    theDimensions = [[NSMutableArray alloc] init];
	[self seedArrays:[NSArray arrayWithObjects:theDimensions,theGlobalAttributes,theVariables,nil]];
}


-(void)seedArrays:(NSArray *)typeArrays
{
    /*Populates NCDFDimension,NCDFAttribute,and NCDFVariable objects based on an existing netcdf file.  This method should only be invoked by subclasses of any of the above objects when the objects values were changed in the file.  However, changing these values will release objects held by the handle.*/
    /*Initialization*/
    
    int ncid,status,numberDims,numberVariables,numberGlobalAtts,numberUnlimited;
    int i;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: seedArrays");
#endif
    if(!filePath)
        return;
	
    ncid = [self ncidWithOpenMode:NC_SHARE status:&status];
    if(status!=NC_NOERR)
    {
		NSLog(@"seedArrays: error open");
        return;
    }
    status = nc_inq(ncid,&numberDims,&numberVariables,&numberGlobalAtts,&numberUnlimited);
	//NSLog(@"dims, %i,variable count %i, globalatts %i",numberDims,numberVariables,numberGlobalAtts);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"seedArrays" subMethod:@"Inquiring netCDF file" errorCode:status];
        NSLog(@"seedArrays: error nc_inq");
        return;
    }
    //NSLog(@"m dim");
    for(i=0;i<numberDims;i++)
    {
        char name[NC_MAX_NAME];
        NSString *cocoaName;
        size_t length;
        NCDFDimension *theDim;
        status = nc_inq_dim(ncid,i,name,&length);
        if(status!=NC_NOERR)
        {
            [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"seedArrays" subMethod:@"Inquiring DIMS in netCDF file" errorCode:status];
            NSLog(@"seedArrays: error nc_inq_dim");
            return;
        }
        cocoaName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        //if([cocoaName isEqualToString:@"time"])
		//NSLog(@"time value = %i",length);
        theDim = [[NCDFDimension alloc] initWithFileName:filePath dimID:i name:cocoaName length:length handle:self];
        [[typeArrays objectAtIndex:0] addObject:theDim];
        if(theDim)
            [theDim release];
		
    }
    //NSLog(@"m ga");
	status = nc_inq_natts(ncid, &numberGlobalAtts);
	if(status!=NC_NOERR)
	{
		//[theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"seedArrays" subMethod:@"Inquiring attribute by name in netCDF file" errorCode:status];
		NSLog(@"seedArrays: app count error");
		return;
	}
	//NSLog(@"seed arrays: count %i file %@",numberGlobalAtts,filePath);
    for(i=0;i<numberGlobalAtts;i++)
    {
        char *name = (char *)calloc(NC_MAX_NAME, sizeof(char));
        nc_type attributeType;
        size_t length;
        NCDFAttribute *theAtt;
        status = nc_inq_attname(ncid, NC_GLOBAL,i, name);
        //NSLog(@"seedArrays: %i %s %@",i, name,filePath);
        if(status!=NC_NOERR)
        {
            [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"seedArrays" subMethod:@"Inquiring attribute by name in netCDF file" errorCode:status];
            NSLog(@"seedArrays: error nc_inq_attname %i %s",i, name);
            return;
        }
        status = nc_inq_att ( ncid, NC_GLOBAL, name,
							 &attributeType, &length);
        if(status!=NC_NOERR)
        {
            [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"seedArrays" subMethod:@"Inquiring attribute in netCDF file" errorCode:status];
            NSLog(@"seedArrays: error nc_inq_att %i %s",i, name);
            return;
        }
        theAtt = [[NCDFAttribute alloc] initWithPath:filePath name:[NSString stringWithCString:name encoding:NSUTF8StringEncoding] variableID:NC_GLOBAL length:length type:attributeType handle:self];
        [[typeArrays objectAtIndex:1] addObject:theAtt];
        [theAtt release];
		free(name);
									
        
    }
    //NSLog(@"m var");
    for(i=0;i<numberVariables;i++)
    {
        char name[NC_MAX_NAME];
        nc_type theType;
        int numberOfDims,j;
        int dimIDs[NC_MAX_VAR_DIMS];
        int numberOfAttributes;
        NSMutableArray *theDimList;
        NCDFVariable *theVar;
    	status = nc_inq_var (ncid,i,name,&theType,&numberOfDims,dimIDs,&numberOfAttributes);
        if(status!=NC_NOERR)
        {
            [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"seedArrays" subMethod:@"Inquiring variable in netCDF file" errorCode:status];
            //NSLog(@"seedArrays: error nc_inq_var");
            return;
        }
        theDimList = [[NSMutableArray alloc] init];
        for(j=0;j<numberOfDims;j++)
        {
            [theDimList addObject:[NSNumber numberWithInt:dimIDs[j]]];
        }
        theVar = [[NCDFVariable alloc] initWithPath:filePath variableName:[NSString stringWithCString:name encoding:NSUTF8StringEncoding] variableID:i type:theType theDims:theDimList attributeCount:numberOfAttributes handle:self];
        [[typeArrays objectAtIndex:2] addObject:theVar];
        [theVar release];
        [theDimList release];
    }
    //NSLog(@"close");
    [self closeNCID:ncid];
    
    //NSLog(@"end");
}


-(void)createFileAtPath:(NSString *)thePath withSettings:(int)settings
{
    /*Creates a new netcdf file at path.  This method should not be invoked.*/
    /*Initialization*/
	
	//FORMATS
	/*quoting from manual: The creation mode flag. The following flags are available: NC NOCLOBBER,
	 NC SHARE, NC 64BIT OFFSET, NC NETCDF4, NC CLASSIC MODEL.
	 Setting NC NOCLOBBER means you do not want to clobber (overwrite) an
	 existing dataset; an error (NC EEXIST) is returned if the specified dataset
	 already exists.
	 The NC SHARE*/
    int status;
    int ncid;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: createFileAtPath");
#endif
    [self setFilePath:thePath];
	[fileDatabaseLock lock];
    status = nc_create([thePath UTF8String],settings,&ncid);
	[fileDatabaseLock unlock];
    if(status!=NC_NOERR)
    {
		[theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createFileAtPath" subMethod:@"Creating new file" errorCode:status];
		//NSLog(@"seedArrays: error nc_create");
		return;
	}
    [self closeNCID:ncid];
}


@end

@implementation NCDFHandle

#pragma mark *** Initilization methods ***

+ (void)initialize
{


    fileDatabaseLock = [[NSLock alloc] init];
    NSAssert( fileDatabaseLock != nil, @"Could not create fileDatabaseLock");

}

-(id)initWithFileAtPath:(NSString *)thePath
{
    /*Initializes a NCDFHandle from an existing file at thePath*/
    /*Initialization*/
    int errorCount;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: initWithFileAtPath");
#endif
    self = [super init];
    //added 0.2.1d1
    theErrorHandle = [[NCDFErrorHandle alloc] init];

    errorCount = [theErrorHandle errorCount];
    [self setFilePath:thePath];
    [self initializeArrays];
    
	//NSLog(@"errorCount %i handle %i",errorCount,[theErrorHandle errorCount]);
    if(errorCount<[theErrorHandle errorCount])
    {
		[theErrorHandle logAllErrors];
        [self release];
        return nil;
    }
    else
        return self;
}

-(id)initByCreatingFileAtPath:(NSString *)thePath withSettings:(int)settings
{
    /*Creates a NCDFHandle and netcdf file at thePath.  This file is empty and must be populated with dimensions, attributes, and variables*/
    /*Initialization*/
    int errorCount;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: initByCreatingFileAtPath");
#endif
    [super init];
    //added 0.2.1d1
    theErrorHandle =[[NCDFErrorHandle alloc] init];
    errorCount = [theErrorHandle errorCount];
    [self createFileAtPath:thePath withSettings:settings];
    if(errorCount<[theErrorHandle errorCount])
    {
        [self release];
        return nil;
    }
    [self setFilePath:thePath];
    [self initializeArrays];
	handleLock = [[NSLock alloc] init];
    if(errorCount<[theErrorHandle errorCount])
    {
        [self release];
        return nil;
    }
    else
        return self;
    return self;
}

-(id)initByCreatingFileAtPath:(NSString *)thePath //retained for compatibility
{
	/*Creates a NCDFHandle and netcdf file at thePath.  This file is empty and must be populated with dimensions, attributes, and variables*/
    /*Initialization*/
    int errorCount;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: initByCreatingFileAtPath");
#endif
    [super init];
    //added 0.2.1d1
    theErrorHandle =[[NCDFErrorHandle alloc] init];
    errorCount = [theErrorHandle errorCount];
    [self createFileAtPath:thePath withSettings:NC_CLOBBER];
    if(errorCount<[theErrorHandle errorCount])
    {
        [self release];
        return nil;
    }
    [self setFilePath:thePath];
    [self initializeArrays];
	handleLock = [[NSLock alloc] init];
    if(errorCount<[theErrorHandle errorCount])
    {
        [self release];
        return nil;
    }
    else
        return self;
    return self;
}

+(id)handleWithNewFileAtPath:(NSString *)thePath
{
	NCDFHandle *aHandle = [[NCDFHandle alloc] initByCreatingFileAtPath:thePath withSettings:NC_CLOBBER];
	return [aHandle autorelease];
}

+(id)handleWithNew64BitFileAtPath:(NSString *)thePath
{
	NCDFHandle *aHandle = [[NCDFHandle alloc] initByCreatingFileAtPath:thePath withSettings:(NC_CLOBBER|NC_64BIT_OFFSET)];
	return [aHandle autorelease];
}

+(id)handleWithNewNetCDF4FileAtPath:(NSString *)thePath
{
	NCDFHandle *aHandle = [[NCDFHandle alloc] initByCreatingFileAtPath:thePath withSettings:(NC_CLOBBER|NC_NETCDF4)];
	return [aHandle autorelease];
}

+(id)handleWithNewClassicNetCDF4FileAtPath:(NSString *)thePath
{
	NCDFHandle *aHandle = [[NCDFHandle alloc] initByCreatingFileAtPath:thePath withSettings:(NC_CLOBBER|NC_NETCDF4|NC_CLASSIC_MODEL)];
	return [aHandle autorelease];
}





#pragma mark *** Setup methods ***



-(NSString *)theFilePath
{
    return filePath;
}

-(NSLock *)handleLock
{
	return handleLock;
}




-(void)refresh
{
    /*This method immediately invalidates all objects held by the handle.  After invalidation, the handle reloads object information for access.*/
    /*Initialization*/
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: refresh");
#endif
    //[self initializeArrays];
    //[self seedArrays];
	NSMutableArray *tempDim = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *tempAtt = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *tempVar = [[[NSMutableArray alloc] init] autorelease];
	[self seedArrays:[NSArray arrayWithObjects:tempDim,tempAtt,tempVar,nil]];
	//temp arrays are seeded.  Now we need to update,add, and delete.
	
	//How to do the dims
	NSMutableArray *theDimsLeft = [NSMutableArray arrayWithArray:theDimensions] ;
	NCDFDimension *aDim,*mainDim;
	NSEnumerator *anEnum = [tempDim objectEnumerator];
	while(aDim = [anEnum nextObject])
	{
		mainDim = [self retrieveDimensionByName:[aDim dimensionName]];
		if(mainDim)
		{
			[theDimsLeft removeObject:mainDim]; //delete the dim from our temp main list
			[mainDim updateDimensionWithDimension:aDim];
		}
		else
			[theDimensions addObject:aDim];
		mainDim = nil;
	}
	NSEnumerator *anEnuma = [theDimsLeft objectEnumerator];
	while(aDim = [anEnuma nextObject])
	{
		[[aDim retain] autorelease];
		[theDimensions removeObject:aDim];
	}
	[theDimsLeft removeAllObjects];
	[theDimensions sortUsingSelector:@selector(compare:)];

	
	//global attributes
	NCDFAttribute *anAtt,*mainAtt;
	NSEnumerator *anEnum1 = [tempAtt objectEnumerator];
	
	NSMutableArray *theAttsLeft = [NSMutableArray arrayWithArray:theGlobalAttributes] ;
	while(anAtt = [anEnum1 nextObject])
	{
		mainAtt = [self retrieveGlobalAttributeByName:[anAtt attributeName]];
		if(mainAtt)
		{
			[theAttsLeft removeObject:mainAtt]; //delete the dim from our temp main list
			[mainAtt updateAttributeWithAttribute:anAtt];
		}
		else
			[theGlobalAttributes addObject:anAtt];
		mainAtt = nil;
	}
	NSEnumerator *anEnum1a = [theAttsLeft objectEnumerator];
	while(anAtt = [anEnum1a nextObject])
	{
		[[anAtt retain] autorelease];
		[theGlobalAttributes removeObject:anAtt];
	}
	[theAttsLeft removeAllObjects];


	//global variables
	//global attributes
	NCDFVariable *aVar,*mainVar;
	NSEnumerator *anEnum2 = [tempVar objectEnumerator];
	//NSLog([tempVar description]);
	NSMutableArray *theVarsLeft = [NSMutableArray arrayWithArray:theVariables];
	while(aVar = [anEnum2 nextObject])
	{
		mainVar = [self retrieveVariableByName:[aVar variableName]];
		if(mainVar)
		{
			[theVarsLeft removeObject:mainVar]; //delete the dim from our temp main list
			[mainVar updateVariableWithVariable:aVar];
		}
		else
			[theVariables addObject:aVar];
		mainAtt = nil;
	}
	NSEnumerator *anEnum2a = [theVarsLeft objectEnumerator];
	while(aVar = [anEnum2a nextObject])
	{
		[[aVar retain] autorelease];
		[theVariables removeObject:aVar];
	}
	[theVarsLeft removeAllObjects];
	//NSLog(@"the count here is %i",[theVariables count]);
}

#pragma mark *** Deallocation methods ***
-(void)dealloc
{
    /*Releases all arrays held by the handle*/
    /*Deallocation*/
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: dealloc");
#endif
    if(theVariables)
        [theVariables release];
   
    if(theGlobalAttributes)
        [theGlobalAttributes release];
    
    if(theDimensions)
        [theDimensions release];
    
    if(filePath)
        [filePath release];
	
	if(theErrorHandle)
		[theErrorHandle release]; 
    if(handleLock)
		[handleLock release];
	if(_theCompareValue)
		[_theCompareValue release];
    [super dealloc];
}

-(void)finalize
{
	[super finalize];
}

#pragma mark *** Simple Accessing Methods ***

-(NSMutableArray *)getDimensions
{
    /*Returns a mutable array listing all the dimensions in the current netcdf file.  This method may be updated to return only a NSArray*/
    /*Accessors*/
    return theDimensions;
}



-(NSMutableArray *)getGlobalAttributes
{
    /*Returns a mutable array listing all the global attributes in the current netcdf file.  This method may be updated to return only a NSArray*/
    /*Accessors*/
    return theGlobalAttributes;
}


-(NSMutableArray *)getVariables
{
    /*Returns a mutable array listing all the global attributes in the current netcdf file. This method may be updated to return only a NSArray*/
    /*Accessors*/
    return theVariables;
}


#pragma mark *** Error Handle Methods ***
-(NCDFErrorHandle *)theErrorHandle
{
    return theErrorHandle;
}

#pragma mark *** Dimension Methods ***

-(BOOL)createNewDimensionWithName:(NSString *)dimName size:(size_t)length
{
    /*Creates a new dimention with the name and size defined by the caller.  Dimension number assignment is defined by the netcdf library.  This method will also release and reload data held by the handle, invalidating all dimensions, attributes, and variables previously held by the handle. The length of an unlimited dimension is defined as NC_UNLIMITED (one unlimited dimension per file).  (SHOULD CREATE ASSOCIATED VARIABLES)*/
    /*Modify netcdf: Dimensions*/
    int ncid;
    int status;
    int newID;
    
    char *theCName;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: createNewDimensionWithName");
#endif
    dimName = [self parseNameString:dimName];
#ifdef DEBUG_LOG
    NSLog(dimName);
#endif
    ncid = [self ncidWithOpenMode:NC_WRITE status:&status];
    
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewDimensionWithName" subMethod:@"Opening file" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewDimensionWithName" subMethod:@"Set redefine mode" errorCode:status];
        return NO;
    }
    theCName = (char *)malloc(sizeof(char)*[dimName length]+1);
	[dimName getCString:theCName maxLength:[dimName length]+1 encoding:NSUTF8StringEncoding];
    status = nc_def_dim(ncid,theCName,length,&newID);
    free(theCName);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewDimensionWithName" subMethod:@"Define dimension" errorCode:status];
        return NO;
    }

    [self closeNCID:ncid];
    [self refresh];
    return YES;

}

-(BOOL)createNewDimensionWithPropertyList:(NSDictionary *)propertyList
{
    BOOL result;
    size_t length;
    int i;
    i = [[propertyList objectForKey:@"length"] intValue];
    length = (size_t)i;
    result = [self createNewDimensionWithName:[propertyList objectForKey:@"dimName"] size:length];
	if(result)
		[self refresh];
    return result;
}

-(NSArray *)createNewDimensionsFromDimensionArray:(NSArray *)newDimensionArray
{
    /*The primary purpose of this method is to copy the dimensions from one handle to another.  Basically, an array NCDFDimensions can be acquired from another NCDFHandle and used to call this method.  This method does not delete any existing dimensions.  After calling this method, the handle's previously held dimensions, attributes, and variables are invalidated.  It is unwise to call this method with existing variable data.  (SHOULD CREATE ASSOCIATED VARIABLES)*/
    /*Modify netcdf: Dimensions*/
    int ncid;
    int status;
    int newID;
    
    char *theCName;
    int i,j;
    size_t length;
    NSString *dimName;
    NSMutableArray *validDim = [[NSMutableArray alloc] init];
    NSMutableArray *returnDims = [[NSMutableArray alloc] init];
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: createNewDimensionsFromDimensionArray");
#endif
    for(i=0;i<[newDimensionArray count];i++)
    {
        BOOL valid;
        valid = YES;
        for(j=0;j<[theDimensions count];j++)
        {
            
            if([[newDimensionArray objectAtIndex:i] isEqualToDim:[theDimensions objectAtIndex:i]])
            {
                valid = NO;
                j = [theDimensions count];
            }
        }
        if(valid)
        {
            [validDim addObject:[NSNumber numberWithInt:1]];
        }
        else
        {
            [validDim addObject:[NSNumber numberWithInt:0]];
            [returnDims addObject:[newDimensionArray objectAtIndex:i]];
            
        }
    }
    
    
    
    ncid = [self ncidWithOpenMode:NC_WRITE status:&status];
    
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewDimensionsFromDimensionArray" subMethod:@"Opening file" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewDimensionsFromDimensionArray" subMethod:@"Set redefine mode" errorCode:status];
        return NO;
    }
    
    //cycle through dims
    for(i=0;i<[newDimensionArray count];i++)
    {
        if([[validDim objectAtIndex:i] intValue]==1)
        {
        dimName = [self parseNameString:[[newDimensionArray objectAtIndex:i]dimensionName]];
#ifdef DEBUG_LOG
        NSLog(dimName);
#endif
        length = [[newDimensionArray objectAtIndex:i]dimLength];
        theCName = (char *)malloc(sizeof(char)*[dimName length]+1);
       
		[dimName getCString:theCName maxLength:[dimName length]+1 encoding:NSUTF8StringEncoding];
        status = nc_def_dim(ncid,theCName,length,&newID);
        if(status!=NC_NOERR)
        {
            [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewDimensionsFromDimensionArray" subMethod:@"Defining a dimension" errorCode:status];
        }
        free(theCName);
        //if(status!=NC_NOERR)
            //return NO;
        }
    }
    [self closeNCID:ncid];
    [validDim release];
    [self refresh];
    return [NSArray arrayWithArray:[returnDims autorelease]];

}

-(BOOL)deleteDimensionWithName:(NSString *)deleteDimName
{
    NSFileManager *theManager = [NSFileManager defaultManager];
    NCDFHandle *newHandle;
    NSString *tempPath = [filePath stringByAppendingString:@"_.nc"];

    int i, errorCount;
    
    errorCount = [theErrorHandle errorCount];
    while([theManager fileExistsAtPath:tempPath])
    {
        tempPath = [tempPath stringByAppendingString:@"_.nc"];
    }
    newHandle = [[NCDFHandle alloc] initByCreatingFileAtPath:tempPath];
    
    for(i=0;i<[theGlobalAttributes count];i++)
    {
        [newHandle createNewGlobalAttributeWithPropertyList:[[theGlobalAttributes objectAtIndex:i] propertyList]];
    }
    
    for(i=0;i<[theDimensions count];i++)
    {
        if(![[[theDimensions objectAtIndex:i] dimensionName] isEqualToString:deleteDimName])
        [newHandle createNewDimensionWithPropertyList:[[theDimensions objectAtIndex:i] propertyList]];
    }
    
    for(i=0;i<[theVariables count];i++)
    {
        if(![[theVariables objectAtIndex:i] doesVariableUseDimensionName:deleteDimName])
        {
        [newHandle createNewVariableWithPropertyList:[[theVariables objectAtIndex:i] propertyList]];
        }
    }
    
    if(errorCount<[theErrorHandle errorCount])
    {
		[theManager removeItemAtPath:tempPath error:nil];
		[newHandle release];
        return NO;
    }
    else
    {
        [theManager removeItemAtPath:filePath error:nil];
		[theManager moveItemAtPath:tempPath toPath:filePath error:nil];
        [self refresh];
        [newHandle release];
        return YES;
    }
}


-(BOOL)resizeDimensionWithName:(NSString *)resizeDimName size:(int)newSize
{
    NSFileManager *theManager = [NSFileManager defaultManager];
    NCDFHandle *newHandle;
    NSString *tempPath = [filePath stringByAppendingString:@"_.nc"];

    int i, errorCount;
    
    errorCount = [theErrorHandle errorCount];
    while([theManager fileExistsAtPath:tempPath])
    {
        tempPath = [tempPath stringByAppendingString:@"_.nc"];
    }
    newHandle = [[NCDFHandle alloc] initByCreatingFileAtPath:tempPath];
    
    for(i=0;i<[theGlobalAttributes count];i++)
    {
        [newHandle createNewGlobalAttributeWithPropertyList:[[theGlobalAttributes objectAtIndex:i] propertyList]];
    }
    //NSLog(@"attributes created");
    for(i=0;i<[theDimensions count];i++)
    {
        if(![[[theDimensions objectAtIndex:i] dimensionName] isEqualToString:resizeDimName])
        [newHandle createNewDimensionWithPropertyList:[[theDimensions objectAtIndex:i] propertyList]];
        else
            [newHandle createNewDimensionWithName:resizeDimName size:(size_t)newSize];
    }
    //NSLog(@"dims created");
    for(i=0;i<[theVariables count];i++)
    {
        if(![[theVariables objectAtIndex:i] doesVariableUseDimensionName:resizeDimName])
        [newHandle createNewVariableWithPropertyList:[[theVariables objectAtIndex:i] propertyList]];
        else
        {
            int newSize,newCount;
            NSArray *theUsedDims = [[theVariables objectAtIndex:i] allVariableDimInformation];
            NSMutableData *newData;
            NSMutableDictionary *propertyList;
            newSize = 1;
            for(newCount = 0;newCount<[theUsedDims count];newCount++)
            {
                if(![[[theUsedDims objectAtIndex:newCount] dimensionName] isEqualToString:resizeDimName])
                    newSize *= (int)[[theUsedDims objectAtIndex:newCount] dimLength];
                else
                    newSize *= newSize;
            }
            
            switch ([[theVariables objectAtIndex:i] variableNC_TYPE])
            {
                case NC_BYTE:
                    newSize *= 1;
                    break;
                case NC_CHAR:
                    newSize *= 1;
                    break;
                case NC_SHORT:
                    newSize *= 2;
                    break;
                case NC_INT:
                    newSize *= 4;
                    break;
                case NC_FLOAT:
                    newSize *= 4;
                    break;
                case NC_DOUBLE:
                    newSize *= 8;
                    break;
                default:
                    break;
            }
            newData = [NSMutableData dataWithData:[[theVariables objectAtIndex:i] readAllVariableData]];
            [newData setLength:newSize];
            propertyList = [NSMutableDictionary dictionaryWithDictionary:[[theVariables objectAtIndex:i] propertyList]];
            [propertyList setObject:[NSData dataWithData:newData] forKey:@"data"];
            [newHandle createNewVariableWithPropertyList:[NSDictionary dictionaryWithDictionary:propertyList]];
            
        }
    }
    //NSLog(@"finished making");
    if(errorCount<[theErrorHandle errorCount])
    {
        [theManager removeItemAtPath:tempPath error:nil];
        [newHandle release];
        return NO;
    }
    else
    {
        [theManager removeItemAtPath:filePath error:nil];
		[theManager moveItemAtPath:tempPath toPath:filePath error:nil];
        [self refresh];
        [newHandle release];
        return YES;
    }
}
/*additional methods needed
1) create dimensions via dimension array and variable array - minimize work
X2) rename dimensions (possibly in NCDFDimension).  
x3) need to check if removing a dim will change the numbers.  If not, some modifications are needed.  Ruled out since you can't delete a dimension.
X4) Modify existing methods to handle the creation of dimension variables automatically - blank values.  THis is ruled out since variables require more information than just a yes or no.*/


#pragma mark *** Global Attributes Methods ***

-(BOOL)createNewGlobalAttributeWithName:(NSString *)attName dataType:(nc_type)theType values:(NSArray *)theValues
{
    /*Creates a new global attribute with the name, type, and size defined by the caller.  nc_type can be any of the accepted types.  theValues array is a array of either NSNumber, NSData objects or a NSString.  Use NSNumber objects when using short, ints, floats, and doubles.  NSString for text objects.  The number of objects in the array define the length of the attibute data.  Use only one NSString object if text is to be used.  NSData objects should be used for NC_BYTE objects.  Creating a new global attribute immediately invalidates all dimensions, attributes, and variables held by the handle. */
    /*Modify netcdf: Global Attributes*/
    int ncid;
    int status;
    
    BOOL dataWritten;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: createNewGlobalAttributeWithName");
#endif
    attName = [self parseNameString:attName];

    ncid = [self ncidWithOpenMode:NC_WRITE status:&status];
    
    if(status!=NC_NOERR)
    {
        //NSLog(@"Failed to open");
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewGlobalAttributeWithName" subMethod:@"Opening file" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);
    if(status!=NC_NOERR)
    {
        //NSLog(@"Failed to redef");
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewGlobalAttributeWithName" subMethod:@"Redefine mode" errorCode:status];
        return NO;
    }
    dataWritten = NO;
    switch (theType){
        case NC_BYTE:
        {
            unsigned char *theText;
            theText = (unsigned char *)malloc(sizeof(unsigned char)*[(NSData *)[theValues objectAtIndex:0]length]);
            [[theValues objectAtIndex:0] getBytes:theText];
            status = nc_put_att_uchar (ncid,NC_GLOBAL,[attName UTF8String],theType,[(NSData *)[theValues objectAtIndex:0]length],theText);
            free(theText);
            if(status==NC_NOERR)
                dataWritten = YES;
            else
            {
                [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewGlobalAttributeWithName" subMethod:@"write NC_BYTE" errorCode:status];
            }
            break;
        }
        case NC_CHAR:
        {
            status = nc_put_att_text (ncid,NC_GLOBAL,[attName UTF8String],[(NSString *)[theValues objectAtIndex:0]length],[[theValues objectAtIndex:0] UTF8String]);
            if(status==NC_NOERR)
                dataWritten = YES;
            else
            {
                [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewGlobalAttributeWithName" subMethod:@"write NC_CHAR" errorCode:status];
            }
            break;
        }
        case NC_SHORT:
        {
            int i;
            short *array;
            array = (short *)malloc(sizeof(short)*[theValues count]);
            for(i=0;i<[theValues count];i++)
                array[i] = [[theValues objectAtIndex:i] shortValue];
            status = nc_put_att_short (ncid,NC_GLOBAL,[attName UTF8String],theType,(size_t)[theValues count],array);
            if(status==NC_NOERR)
                dataWritten = YES;
            else
            {
                [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewGlobalAttributeWithName" subMethod:@"write NC_SHORT" errorCode:status];
            }
            free(array);
            break;
        }
        case NC_INT:
        {
            int i;
            int *array;
            array = (int *)malloc(sizeof(int)*[theValues count]);
            for(i=0;i<[theValues count];i++)
                array[i] = [[theValues objectAtIndex:i] intValue];
            status = nc_put_att_int (ncid,NC_GLOBAL,[attName UTF8String],theType,(size_t)[theValues count],array);
            if(status==NC_NOERR)
                dataWritten = YES;
            else
            {
                [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewGlobalAttributeWithName" subMethod:@"write NC_INT" errorCode:status];
            }
            free(array);
            break;
        }
        case NC_FLOAT:
        {
            int i;
            float *array;
            array = (float *)malloc(sizeof(float)*[theValues count]);
            for(i=0;i<[theValues count];i++)
                array[i] = [[theValues objectAtIndex:i] floatValue];
            status = nc_put_att_float(ncid,NC_GLOBAL,[attName UTF8String],theType,(size_t)[theValues count],array);
            if(status==NC_NOERR)
                dataWritten = YES;
            else
            {
                [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewGlobalAttributeWithName" subMethod:@"write NC_FLOAT" errorCode:status];
            }
            free(array);
            break;
        }
        case NC_DOUBLE:
        {
            int i;
            double *array;
            array = (double *)malloc(sizeof(double)*[theValues count]);
            for(i=0;i<[theValues count];i++)
                array[i] = [[theValues objectAtIndex:i] doubleValue];
            status = nc_put_att_double(ncid,NC_GLOBAL,[attName UTF8String],theType,(size_t)[theValues count],array);
            if(status==NC_NOERR)
                dataWritten = YES;
            else
            {
                [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewGlobalAttributeWithName" subMethod:@"write NC_DOUBLE" errorCode:status];
            }
            free(array);
            break;
        }
        case NC_NAT:
        {
            NSLog(@"createNewGlobalAttributeWithName: Case NC_NAT not handled");
        }
    }
    
    [self closeNCID:ncid];
    if(!dataWritten)
        return NO;

    
    [self refresh];
    return YES;


}

-(BOOL)createNewGlobalAttributeWithPropertyList:(NSDictionary *)propertyList
{
    BOOL result;
    int i;
    i = [[propertyList objectForKey:@"nc_type"] intValue];
    result = [self createNewGlobalAttributeWithName:[propertyList objectForKey:@"attributeName"] dataType:(nc_type)i values:[propertyList objectForKey:@"values"]];
    if(result)
		[self refresh];
	return result;
}


-(NSArray *)createNewGlobalAttributeWithArray:(NSArray *)theNewAttributes
{
    int i,j;
    NSMutableArray *existingAttributes = [[NSMutableArray alloc] init];
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: createNewGlobalAttributeWithArray");
#endif    
    for(i=0;i<[theNewAttributes count];i++)
    {
        BOOL valid,result;
        valid = YES;
        for(j=0;j<[theGlobalAttributes count];j++)
        {
            if([[theNewAttributes objectAtIndex:i] isEqualToAttribute:[theGlobalAttributes objectAtIndex:j]])
            {
                valid = NO;
                j = [theGlobalAttributes count];
            }
        }
        if(valid)
        {
        result = [self createNewGlobalAttributeWithName:[[theNewAttributes objectAtIndex:i] attributeName] dataType:[[theNewAttributes objectAtIndex:i] attributeNC_TYPE] values:[[theNewAttributes objectAtIndex:i] getAttributeValueArray]];
        if(!result)
        {
            [existingAttributes addObject:[theNewAttributes objectAtIndex:i]];
            NSLog(@"createNewGlobalAttributeWithArray: failed write");
        }
        }
        else
        [existingAttributes addObject:[theNewAttributes objectAtIndex:i]];
    }
    
    return [NSArray arrayWithArray:[existingAttributes autorelease]];
}

-(BOOL)deleteGlobalAttributeWithName:(NSString *)attName
{
    /*Removes the global attribute with the name attName.  Deleting a global attribute immediately invalidates all dimensions, attributes, and variables held by the handle.*/
    /*Modify netcdf: Global Attributes*/
    int ncid;
    int status;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: deleteGlobalAttributeWithName");
#endif
    ncid = [self ncidWithOpenMode:NC_WRITE status:&status];
    if(status != NC_NOERR)
    {
        return NO;
    }
    else
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"deleteGlobalAttributeWithName" subMethod:@"Open file" errorCode:status];
    }
    nc_redef(ncid);
    
    status = nc_del_att(ncid,NC_GLOBAL,[attName UTF8String]);
    [self closeNCID:ncid];
    if(status==NC_NOERR)
    {
        [self refresh];
        return YES;
    }
    else
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"deleteGlobalAttributeWithName" subMethod:@"delete attribute" errorCode:status];
    return NO;
    }
}

#pragma mark *** Validation Methods ***

-(NSString *)parseNameString:(NSString *)theString
{
    /*This method ensures that a name for creation or renaming of an netcdf object does not contain white spaces.  All white spaces are replaced with "_" values.*/
    /*Validation*/
    
    NSMutableString *mutString;
    NSRange theRange;
    NSScanner *theScanner = [NSScanner scannerWithString:theString];
    NSCharacterSet *theSet = [NSCharacterSet whitespaceCharacterSet];
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: parseNameString");
#endif
    mutString = [NSMutableString stringWithString:theString];
        theRange.length = 1;
    while(![theScanner isAtEnd])
    {
        [theScanner scanUpToCharactersFromSet:theSet intoString:nil];
        theRange.location = [theScanner scanLocation];       
        if(![theScanner isAtEnd])
            [mutString replaceCharactersInRange:theRange withString:@"_"];
    }
    
    return [NSString stringWithString:mutString];
}


#pragma mark *** Variables Methods ***

-(BOOL)createVariableWithName:(NSString *)varName type:(nc_type)theType dimArray:(NSArray *)theVariableDims
{
    /*Creates a new variable within the reciever's file.  Requires a variable name NSString and a netCDF  data type.  It also requires an array of dimensions (NCDFDimensions) in the order of most significant to least significant.*/
    /*Editing netCDF File*/
    int status;
    int *theDimNumbers;
    int i,ncid,varID;
    NSString *theName;
    //open netcdf
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: createVariableWithName");
#endif
    ncid = [self ncidWithOpenMode:NC_WRITE status:&status];

    if(status != NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createVariableWithName" subMethod:@"Open File" errorCode:status];
    
        return NO;
    }
    status = nc_redef(ncid);

    //set up dims
    theDimNumbers = (int *)malloc(sizeof(int)*[theVariableDims count]);
    for(i=0;i<[theVariableDims count];i++)
    {
        theDimNumbers[i] = [[theVariableDims objectAtIndex:i] dimensionID];
    }
    
    //parse variableName
    theName = [self parseNameString:varName];

    status = nc_def_var(ncid,[theName UTF8String],theType,[theVariableDims count],theDimNumbers,&varID);
    free(theDimNumbers);
    if(status != NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createVariableWithName" subMethod:@"Define variable" errorCode:status];
        return NO;
    }
    [self closeNCID:ncid];

    

    [self refresh];

    return YES;
    
}

-(BOOL)createNewVariableWithPropertyList:(NSDictionary *)propertyList
{
    /*This method assumes that the property list is for the current handle.
    transfering this property list between handles requires additional
    work to synchronize dimensions*/
    BOOL result;
    int i;
    NSMutableArray *newDimIDs;
    NSArray *newDimNames;
    NCDFVariable *aVar;
    newDimIDs = [[NSMutableArray alloc] init];
    newDimNames = [propertyList objectForKey:@"dimNames"];

    for(i=0;i<[newDimNames count];i++)
    {
        NCDFDimension *aDim = [self retrieveDimensionByName:[newDimNames objectAtIndex:i]];
            
        [newDimIDs addObject:aDim]; 
    }
    
    i = [[propertyList objectForKey:@"nc_type"] intValue];
    result = [self createVariableWithName:[propertyList objectForKey:@"variableName"]  type:(nc_type)i dimArray:newDimIDs];
    if([propertyList objectForKey:@"data"]!=nil)
    {
        aVar = nil;
        aVar = [self retrieveVariableByName:[propertyList objectForKey:@"variableName"] ];
        
        [aVar writeAllVariableData:[propertyList objectForKey:@"data"]];

    }

    [self refresh];
    [newDimIDs release];
    return result;
}

-(NSArray *)createVariablesWithArray:(NSArray *)theNewVariables importData:(BOOL)importData
{
    int i,j,k;
    NSMutableArray *variablesNotAdded;
    variablesNotAdded = [[NSMutableArray alloc] init];
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: createVariablesWithArray");
#endif
    for(i=0;i<[theNewVariables count];i++)
    {
        NSMutableArray *theNativeDimensionArray = [[NSMutableArray alloc] init];
        //check for valid dims
        for(j=0;j<[[[theNewVariables objectAtIndex:i] variableDimensions] count];j++)
        {
            NCDFDimension *theWorkingDim;
            
            theWorkingDim = [[[theNewVariables objectAtIndex:i] variableDimensions] objectAtIndex:j];
            
            for(k=0;k<[theDimensions count];k++)
            {
                if([theWorkingDim isEqualToDim:[theDimensions objectAtIndex:k]])
                {
                    [theNativeDimensionArray addObject:[theDimensions objectAtIndex:k]];
                    k = [theDimensions count];
                }
            }
        
        }
        if([theNativeDimensionArray count]==[[[theNewVariables objectAtIndex:i] variableDimensions] count])
        {
        [self createVariableWithName:[[theNewVariables objectAtIndex:i] variableName] type:[[theNewVariables objectAtIndex:i]variableNC_TYPE] dimArray:theNativeDimensionArray];
        [theNativeDimensionArray release];
        }
        else
        {
            [variablesNotAdded addObject:[theNewVariables objectAtIndex:i]];
        }
    }
    
    return [NSArray arrayWithArray:[variablesNotAdded autorelease]];
}

-(BOOL)createNewVariableWithName:(NSString *)variableName type:(nc_type)theType dimNameArray:(NSArray *)selectedDims
{
    int i,j,ncid,vid,status;
    int *selectedDimIDs;
    NSMutableArray *theCurrentVars = [self getVariables];
    NSMutableArray *theCurrentDims = [self getDimensions];
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: createNewVariableWithName");
#endif
    //step 1. Parse variable name
    variableName = [self parseNameString:variableName];
    //step 2. check for variable names
    for(i=0;i<[theCurrentVars count];i++)
    {
        if([[[theCurrentVars objectAtIndex:i] variableName] isEqualToString:variableName])
        {
            variableName = [variableName stringByAppendingString:@"_1"];
            i=[theCurrentVars count];
        }
    }
    //step 3. check for dimensions  If dim not present return an error.
    selectedDimIDs = (int *)malloc(sizeof(int)*NC_MAX_VAR_DIMS);//the max prevents nils.
    for(i=0;i<[selectedDims count];i++)
        selectedDimIDs[i] = -1;
    for(i=0;i<[theCurrentDims count];i++)
    {
        for(j=0;j<[selectedDims count];j++)
        {
            if([[[theCurrentDims objectAtIndex:i] dimensionName] isEqualToString:[selectedDims objectAtIndex:j]])
            {
                selectedDimIDs[j] = [[theCurrentDims objectAtIndex:i] dimensionID];
            }

                
        }
        
    }
    if(selectedDimIDs[[selectedDims count]-1]==-1)
    {
        NSLog(@"Missing dim");
        return NO;
    }
    //step 4.  I think we have everything, let's create.
    
    ncid = [self ncidWithOpenMode:NC_WRITE status:&status];
    
    if(status != NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewVariableWithName" subMethod:@"Open File" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);
    if(status != NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewVariableWithName" subMethod:@"Redefine Mode" errorCode:status];
        return NO;
    }
    status = nc_def_var(ncid,[variableName UTF8String],theType,[selectedDims count],selectedDimIDs,&vid);
    free(selectedDimIDs);
    if(status != NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"createNewVariableWithName" subMethod:@"Variable write" errorCode:status];
        return NO;
    }
	[self closeNCID:ncid];
    [self refresh];
    
    return YES;
}

-(BOOL)deleteVariableWithName:(NSString *)deleteVariableName
{
    NSFileManager *theManager = [NSFileManager defaultManager];
    NCDFHandle *newHandle;
    NSString *tempPath = [filePath stringByAppendingString:@"_.nc"];

    int i, errorCount;
    
    errorCount = [theErrorHandle errorCount];
    while([theManager fileExistsAtPath:tempPath])
    {
        tempPath = [tempPath stringByAppendingString:@"_.nc"];
    }
    newHandle = [[NCDFHandle alloc] initByCreatingFileAtPath:tempPath];
    
    for(i=0;i<[theGlobalAttributes count];i++)
    {
        [newHandle createNewGlobalAttributeWithPropertyList:[[theGlobalAttributes objectAtIndex:i] propertyList]];
    }
    
    for(i=0;i<[theDimensions count];i++)
    {
        
        [newHandle createNewDimensionWithPropertyList:[[theDimensions objectAtIndex:i] propertyList]];
    }
    
    for(i=0;i<[theVariables count];i++)
    {
        if(![[[theVariables objectAtIndex:i] variableName] isEqualToString:deleteVariableName])
        {
        [newHandle createNewVariableWithPropertyList:[[theVariables objectAtIndex:i] propertyList]];
        }
    }
    
    if(errorCount<[theErrorHandle errorCount])
    {
        [theManager removeItemAtPath:tempPath error:nil];
        [newHandle release];
        return NO;
    }
    else
    {
        [theManager removeItemAtPath:filePath error:nil];
		[theManager moveItemAtPath:tempPath toPath:filePath error:nil];
        [self refresh];
        [newHandle release];
        return YES;
    }
}

-(BOOL)deleteVariablesWithNames:(NSArray *)nameArray
{
    NSFileManager *theManager = [NSFileManager defaultManager];
    NCDFHandle *newHandle;
    NSString *tempPath = [filePath stringByAppendingString:@"_.nc"];

    int i, errorCount,j;
    //NSLog(@"deleteVariablesWithNames");
    errorCount = [theErrorHandle errorCount];
    while([theManager fileExistsAtPath:tempPath])
    {
        tempPath = [tempPath stringByAppendingString:@"_.nc"];
    }
    newHandle = [[NCDFHandle alloc] initByCreatingFileAtPath:tempPath];
    //NSLog(@"theGlobalAttributes");
    for(i=0;i<[theGlobalAttributes count];i++)
    {
        [newHandle createNewGlobalAttributeWithPropertyList:[[theGlobalAttributes objectAtIndex:i] propertyList]];
    }
    //NSLog(@"theDimensions");
    for(i=0;i<[theDimensions count];i++)
    {
        
        [newHandle createNewDimensionWithPropertyList:[[theDimensions objectAtIndex:i] propertyList]];
    }
    //NSLog(@"theVariables");
    for(i=0;i<[theVariables count];i++)
    {
        BOOL Valid;
        //if(theVariables!=nil)
        //    NSLog(@"have variables");
        //if(nameArray!=nil)
         //   NSLog(@"have name array");
        Valid = YES;
        for(j=0;j<[nameArray count];j++)
        {
            if([[[theVariables objectAtIndex:i] variableName] isEqualToString:[nameArray objectAtIndex:j]])
                Valid = NO;
        }
        //NSLog(@"checking valid");
        if(Valid)
        {
            //NSLog(@"creating");
            NSDictionary *aTempDict = [[[theVariables objectAtIndex:i] propertyList] retain];
            //NSLog(@"creating 1");
            [newHandle refresh];
            //NSLog(@"creating 2");
            [newHandle createNewVariableWithPropertyList:aTempDict];
            //NSLog(@"creating 3");
            [aTempDict release];
            //NSLog(@"end creating");
        }
        //NSLog(@"%i of %i",i,[theVariables count]);
    }
    //NSLog(@"errorCount");
    if(errorCount<[theErrorHandle errorCount])
    {
        [theManager removeItemAtPath:tempPath error:nil];
        [newHandle release];
        return NO;
    }
    else
    {
        [theManager removeItemAtPath:filePath error:nil];
		[theManager moveItemAtPath:tempPath toPath:filePath error:nil];
        [self refresh];
        [newHandle release];
        return YES;
    }
}

#pragma mark *** Presently Unclassified Methods ***

-(NCDFVariable *)retrieveVariableByName:(NSString *)aName
{
    int i;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: retrieveVariableByName");
#endif
    for(i=0;i<[theVariables count];i++)
    {
        if([[[theVariables objectAtIndex:i] variableName] isEqualToString:aName])
            return [theVariables objectAtIndex:i];
    }
    return nil;
}

-(NCDFDimension *)retrieveDimensionByName:(NSString *)aName
{
    int i;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: retrieveDimensionByName");
#endif
    for(i=0;i<[theDimensions count];i++)
    {
        if([[[theDimensions objectAtIndex:i] dimensionName] isEqualToString:aName])
            return [theDimensions objectAtIndex:i];
    }
    return nil;

}

-(NCDFAttribute *)retrieveGlobalAttributeByName:(NSString *)aName
{
    int i;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: retrieveDimensionByName");
#endif
    for(i=0;i<[theGlobalAttributes count];i++)
    {
        if([[[theGlobalAttributes objectAtIndex:i] attributeName] isEqualToString:aName])
            return [theGlobalAttributes objectAtIndex:i];
    }
    return nil;
	
}

-(NCDFDimension *)retrieveUnlimitedDimension
{
    int i;
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: retrieveUnlimitedDimension");
#endif
    for(i=0;i<[theDimensions count];i++)
    {
        if([[theDimensions objectAtIndex:i] isUnlimited] )
            return [theDimensions objectAtIndex:i];
    }
    return nil;

}

-(NCDFVariable *)retrieveUnlimitedVariable
{
    int i;
    NSString *nameOfUnlimited = [[self retrieveUnlimitedDimension] dimensionName];
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: retrieveUnlimitedVariable");
#endif
    for(i=0;i<[theVariables count];i++)
    {
        if([[[theVariables objectAtIndex:i] variableName] isEqualToString:nameOfUnlimited])
            return [theVariables objectAtIndex:i];
    }
    return nil;
}

-(NCDFDimension *)retrieveDimensionByIndex:(int)index
{
    return [theDimensions objectAtIndex:index];
}

-(BOOL)extendUnlimitedVariableBy:(int)units
{
    BOOL result;
    size_t dimLength;
    int dataSize,i;
    NSMutableArray *startCoords;
    NSMutableArray *endCoords;
    NSArray *varDimIDs;
    NSData *emptyObject;
    NCDFVariable *aVar = [self retrieveUnlimitedVariable];
#ifdef DEBUG_NCDFHandle
    NSLog(@"NCDFHandle: extendUnlimitedVariableBy");
#endif
    dimLength = [[self retrieveUnlimitedDimension] dimLength];
    varDimIDs = [aVar variableDimensions];
    //set start coords
    startCoords = [[NSMutableArray alloc] init];
    dataSize = 1 * units;
    for(i=0;i<[varDimIDs count];i++)
    {
        if(i==0)
            [startCoords addObject:[NSNumber numberWithInt:dimLength]];
        else
            [startCoords addObject:[NSNumber numberWithInt:0]];
    }
    //end coords
    endCoords = [[NSMutableArray alloc] init];
    for(i=0;i<[varDimIDs count];i++)
    {
        if(i==0)
            [endCoords addObject:[NSNumber numberWithInt:(units)]];
        else
        {
            [endCoords addObject:[NSNumber numberWithInt:[[self retrieveDimensionByIndex:[[varDimIDs objectAtIndex:i] intValue]] dimLength]]];
            
        }
    }
    dataSize *= [aVar sizeUnitVariableForType];
    emptyObject = [NSData dataWithData:[NSMutableData dataWithLength:dataSize]];
    
    result  = [aVar writeValueArrayAtLocation:startCoords edgeLengths:endCoords withValue:emptyObject];
    [self refresh];
    if(!result)
        NSLog(@"extendUnlimitedVariableBy failed");
    else
        NSLog(@"extendUnlimitedVariableBy okay");
    return result;
}

-(NSString *)htmlDescription
{
	/*
	 theVariables;
	 NSMutableArray *theGlobalAttributes;
	 NSMutableArray *theDimensions
	 */
	NSMutableString *theString = [[[NSMutableString alloc] init] autorelease];
	//Step 1. Header
	[theString appendString:@"<html>\n"];
	[theString appendString:@"<head>\n"];
	[theString appendFormat:@"<title>NetCDF File Description: %@</title>\n",[[self theFilePath] lastPathComponent]];
	[theString appendString:@"</head>\n"];
	[theString appendString:@"<body>\n"];
	
	[theString appendFormat:@"<center><H1>NetCDF File Description: %@</H1></center>\n<BR>",[[self theFilePath] lastPathComponent]];
	
	//create quick links for each value
	[theString appendString:@"Quicklinks:<P>\n"];
	[theString appendString:@"\n<table width=\"600\" border=\"1\" cellspacing=\"0\" cellpadding=\"0\">\n"];
	
	[theString appendString:@"<tr>\n"];
	[theString appendString:@"<td width=\"200\">"];
	[theString appendString:@"Global Attributes:<BR>"];
	[theString appendString:@"</td>"];
	[theString appendString:@"<td width=\"200\">"];
	[theString appendString:@"Dimensions:<BR>\n"];
	[theString appendString:@"</td>"];
	[theString appendString:@"<td width=\"200\">"];
	[theString appendString:@"Variables:<BR>\n"];
	[theString appendString:@"</td>"];
	[theString appendString:@"</tr>\n"];
	
	[theString appendString:@"<tr>\n"];
	
	[theString appendString:@"<td valign=\"top\" width=\"200\">"];
	if([theGlobalAttributes count] >0)
	{
		NSEnumerator *anEnum = [theGlobalAttributes objectEnumerator];
		NCDFAttribute *anAtt;
		while(anAtt = [anEnum nextObject])
		{
			[theString appendFormat:@"<a href=\"#gatt-%@\">%@</a><BR>\n",[anAtt attributeName],[anAtt attributeName]];
		}
	}
	[theString appendString:@"<P>"];
	[theString appendString:@"</td>"];
	
	[theString appendString:@"<td valign=\"top\" width=\"200\">"];
	if([theDimensions count] >0)
	{
		NSEnumerator *anEnum = [theDimensions objectEnumerator];
		NCDFDimension *aDim;
		while(aDim = [anEnum nextObject])
		{
			[theString appendFormat:@"<a href=\"#dim-%@\">%@</a><BR>\n",[aDim dimensionName],[aDim dimensionName]];
		}
	}
	[theString appendString:@"<P>"];
	[theString appendString:@"</td>"];
	
	[theString appendString:@"<td valign=\"top\" width=\"200\">"];
	if([theVariables count] >0)
	{
		NSEnumerator *anEnum = [theVariables objectEnumerator];
		NCDFVariable *aVar;
		while(aVar = [anEnum nextObject])
		{
			[theString appendFormat:@"<a href=\"#var-%@\">%@</a><BR>\n",[aVar variableName],[aVar variableName]];
		}
	}
	[theString appendString:@"</td>"];
	[theString appendString:@"</tr>\n"];
	[theString appendString:@"</table>\n"];
	[theString appendString:@"<P>"];
	
	[theString appendString:@"<hr>"];
	
	//at this point, I'm ready to build all technical information for the document.
	
	
	//part 1. attributes.  Attributes don't self-generate HTML.  This is becuase they're likely to be in a table.  
	//in this case, 1 table per attribute.
	
	
	//[theString appendString:@"\n<table width=\"500\" border=\"1\" cellspacing=\"0\" cellpadding=\"0\">\n"];
	
	if([theGlobalAttributes count] >0)
	{
		[theString appendString:@"<H2> Global Attributes:<H2><BR>\n"];
		NSEnumerator *anEnum = [theGlobalAttributes objectEnumerator];
		NCDFAttribute *anAtt;
		while(anAtt = [anEnum nextObject])
		{
			[theString appendString:@"\n<table width=\"600\" border=\"1\" cellspacing=\"3\" cellpadding=\"0\">\n"];
			[theString appendString:@"<tr>\n"];
			[theString appendString:@"<td valign=\"top\" width=\"200\">\n"];
			[theString appendFormat:@"<a name=\"gatt-%@\"></a>%@\n",[anAtt attributeName],[anAtt attributeName]];
			[theString appendString:@"</td>\n"];
			[theString appendString:@"<td valign=\"top\" >\n"];
			[theString appendFormat:@"%@",[anAtt contentDescription]];
			[theString appendString:@"</td>\n"];
			[theString appendString:@"</table>"];
		}
	}
	
	//part 2. dims.  make individual tables like the atts.
	if([theDimensions count] >0)
	{
		[theString appendString:@"<H2>Dimensions:<H2><BR>\n"];
		NSEnumerator *anEnum = [theDimensions objectEnumerator];
		NCDFDimension *aDim;
		while(aDim = [anEnum nextObject])
		{
			[theString appendString:@"\n<table width=\"600\" border=\"1\" cellspacing=\"3\" cellpadding=\"0\">\n"];
			[theString appendString:@"<tr>\n"];
			[theString appendString:@"<td  valign=\"top\" width=\"200\">\n"];
			[theString appendFormat:@"<a name=\"dim-%@\"></a>%@\n",[aDim dimensionName],[aDim dimensionName]];
			[theString appendString:@"</td>\n"];
			[theString appendString:@"<td valign=\"top\" >\n"];
			[theString appendFormat:@"%i",[aDim dimLength]];
			[theString appendString:@"</td>\n"];
			[theString appendString:@"</table>"];
		}
	}
	
	//part 2. dims.  make individual tables like the atts.
	if([theVariables count] >0)
	{
		[theString appendString:@"<H2>Variables:<H2><BR>\n"];
		NSEnumerator *anEnum = [theVariables objectEnumerator];
		NCDFVariable *aVar;
		while(aVar = [anEnum nextObject])
		{
			[theString appendString:[aVar htmlDescription]];
		}
	}
	[theString appendString:@"</body>\n"];
	[theString appendString:@"</html>\n"];
	return [NSString stringWithString:theString];
}


-(NSComparisonResult)compareUnlimitedValue:(id)object
{
	if(!_theCompareValue)
		[self createCompareValue];
	
	NSComparisonResult result = [_theCompareValue compare:[object compareValue]];
	
	return result;
}


-(NSNumber *)compareValue
{
	if(!_theCompareValue)
		[self createCompareValue];
	return _theCompareValue;
}

-(void)createCompareValue
{
\
	if(!_theCompareValue)
	{
		NCDFVariable *theVar = [self retrieveUnlimitedVariable];
		if(theVar)
		{
			_theCompareValue = [[theVar getSingleValue:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]] retain];
			if(!_theCompareValue)
				_theCompareValue = [[NSNumber numberWithFloat:NAN] retain];
		}
		else
		{
			_theCompareValue = [[NSNumber numberWithFloat:NAN] retain];
		}
	}
	\
}

-(int)ncidForReadOnly
{
	int ncid;
	int status;
	[fileDatabaseLock lock];
	status = nc_open([filePath cStringUsingEncoding:NSUTF8StringEncoding],NC_NOWRITE,&ncid);
	[fileDatabaseLock unlock];
	if(status != NC_NOERR)
	{
		[theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"ncidForReadOnly" subMethod:@"Opening netCDF file" errorCode:status];
		return -1;
	}

	return ncid;
	

}

-(int)ncidWithOpenMode:(int)openMode status:(int *)status
{
	int ncid;
	//char *theCPath = (char *)calloc([filePath length]+1,sizeof(char));
	[fileDatabaseLock lock];
	
	if(openMode	== NC_WRITE)
		openMode = NC_WRITE|NC_SHARE;
	else if(openMode == NC_NOWRITE)
		openMode = NC_SHARE;
	
	*status = nc_open([filePath cStringUsingEncoding:NSUTF8StringEncoding],openMode,&ncid);
	[fileDatabaseLock unlock];
	
	return ncid;
	
	/*NSLog(@"%s %i",__FUNCTION__,__LINE__);
	
	if((_NCDFNcidHoldCount>0)&&(_NCDFNcid>0))
	{
		//here we have an open and valid file.
		_NCDFNcidHoldCount++;
		NSLog(@"%s %i",__FUNCTION__,__LINE__);
	}
	else {
		//here we need to open a file.
		NSLog(@"%s %i",__FUNCTION__,__LINE__);
		int ncid;
		char *theCPath = (char *)malloc(sizeof(char)*[filePath length]+1);
		[filePath getCString:theCPath maxLength:[filePath length]+1 encoding:NSUTF8StringEncoding];
		[fileDatabaseLock lock];
		
		if(openMode	== NC_WRITE)
			openMode = NC_WRITE|NC_SHARE;
		else if(openMode == NC_NOWRITE)
			openMode = NC_SHARE;
		
		*status = nc_open(theCPath,openMode,&ncid);
		[fileDatabaseLock unlock];
		free(theCPath);
		if(ncid>0)
		{
			_NCDFNcid = ncid;
			_NCDFNcidHoldCount++;
		}
		else {
			_NCDFNcid = 0;
		}
		NSLog(@"%s %i id %i",__FUNCTION__,__LINE__,_NCDFNcid);
		NSLog(@"%s %i hold %i",__FUNCTION__,__LINE__,_NCDFNcidHoldCount);
			
	}

	
	
	NSLog(@"%s %i id %i",__FUNCTION__,__LINE__,_NCDFNcid);
	return _NCDFNcid;*/
	
}

-(void)closeNCID:(int)ncid
{
	int status;
	[fileDatabaseLock lock];
	status = nc_close(ncid);
	[fileDatabaseLock unlock];
	if(status != NC_NOERR)
	{
		[theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"closeNCID" subMethod:@"Closing netCDF file" errorCode:status];
	}
	/*
	if(_NCDFNcid==ncid)
	{
		_NCDFNcidHoldCount -= 1;
		if(_NCDFNcidHoldCount == 0)
		{
			int status;
			[fileDatabaseLock lock];
			status = nc_close(ncid);
			[fileDatabaseLock unlock];
			if(status != NC_NOERR)
			{
				[theErrorHandle addErrorFromSource:filePath className:@"NCDFHandle" methodName:@"closeNCID" subMethod:@"Closing netCDF file" errorCode:status];
			}
			_NCDFNcid = 0;
		}

	}
	
	*/

}


@end


