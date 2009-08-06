//
//  NCDFVariable.m
//  netcdf
//
//  Created by tmoore on Wed Feb 13 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

#import "NCDFNetCDF.h"

#ifndef NOEXCEPTIONHANDLE
#ifndef GUI_EXCEPTION
#define NOGUI_EXCEPTION
#endif
#endif
@implementation NCDFVariable

-(id)initWithPath:(NSString *)thePath variableName:(NSString *)theName variableID:(int)theID type:(nc_type)theType theDims:(NSArray *)theDims attributeCount:(int)nAtt handle:(NCDFHandle *)handle
{
    /*This method initializes a variable from a file.  The values are seeded typically by the NCDFHandle.  This method should not be called except from NCDFHandle's initialization methods.*/
    /*Initialization*/
    /*Validated*/
    
    [super init];
    fileName = [thePath copy];
    variableName = [theName copy];
    varID = theID;
    dataType = theType;
    dimIDs = [theDims copy];
    numberOfAttributes = nAtt;
    theHandle = handle;
    return self;
}

-(void)dealloc
{
    /*Dealloc the reciever.*/
    /*Deallocation*/
    if(fileName)
        [fileName release];
    if(variableName)
        [variableName release];
    if(dimIDs)
        [dimIDs release];
    if(attributes)
        [attributes release];
    [super dealloc];
}

-(void)finalize
{
	[super finalize];
}

-(NSLock *)handleLock
{
	return [theHandle handleLock];
}
-(NSString *)variableName
{
    /*Returns the reciever's variable name.*/
    /*Accessor*/
    /*Validated*/
    return variableName;
}

-(NSData *)readAllVariableData
{
    /*Returns a NSData object containing all the variable data.  The data will be in order of netcdf dimensional order.  Before using the NSData object, it is important to ensure that the data type is known in order to access the values.*/
    /*Accessor*/
    /*Validated Types:
        */
    int i;
    NSArray *theDims;
    
    size_t total_values;
    int ncid,result;
    NSData *theData;
/*#ifndef NOEXCEPTIONHANDLE
    NS_DURING  //Exception Handling
#endif*/
    theData = nil;
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    theDims = [theHandle getDimensions];
    total_values = 1;
    for(i=0;i<[dimIDs count];i++)
    {
        total_values *= [[theDims objectAtIndex:[[dimIDs objectAtIndex:i] intValue]] dimLength];
    }
    //theCPath = (char *)malloc(sizeof(char)*[fileName length]+1);
    //[fileName getCString:theCPath];
    result = nc_open([fileName cString],NC_NOWRITE,&ncid);
    //free(theCPath);
    if(result!=NC_NOERR)
    {
       [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"readAllVariableData" subMethod:@"Open netCDF failed" errorCode:result];
       return nil;
    }
    switch(dataType)
    {
        case NC_BYTE:
        {
            char *theText;
            theText = (char *)malloc(sizeof(char)*total_values);
            result = nc_get_var_text(ncid,varID,theText);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"readAllVariableData" subMethod:@"Read NC_Byte" errorCode:result];
                return nil;
            }
            theData = [[NSData dataWithBytes:theText length:total_values] retain];
            free(theText);
            break;
        }
        case NC_CHAR:
        {
            char *theText;
            theText = (char *)malloc(sizeof(char)*total_values+1);
            result = nc_get_var_text(ncid,varID,theText);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"readAllVariableData" subMethod:@"Read NC_Char" errorCode:result];
                return nil;
            }
            theData = [[NSData dataWithBytes:theText length:total_values+1] retain];
            free(theText);
            break;
        }
        case NC_SHORT:
        {
            short *array;
            array = (short *)malloc(sizeof(short)*total_values);
            result = nc_get_var_short(ncid,varID,array);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"readAllVariableData" subMethod:@"Read NC_Short" errorCode:result];
                return nil;
            }
            theData = [[NSData dataWithBytes:array length:(sizeof(short)*total_values)] retain];
            free(array);
            break;
        }
        case NC_INT:
        {
            int *array;
            array = (int *)malloc(sizeof(int)*total_values);
            result = nc_get_var_int(ncid,varID,array);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"readAllVariableData" subMethod:@"Read NC_Int" errorCode:result];
                return nil;
            }
            theData = [[NSData dataWithBytes:array length:(sizeof(int)*total_values)] retain];
            free(array);
            break;
        }
        case NC_FLOAT:
        {
            float *array;
            array = (float *)malloc(sizeof(float)*total_values);
            //NSLog(@"total values %i",total_values);
            result = nc_get_var_float(ncid,varID,array);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"readAllVariableData" subMethod:@"Read NC_Float" errorCode:result];
                return nil;
            }
            theData = [[NSData dataWithBytes:array length:(sizeof(float)*total_values)] retain];
            free(array);
            break;
        }
        case NC_DOUBLE:
        {
            double *array;
            array = (double *)malloc(sizeof(double)*total_values);
            result = nc_get_var_double(ncid,varID,array);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"readAllVariableData" subMethod:@"Read NC_Double" errorCode:result];
                return nil;
            }

            theData = [[NSData dataWithBytes:array length:(sizeof(double)*total_values)] retain];
            free(array);
            break;
        }
        case NC_NAT:
        {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"readAllVariableData" subMethod:@"NC_Nat not handled" errorCode:result];
                return nil;
            }
    }
    nc_close(ncid);
    //NSLog(@"Variable Retain count: %i",[theData retainCount]);
    return [theData autorelease];
}

-(NSString *)variableType
{
    /*Returns a NSString object with string representation of the data type.  This method is intended for use with NSLogs and GUI information.*/
    /*Accessor*/
    /*Validated For:
        BYTE = NO
        CHAR = YES
        SHORT = YES
        INT = YES
        FLOAT = YES
        DOUBLE = YES
        */
    switch(dataType)
    {
        case NC_BYTE:
        {
            return [NSString stringWithString:@"NC_BYTE"];
            break;
        }
        case NC_CHAR:
        {
            return [NSString stringWithString:@"NC_CHAR"];
            break;
        }
        case NC_SHORT:
        {
            return [NSString stringWithString:@"NC_SHORT"];
            break;
        }
        case NC_INT:
        {
            return [NSString stringWithString:@"NC_INT"];
            break;
        }
        case NC_FLOAT:
        {
            return [NSString stringWithString:@"NC_FLOAT"];
            break;
        }
        case NC_DOUBLE:
        {
            return [NSString stringWithString:@"NC_DOUBLE"];
            break;
        }
        case NC_NAT:
        {
            return [NSString stringWithString:@"NC_NAT"];
            break;
        }
    }
    return [NSString stringWithString:@"Not Valid"];
}

-(void)writeAllVariableData:(NSData *)dataForWriting
{
    /*Writes a complete set of data for a variable.  Be sure the data is of the correct size and shape.  For unlimited cases, ensure the data is the correct size and shape for the larger shape.*/
    /*Accessor*/
    /*Validated For:
        BYTE = NO
        CHAR = NO
        SHORT = NO
        INT = NO
        FLOAT = NO
        DOUBLE = NO
        */
    int i;
    NSArray *theDims;
 
    size_t total_values;
    int ncid,result;
    BOOL usesUnlimitedDim;
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    theDims = [theHandle getDimensions];
    total_values = 1;
    usesUnlimitedDim = NO;
    for(i=0;i<[dimIDs count];i++)
    {
        
        if([[theDims objectAtIndex:[[dimIDs objectAtIndex:i] intValue]] isUnlimited])
        {
            usesUnlimitedDim = YES;
        }
        else
        total_values *= [[theDims objectAtIndex:[[dimIDs objectAtIndex:i] intValue]] dimLength];
    }
   
    result = nc_open([fileName cString],NC_WRITE,&ncid);
    
    
    if(result!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeAllVariableData" subMethod:@"Open file failed" errorCode:result];
        return;
    }
    switch(dataType)
    {
        case NC_BYTE:
        {
             char *theText;
            //NSLog(@"byte");
            if(usesUnlimitedDim==YES)
            	total_values = [dataForWriting length];
            
            theText = ( char *)malloc(sizeof( char)*total_values);
            [dataForWriting getBytes:theText];
            result = nc_put_var_text(ncid,varID,theText);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeAllVariableData" subMethod:@"Write NC_Byte" errorCode:result];
                return;
            }            
            free(theText);
            break;
        }
        case NC_CHAR:
        {
            char *theText;
            //NSLog(@"char");
            if(usesUnlimitedDim==YES)
            	total_values = [dataForWriting length];
            theText = (char *)malloc(sizeof(char)*total_values+1);
            [dataForWriting getBytes:theText];
            result = nc_put_var_text(ncid,varID,theText);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeAllVariableData" subMethod:@"Write NC_Char" errorCode:result];
                return ;
            }
            free(theText);
            break;
        }
        case NC_SHORT:
        {
            short *array;
            //NSLog(@"short");
            if(usesUnlimitedDim==YES)
            	total_values = [dataForWriting length]/2;
            array = (short *)malloc(sizeof(short)*total_values);
            [dataForWriting getBytes:array];
            result = nc_put_var_short(ncid,varID,array);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeAllVariableData" subMethod:@"Write NC_Short" errorCode:result];
                return ;
            }
            free(array);
            break;
        }
        case NC_INT:
        {
            int *array;
            //NSLog(@"int");
            if(usesUnlimitedDim==YES)
            	total_values = [dataForWriting length]/4;
            array = (int *)malloc(sizeof(int)*total_values);
            [dataForWriting getBytes:array];
            result = nc_put_var_int(ncid,varID,array);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeAllVariableData" subMethod:@"Write NC_INT" errorCode:result];
                return ;
            }
            
            free(array);
            break;
        }
        case NC_FLOAT:
        {
            float *array;
            //NSLog(@"float");
            if(usesUnlimitedDim==YES)
            	total_values = [dataForWriting length]/4;
            //NSLog(@"Total values %i",total_values);
            array = (float *)malloc(sizeof(float)*total_values);
            //NSLog(@"size %i %i",(sizeof(float)*total_values),[dataForWriting length]);
            [dataForWriting getBytes:array];
            //NSLog(@"data field");
            result = nc_put_var_float(ncid,varID,array);
            //NSLog(@"put var field");
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeAllVariableData" subMethod:@"Write NC_FLOAT" errorCode:result];
                return ;
            }
            //NSLog(@"free field");
            free(array);
            break;
        }
        case NC_DOUBLE:
        {
            double *array;
        
            if(usesUnlimitedDim==YES)
            	total_values = [dataForWriting length]/8;
            array = (double *)malloc(sizeof(double)*total_values);
            [dataForWriting getBytes:array];
            result = nc_put_var_double(ncid,varID,array);
            if(result!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeAllVariableData" subMethod:@"Write NC_Double" errorCode:result];
                return ;
            }
            free(array);
            break;
        }
        case NC_NAT:
        {
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeAllVariableData" subMethod:@"Write NC_NAT" errorCode:result];
                return ;
            }
        }
    }
    //NSLog(@"end");
    nc_close(ncid);
}

-(BOOL)createNewVariableAttributeWithName:(NSString *)attName dataType:(nc_type)theType values:(NSArray *)theValues
{
    /*Creates a new attribute for the variable in the current netcdf file.  If the nc_type is a nc_char, then use only one NSString in theValues, same for NC_BYTE data.  Otherwise, all objects should be NSNumbers.*/
    /*Accessor: Attributes*/
    /*Validated For:
        BYTE = NO
        CHAR = YES
        SHORT = NO
        INT = NO
        FLOAT = NO
        DOUBLE = NO
        */
    int ncid;
    int status;
   
    BOOL dataWritten;
    
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
	
    
    status = nc_open([fileName cString],NC_WRITE,&ncid);
   

    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"createNewVariableAttributeWithName" subMethod:@"Open file" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);

    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"createNewVariableAttributeWithName" subMethod:@"Open file" errorCode:status];
        nc_close(ncid);
        return NO;
    }
	
    dataWritten = NO;
    switch (theType){
        case NC_BYTE:
        {
            unsigned char *theText;
            //assumes object is an NSData object
            theText = (unsigned char *)malloc(sizeof(unsigned char)*[(NSData *)[theValues objectAtIndex:0]length]);
            [[theValues objectAtIndex:0] getBytes:theText];
            status = nc_put_att_uchar (ncid,varID,[attName cString],theType,[(NSData *)[theValues objectAtIndex:0]length],theText);
            free(theText);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"createNewVariableAttributeWithName" subMethod:@"Write NC_Byte" errorCode:status];
            }
            else
                dataWritten = YES;
            break;
        }
        case NC_CHAR:
        {
            //now assuming that the object at index is a NSData object
	
            status = nc_put_att_text (ncid,varID,[attName cString],[(NSString *)[theValues objectAtIndex:0]length],[[theValues objectAtIndex:0] cString]);
     
			if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"createNewVariableAttributeWithName" subMethod:@"Write NC_CHAR" errorCode:status];
            }
            else
                dataWritten = YES;

            break;
        }
        case NC_SHORT:
        {
            int i;
            short *array;
            array = (short *)malloc(sizeof(short)*[theValues count]);
            for(i=0;i<[theValues count];i++)
                array[i] = [[theValues objectAtIndex:i] shortValue];
            status = nc_put_att_short (ncid,varID,[attName cString],theType,(size_t)[theValues count],array);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"createNewVariableAttributeWithName" subMethod:@"Write NC_SHORT" errorCode:status];
            }
            else
                dataWritten = YES;
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
            status = nc_put_att_int (ncid,varID,[attName cString],theType,(size_t)[theValues count],array);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"createNewVariableAttributeWithName" subMethod:@"Write NC_INT" errorCode:status];
            }
            else
                dataWritten = YES;
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
            status = nc_put_att_float(ncid,varID,[attName cString],theType,(size_t)[theValues count],array);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"createNewVariableAttributeWithName" subMethod:@"Write NC_FLOAT" errorCode:status];
            }
            else
                dataWritten = YES;
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
            status = nc_put_att_double(ncid,varID,[attName cString],theType,(size_t)[theValues count],array);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"createNewVariableAttributeWithName" subMethod:@"Write NC_DOUBLE" errorCode:status];
            }
            else
                dataWritten = YES;
            free(array);
            break;
        }
        case NC_NAT:
        {
            [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"createNewVariableAttributeWithName" subMethod:@"Write NC_NAT" errorCode:status];
        }
    }

    nc_close(ncid);
    if(!dataWritten)
        return NO;

    [theHandle refresh];
    numberOfAttributes++;
    return YES;


}

-(BOOL)createNewVariableAttributePropertyList:(NSDictionary *)propertyList
{
    if([self createNewVariableAttributeWithName:[propertyList objectForKey:@"attributeName"] dataType:[[propertyList objectForKey:@"nc_type"] intValue] values:[propertyList objectForKey:@"values"]])
    {
		[theHandle refresh];
		return YES;
	}
    else
        return NO;
}


-(NSArray *)getVariableAttributes
{
    /*Returns an array containing all the attributes for the variable.  This method should not be called on from any variable that is not attached to a NCDFHandle.*/
    /*Accessor: Attributes*/
    
    int i;
    int ncid;
    int status;
    NSMutableArray *theAttArray;
    NSArray *theFinal;
    
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    status = nc_open([fileName cString],NC_NOWRITE,&ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getVariableAttributes" subMethod:@"Open file" errorCode:status];
        return nil;
    }
    theAttArray = [[NSMutableArray alloc] init];
    for(i=0;i<numberOfAttributes;i++)
    {
        char name[NC_MAX_NAME];
        nc_type attributeType;
        size_t length;
        NCDFAttribute *theAtt;
        status = nc_inq_attname(ncid, varID,i, name);
        
        if(status!=NC_NOERR)
        {
            [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getVariableAttributes" subMethod:@"nc_inq_attname" errorCode:status];
        }
        
        status = nc_inq_att ( ncid, varID, name,
&attributeType, &length);
        if(status!=NC_NOERR)
        {
            [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getVariableAttributes" subMethod:@"nc_inq_att" errorCode:status];
        }
        
        theAtt = [[NCDFAttribute alloc] initWithPath:fileName name:[NSString stringWithCString:name] variableID:varID length:length type:attributeType handle:theHandle];
        [theAttArray addObject:theAtt];
        [theAtt release];
        
    }
    theFinal = [[NSArray arrayWithArray:theAttArray] retain];
    [theAttArray autorelease];
    nc_close(ncid);
    return [theFinal autorelease];
}

-(BOOL)deleteVariableAttributeByName:(NSString *)name
{
    /*Deletes the reciever's attribute of name.*/
    /*Edit: Attributes*/
    int ncid;
    int status;
    
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    status = nc_open([fileName cString],NC_WRITE,&ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"deleteVariableAttributeByName" subMethod:@"Open file" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"deleteVariableAttributeByName" subMethod:@"nc_redef" errorCode:status];
        nc_close(ncid);
        return NO;
    }
    status = nc_del_att(ncid,varID,[name cString]);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"deleteVariableAttributeByName" subMethod:@"nc_del_att" errorCode:status];
        nc_close(ncid);
        return NO;
    }
    nc_close(ncid);
	[theHandle refresh];
    numberOfAttributes--;
    return YES;
}

-(NSArray *)variableDimensions
{
    /*Returns an array of the reciever's dimention numbers.*/
    /*Accessors: Variable Dimensions*/
    return dimIDs;
}


-(NSString *)variableDimDescription
{
    NSArray *theWorkingDims;
    NSString *theString;
    int i;
    theWorkingDims = [theHandle getDimensions];
    theString = [NSString stringWithString:@"["];
    for(i=0;i<[dimIDs count];i++)
    {
        theString = [theString stringByAppendingString:[[theWorkingDims objectAtIndex:[[dimIDs objectAtIndex:i] intValue]] dimensionName]];
        if(i+1<[dimIDs count])
            theString = [theString stringByAppendingString:@","];
    }
    theString = [theString stringByAppendingString:@"]"];
    [theString retain];
    return [theString autorelease];
}

-(NSString *)dataTypeWithDimDescription
{
    NSString *aString;
    aString = [[NSString stringWithFormat:@"%@ %@",[self variableType],[self variableDimDescription]] retain];
    return [aString autorelease];
}

-(nc_type)variableNC_TYPE
{
    /*Returns an array of the reciever's data type.*/
    /*Accessors: Data Type*/
    return dataType;
}

-(BOOL)renameVariable:(NSString *)newName
{
    /*Changes the name of the variable.*/
    /*Edit: Variable Information*/
    int status;
    int ncid;
    
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    newName = [self parseNameString:newName];
    status = nc_open([fileName cString],NC_WRITE,&ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"renameVariable" subMethod:@"Open file" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"renameVariable" subMethod:@"nc_redef" errorCode:status];
        nc_close(ncid);
        return NO;
    }
    status = nc_rename_var(ncid,varID,[newName cString]);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"renameVariable" subMethod:@"nc_rename_var" errorCode:status];
        nc_close(ncid);
        return NO;
    }
    nc_close(ncid);
	[theHandle refresh];
    return YES;
    
}

-(NSString *)parseNameString:(NSString *)theString
{
    /*Returns a copy of theString without whitespaces.  Whitespaces are replaced by "_"*/
    /*Parsers*/
    NSString *newString;
    NSMutableString *mutString;
    NSRange theRange;
    NSScanner *theScanner = [NSScanner scannerWithString:theString];
    NSCharacterSet *theSet = [NSCharacterSet whitespaceCharacterSet];
    mutString = [NSMutableString stringWithString:theString];
        theRange.length = 1;
    while(![theScanner isAtEnd])
    {
        [theScanner scanUpToCharactersFromSet:theSet intoString:nil];
        if(![theScanner isAtEnd])
        {
        theRange.location = [theScanner scanLocation];
        [mutString replaceCharactersInRange:theRange withString:@"_"];
        }
    }
    newString = [[NSString stringWithString:mutString] retain];
    return [newString autorelease];
}

-(BOOL)writeSingleValue:(NSArray *)coordinates withValue:(id)value
{
    /*Writes a single value in the reciever's data field.  The coordinates should be an array of NSNumbers (ints) that location the position for each dimension.  This should be in the same order as the dimension ID list.*/
    /*Edit: Write Values*/
    /*Validated For:
        BYTE = NO
        CHAR = NO
        SHORT = NO
        INT = NO
        FLOAT = NO
        DOUBLE = NO
        */
    int ncid,status, i;
    size_t *index;
    
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    if([dimIDs count]!=[coordinates count])
    {
        return NO;
    }
    index = (size_t *)malloc(sizeof(size_t)*[coordinates count]);
    for(i=0;i<[coordinates count];i++)
    {
        index[i] = [[coordinates objectAtIndex:i] intValue];
    }
    status = nc_open([fileName cString],NC_WRITE,&ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeSingleValue" subMethod:@"Open file" errorCode:status];
        free(index);
        return NO;
    }
    switch(dataType)
    {
        case NC_BYTE:
        {
            unsigned char theText;
            [value getBytes:&theText];
            status = nc_put_var1_uchar(ncid,varID,index,&theText);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeSingleValue" subMethod:@"Write NC_BYTE" errorCode:status];
                free(index);
                nc_close(ncid);
                return NO;
            }
            break;
        }
        case NC_CHAR:
        {
            char *theText;
            theText = (char *)malloc(sizeof(char)*2);
            [value getCString:theText];
            status = nc_put_var1_text(ncid,varID,index,&theText[0]);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeSingleValue" subMethod:@"Write NC_CHAR" errorCode:status];
                free(index);
                free(theText);
                nc_close(ncid);
                return NO;
            }
            
            free(theText);
            break;
        }
        case NC_SHORT:
        {
            short theNumber;
            theNumber = [value shortValue];
            status = nc_put_var1_short(ncid,varID,index,&theNumber);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeSingleValue" subMethod:@"Write NC_SHORT" errorCode:status];
                free(index);
                nc_close(ncid);
                return NO;
            }
            break;
        }
        case NC_INT:
        {
            int theNumber;
            theNumber = [value intValue];
            status = nc_put_var1_int(ncid,varID,index,&theNumber);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeSingleValue" subMethod:@"Write NC_INT" errorCode:status];
                free(index);
                nc_close(ncid);
                return NO;
            }
            break;
        }
        case NC_FLOAT:
        {
            float theNumber;
            theNumber = [value floatValue];
            status = nc_put_var1_float(ncid,varID,index,&theNumber);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeSingleValue" subMethod:@"Write NC_FLOAT" errorCode:status];
                free(index);
                nc_close(ncid);
                return NO;
            }
            break;
        }
        case NC_DOUBLE:
        {
            double theNumber;
            theNumber = [value doubleValue];
            status = nc_put_var1_double(ncid,varID,index,&theNumber);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeSingleValue" subMethod:@"Write NC_DOUBLE" errorCode:status];
                free(index);
                nc_close(ncid);
                return NO;
            }
            break;
        }
        case NC_NAT:
        {
            
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeSingleValue" subMethod:@"Write NC_NAT" errorCode:status];
                free(index);
                nc_close(ncid);
                return NO;
            
        }
    }
    free(index);
    nc_close(ncid);
    return YES;
}

-(BOOL)writeValueArrayAtLocation:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths withValue:(NSData *)dataObject
{
    /*Writes an array for values.  Start coordinates represents the start point in the data field.  Edge lengths is the lengths to be read for each dimension.  Data object must be an NSData object. */
    /*Edit: Write Values*/
    /*Validated For:
        BYTE = NO
        CHAR = NO
        SHORT = NO
        INT = NO
        FLOAT = NO
        DOUBLE = NO
        */
    int ncid,status, i;
    BOOL isError;
    size_t *index,*edges;
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
        
    if(([dimIDs count]!=[startCoordinates count])||([dimIDs count]!=[edgeLengths count]))
    {
        return NO;
    }
    index = (size_t *)malloc(sizeof(size_t)*[startCoordinates count]);
    edges = (size_t *)malloc(sizeof(size_t)*[edgeLengths count]);
    for(i=0;i<[startCoordinates count];i++)
    {
        index[i] = (size_t)[[startCoordinates objectAtIndex:i] intValue];
        edges[i] = (size_t)[[edgeLengths objectAtIndex:i] intValue];
        
    }
    status = nc_open([fileName cString],NC_WRITE,&ncid);
    isError = NO;
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeValueArrayAtLocation" subMethod:@"Open File" errorCode:status];
        free(index);
        free(edges);
        return NO;
    }
    //NSLog(@"Data length: %i",[dataObject length]);
    switch(dataType)
    {
        case NC_BYTE:
        {
            unsigned char *theText;
            theText = (unsigned char *)malloc(sizeof(unsigned char) *[dataObject length]);
            [dataObject getBytes:theText];
            status = nc_put_vara_uchar(ncid,varID,index,edges,theText);
            if(status!=NC_NOERR)
            {
                isError = YES;
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeValueArrayAtLocation" subMethod:@"Write NC_BYTE" errorCode:status];
            }
            free(theText);
            break;
        }
        case NC_CHAR:
        {
            char *theText;
            theText = (char *)malloc(sizeof(char)*[dataObject length]+1);
            [dataObject getBytes:theText];
            status = nc_put_vara_text(ncid,varID,index,edges,theText);
            if(status!=NC_NOERR)
            {
                isError = YES;
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeValueArrayAtLocation" subMethod:@"Write NC_CHAR" errorCode:status];
            }
            
            free(theText);
            break;
        }
        case NC_SHORT:
        {
            short *theNumber;
            theNumber = (short *)malloc([dataObject length]);
            [dataObject getBytes:theNumber];
            status = nc_put_vara_short(ncid,varID,index,edges,theNumber);
            if(status!=NC_NOERR)
            {
                isError = YES;
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeValueArrayAtLocation" subMethod:@"Write NC_SHORT" errorCode:status];
            }
            free(theNumber);
            break;
        }
        case NC_INT:
        {
            int *theNumber;
            theNumber = (int *)malloc([dataObject length]);
            [dataObject getBytes:theNumber];
            status = nc_put_vara_int(ncid,varID,index,edges,theNumber);
            if(status!=NC_NOERR)
            {
                isError = YES;
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeValueArrayAtLocation" subMethod:@"Write NC_INT" errorCode:status];
            }
            free(theNumber);
            break;
        }
        case NC_FLOAT:
        {
            float *theNumber;
            
            theNumber = (float *)malloc([dataObject length]);
            
            [dataObject getBytes:theNumber];
           
            status = nc_put_vara_float(ncid,varID,index,edges,theNumber);
            if(status!=NC_NOERR)
            {
                isError = YES;
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeValueArrayAtLocation" subMethod:@"Write NC_FLOAT" errorCode:status];
            }
            
            free(theNumber);
            
            break;
        }
        case NC_DOUBLE:
        {
            double *theNumber;
            theNumber = (double *)malloc([dataObject length]);
            [dataObject getBytes:theNumber];
            status = nc_put_vara_double(ncid,varID,index,edges,theNumber);
            if(status!=NC_NOERR)
            {
                isError = YES;
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeValueArrayAtLocation" subMethod:@"Write NC_DOUBLE" errorCode:status];
            }
            free(theNumber);
            break;
        }
        case NC_NAT:
        {
            isError = YES;
            [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"writeValueArrayAtLocation" subMethod:@"Write NC_NAT" errorCode:status];
        }
    }
    free(index);
    free(edges);
    if(isError)
        return NO;
    nc_close(ncid);
    return YES;
}

-(id)getSingleValue:(NSArray *)coordinates
{
    /*Reads a single value at the stated coordinates.  The coordinates are an array of NSNumber objects (ints) for each dimension.*/
    /*Accessor: Read Values*/
    /*Validated For:
        BYTE = NO
        CHAR = NO
        SHORT = NO
        INT = NO
        FLOAT = NO
        DOUBLE = NO
        */
    int ncid,status, i,errorCount;
    id theObject;
    size_t *index;
    theObject = nil;
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    errorCount = [theErrorHandle errorCount];
    if([dimIDs count]!=[coordinates count])
    {
        return NO;
    }
    index = (size_t *)malloc(sizeof(size_t)*[coordinates count]);
    for(i=0;i<[coordinates count];i++)
    {
        index[i] = [[coordinates objectAtIndex:i] intValue];
    }
    status = nc_open([fileName cString],NC_NOWRITE,&ncid);
    if(status!=NC_NOERR)
    {
        free(index);
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getSingleValue" subMethod:@"Open File" errorCode:status];
        return NO;
    }
    switch(dataType)
    {
        case NC_BYTE:
        {
            unsigned char theText;
            status = nc_get_var1_uchar(ncid,varID,index,&theText);
            theObject = [NSData dataWithBytes:&theText length:1];
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getSingleValue" subMethod:@"Read NC_BYTE" errorCode:status];
            }
            
            break;
        }
        case NC_CHAR:
        {
            char theText[2];
            char theChar;
            status = nc_get_var1_text(ncid,varID,index,&theChar);
            theText[0] = theChar;
            theObject = [NSString stringWithCString:theText];
            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getSingleValue" subMethod:@"Read NC_CHAR" errorCode:status];
            break;
        }
        case NC_SHORT:
        {
            short theNumber;
            status = nc_get_var1_short(ncid,varID,index,&theNumber);
            theObject = [NSNumber numberWithShort:theNumber];
            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getSingleValue" subMethod:@"Read NC_SHORT" errorCode:status];
            break;
        }
        case NC_INT:
        {
            int theNumber;
            status = nc_get_var1_int(ncid,varID,index,&theNumber);
            theObject = [NSNumber numberWithInt:theNumber];
            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getSingleValue" subMethod:@"Read NC_INT" errorCode:status];
            break;
        }
        case NC_FLOAT:
        {
            float theNumber;
            status = nc_get_var1_float(ncid,varID,index,&theNumber);
            theObject = [NSNumber numberWithFloat:theNumber];
            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getSingleValue" subMethod:@"Read NC_FLOAT" errorCode:status];
            break;
        }
        case NC_DOUBLE:
        {
            double theNumber;
            status = nc_get_var1_double(ncid,varID,index,&theNumber);
            theObject = [NSNumber numberWithDouble:theNumber];
            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getSingleValue" subMethod:@"Read NC_DOUBLE" errorCode:status];
            break;
        }
        case NC_NAT:
        {
            [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getSingleValue" subMethod:@"Read NC_NAT" errorCode:status];
        }
    }
    nc_close(ncid);
    if(errorCount == [theErrorHandle errorCount])
        return theObject;
    else
        return nil;
}


-(NSData *)getValueArrayAtLocation:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths
{
    /*Reads an array ofs values at the stated coordinates.  The coordinates are an array of NSNumber objects (ints) for each dimension.  Edge lengths are the lengths for each dimension.*/
    /*Accessor: Read Values*/
    /*Validated For:
        BYTE = NO
        CHAR = NO
        SHORT = NO
        INT = NO
        FLOAT = NO
        DOUBLE = NO
        */
    int ncid,status, i,errorCount;
    size_t *index,*edges,unitSize;
    NSData *theData;
    unitSize = 0;
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    errorCount = [theErrorHandle errorCount];
    if(([dimIDs count]!=[startCoordinates count])||([dimIDs count]!=[edgeLengths count]))
    {
        return NO;
    }
    index = (size_t *)malloc(sizeof(size_t)*[startCoordinates count]);
    edges = (size_t *)malloc(sizeof(size_t)*[edgeLengths count]);
    for(i=0;i<[startCoordinates count];i++)
    {
        index[i] = (size_t)[[startCoordinates objectAtIndex:i] intValue];
        edges[i] = (size_t)[[edgeLengths objectAtIndex:i] intValue];
        if(i==0)
            unitSize = (size_t)([[edgeLengths objectAtIndex:i] intValue]);
        else
            unitSize *= (size_t)[[edgeLengths objectAtIndex:i] intValue];
    }
    status = nc_open([fileName cString],NC_NOWRITE,&ncid);
    if(status!=NC_NOERR)
    {
        free(index);
        free(edges);
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getValueArrayAtLocation" subMethod:@"Open File" errorCode:status];
        return nil;
    }
    switch(dataType)
    {
        case NC_BYTE:
        {
            unsigned char *theText;
            theText = (unsigned char *)malloc(sizeof(unsigned char) *unitSize);
            
            status = nc_get_vara_uchar(ncid,varID,index,edges,theText);
            theData = [NSData dataWithBytes:theText length:(sizeof(unsigned char) *unitSize)];
            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getValueArrayAtLocation" subMethod:@"Read NC_BYTE" errorCode:status];
            free(theText);
            break;
        }
        case NC_CHAR:
        {
            char *theText;
            theText = (char *)malloc(sizeof(char) *unitSize+1);
            
            status = nc_get_vara_text(ncid,varID,index,edges,theText);
            theData = [NSData dataWithBytes:theText length:(sizeof(char) *unitSize)];
            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getValueArrayAtLocation" subMethod:@"Read NC_CHAR" errorCode:status];
            
            free(theText);
            break;
        }
        case NC_SHORT:
        {
            short *theNumber;
            theNumber = (short *)malloc(sizeof(short)*unitSize);
            status = nc_get_vara_short(ncid,varID,index,edges,theNumber);
            theData = [NSData dataWithBytes:theNumber length:(sizeof(short) *unitSize)];
            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getValueArrayAtLocation" subMethod:@"Read NC_SHORT" errorCode:status];
            free(theNumber);
            break;
        }
        case NC_INT:
        {
            int *theNumber;
            theNumber = (int *)malloc(sizeof(int)*unitSize);
            status = nc_get_vara_int(ncid,varID,index,edges,theNumber);
            theData = [NSData dataWithBytes:theNumber length:(sizeof(int) *unitSize)];
            
            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getValueArrayAtLocation" subMethod:@"Read NC_INT" errorCode:status];
            free(theNumber);
            break;
        }
        case NC_FLOAT:
        {
            float *theNumber;
            theNumber = (float *)malloc(sizeof(float)*unitSize);
            status = nc_get_vara_float(ncid,varID,index,edges,theNumber);
            theData = [NSData dataWithBytes:theNumber length:(sizeof(float) *unitSize)];

            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getValueArrayAtLocation" subMethod:@"Read NC_FLOAT" errorCode:status];
            free(theNumber);
            break;
        }
        case NC_DOUBLE:
        {
            double *theNumber;
            theNumber = (double *)malloc(sizeof(double)*unitSize);
            status = nc_get_vara_double(ncid,varID,index,edges,theNumber);
            theData = [NSData dataWithBytes:theNumber length:(sizeof(double) *unitSize)];

            if(status!=NC_NOERR)
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getValueArrayAtLocation" subMethod:@"Read NC_DOUBLE" errorCode:status];
            free(theNumber);
            break;
        }
        case NC_NAT:
        {
            [theErrorHandle addErrorFromSource:fileName className:@"NCDFVariable" methodName:@"getValueArrayAtLocation" subMethod:@"Read NC_NAT" errorCode:status];
            theData = nil;
        }
        default:
            theData = nil;
            break;
    }
    nc_close(ncid);
    free(index);
    free(edges);
    if(errorCount == [theErrorHandle errorCount])
        return theData;
    else
        return nil;
}

-(BOOL)isDimensionVariable
{
    /*This method is to test weather the reciever is a variable that represents dimension values.*/
    /*Accessor*/
    /*Validated*/
    NSArray *theArray;
    if([dimIDs count]!=1)
        return NO;
    theArray = [theHandle getDimensions];
    if([[[theArray objectAtIndex:[[dimIDs objectAtIndex:0]intValue]]  dimensionName] isEqualToString:variableName])
        return YES;
    return NO;
}

-(int)sizeUnitVariable
{
    NSMutableArray *theDims = [theHandle getDimensions];
    int i;
    int theSize,aLength;
    
    theSize = 1;
    for(i=0;i<[dimIDs count];i++)
    {
        aLength = [[theDims objectAtIndex:[[dimIDs objectAtIndex:i] intValue]] dimLength];
        if(![[theDims objectAtIndex:[[dimIDs objectAtIndex:i] intValue]] isUnlimited])
            theSize *= aLength;
    }
    return theSize;
}

-(int)sizeUnitVariableForType
{
   int size;
   
   size = [self sizeUnitVariable];
   switch(dataType)
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
    NSMutableArray *theDims = [theHandle getDimensions];
    int i;
    int theSize,aLength;
    
    theSize = 1;
    for(i=0;i<[dimIDs count];i++)
    {
        aLength = [[theDims objectAtIndex:[[dimIDs objectAtIndex:i] intValue]] dimLength];
        theSize *= aLength;
    }
    return theSize;
}

-(int)currentVariableByteSize
{
    int size = [self currentVariableSize];
    switch(dataType)
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

-(int)unlimitedVariableLength
{
    
    if([[[theHandle retrieveUnlimitedDimension] dimensionName] isEqualToString:[self variableName]])
    {
        NSData *theData = [self readAllVariableData];
        switch(dataType)
        {
            case NC_BYTE:
                return [theData length];
                break;
            case NC_CHAR:
                return [theData length];
                break;
            case NC_SHORT:
                return [theData length]/2;
                break;
            case NC_INT:
                return [theData length]/4 ;
                break;
            case NC_FLOAT:
                return [theData length]/4 ;
                break;
            case NC_DOUBLE:
                return [theData length]/8 ;
                break;
            default:
                break;
        }
    }
    return -1;
}
-(NSArray *)lengthArray
{
    NSMutableArray *theDims = [theHandle getDimensions];
    NSMutableArray *theLengths = [[NSMutableArray alloc] init];
    int i;
    int theSize,aLength;
    
    theSize = 1;
    for(i=0;i<[dimIDs count];i++)
    {
        aLength = [[theDims objectAtIndex:[[dimIDs objectAtIndex:i] intValue]] dimLength];
        if(aLength != NC_UNLIMITED)
            [theLengths addObject:[NSNumber numberWithInt:aLength]];
        else
        {
            [theLengths addObject:[NSNumber numberWithInt:[[theHandle retrieveUnlimitedVariable] unlimitedVariableLength]]];
        }
    }
    
    return [theLengths autorelease];
}

-(BOOL)isUnlimited
{
    int i;
    BOOL unlim;
    unlim = NO;
    for(i=0;i<[dimIDs count];i++)
    {
        if([[theHandle retrieveDimensionByIndex:[[dimIDs objectAtIndex:i] intValue]] isUnlimited])
            unlim = YES;
    }
    return unlim;
}

-(BOOL)isCompatibleWithVariable:(NCDFVariable *)aVar
{
    //check one, see if the data types are consistent
    NSMutableArray *dimLengths1,*dimLengths2;
    int i;
    if(!aVar)
        return NO;
    if(dataType!=[aVar variableNC_TYPE])
        return NO;
    if([self sizeUnitVariable]!=[aVar sizeUnitVariable])
        return NO;
    dimLengths1 = [[NSMutableArray arrayWithArray:[self lengthArray]] retain];
    dimLengths2 = [[NSMutableArray arrayWithArray:[aVar lengthArray]] retain];
    if([self isUnlimited])
    {	
        [dimLengths1 removeObjectAtIndex:0];
    }
    if([aVar isUnlimited])
    {
        [dimLengths2 removeObjectAtIndex:0];
    }
    if([dimLengths1 count]!=[dimLengths2 count])
    {
        [dimLengths1 release];
        [dimLengths2 release];
        return NO;
    }
    for(i=0;i<[dimLengths1 count];i++)
    {
        if([[dimLengths1 objectAtIndex:i] intValue]!=[[dimLengths2 objectAtIndex:i] intValue])
        {
            i = [dimLengths1 count];
            [dimLengths1 release];
            [dimLengths2 release];
            return NO;
        }
        
    }
    return YES;
}

-(BOOL)doesVariableUseDimensionName:(NSString *)aDimName
{
    int tempID,i;
    
    tempID = [[theHandle retrieveDimensionByName:aDimName] dimensionID];
    for(i=0;i<[dimIDs count];i++)
    {
        if([[dimIDs objectAtIndex:i] intValue]==tempID)
            return YES;
    }
    return NO;
}

-(BOOL)doesVariableUseDimensionID:(int)aDimID
{
    int i;
    
    for(i=0;i<[dimIDs count];i++)
    {
        if([[dimIDs objectAtIndex:i] intValue]==aDimID)
            return YES;
    }
    return NO;
}

-(BOOL)createAttributesFromAttributeArray:(NSArray *)newAttributes
{
    int i;
    
    for(i=0;i<[newAttributes count];i++)
    {
        if(![self createNewVariableAttributeWithName:[[newAttributes objectAtIndex:i]attributeName] dataType:[[newAttributes objectAtIndex:i]attributeNC_TYPE] values:[[newAttributes objectAtIndex:i]getAttributeValueArray]])
            return NO;
    }
    return YES;
}

-(NSDictionary *)propertyList
{
    NSDictionary *thePropertyList;
    NSMutableDictionary *theTemp;
    NSMutableArray *attributeDictionaries;
    NSArray *originalAtts;
    int i;
    theTemp = [[NSMutableDictionary alloc] init];
    [theTemp setObject:fileName forKey:@"fileName"];
    [theTemp setObject:[NSNumber numberWithInt:varID] forKey:@"variableID"];
    [theTemp setObject:variableName forKey:@"variableName"];
    [theTemp setObject:[NSNumber numberWithInt:(int)dataType] forKey:@"nc_type"];
    [theTemp setObject:[self dimensionNames] forKey:@"dimNames"];
    [theTemp setObject:[self readAllVariableData] forKey:@"data"];
    attributeDictionaries = [[NSMutableArray alloc] init];
    originalAtts = [self getVariableAttributes];
    for(i=0;i<[originalAtts count];i++)
    {
        [attributeDictionaries addObject:[[originalAtts objectAtIndex:i] propertyList]];
    }
    [theTemp setObject:[NSArray arrayWithArray:attributeDictionaries]  forKey:@"attributes"];
    thePropertyList = [[NSDictionary dictionaryWithDictionary:theTemp] retain];
    [theTemp release];
    [attributeDictionaries release];
    return [thePropertyList autorelease];
}

-(NSArray *)dimensionNames
{
    NSMutableArray *temp;
    NSArray *names;
    int i;
    temp = [[NSMutableArray alloc] init];
    for(i=0;i<[dimIDs count];i++)
    {
        [temp addObject:[[theHandle retrieveDimensionByIndex:[[dimIDs objectAtIndex:i] intValue]] dimensionName]];
    }
    names = [[NSArray arrayWithArray:temp] retain];
    [temp release];
    return [names autorelease];

}

-(NSArray *)allVariableDimInformation
{
    NSMutableArray *temp;
    NSArray *names;
    int i;
    temp = [[NSMutableArray alloc] init];
    for(i=0;i<[dimIDs count];i++)
    {
        [temp addObject:[theHandle retrieveDimensionByIndex:[[dimIDs objectAtIndex:i] intValue]]];
    }
    names = [[NSArray arrayWithArray:temp] retain];
    [temp release];
    return [names autorelease];
}

-(BOOL)reverseAndStoreDataAlongDimensionName:(NSString *)theDimName
{
    NSData *theData = [[self reverseDataAlongDimensionName:theDimName] retain];
    if(theData != NULL)
    {
        [self writeAllVariableData:theData];
        [theData release];
        return YES;
    }
    else
        return NO;
    
}

-(NSData *)reverseDataAlongDimensionName:(NSString *)theDimName
{
    /*QA tested for shifts of 5 for 1, 2, and 3d cases.*/
    NSArray *theVarDims = [self allVariableDimInformation];
    NSArray *theLengths = [self lengthArray];
    int i,j,flippedDim,bytes;
    NSMutableArray *theResetLengths = [[NSMutableArray alloc] init];
    NSData *theData = [self readAllVariableData];
    NSMutableData *theFinalData = [[NSMutableData alloc] initWithCapacity:[theData length]];
    NSRange theRange;
    int unitSize,unitCount,totalUnits;
    NSData *returnData;
    flippedDim = -1;
    bytes = 0;
    //get all variable dims and determine which is flipped
    for(i=0;i<[theVarDims count];i++)
    {
        if([[[theVarDims objectAtIndex:i] dimensionName] isEqualToString:theDimName])
            flippedDim = i;
    }
    if(flippedDim == -1)
        return NO;
        
    //estimate new lengths from theLengths - lengths for each dim
    //here what we want to do is figure the minimum unit that needs flipping.  We also want to know about how that will work with other dimensions.
    for(i=0;i<[theLengths count];i++)
    {
        
        int newValue = 1;
        for(j=i+1;j<[theLengths count];j++)
        {
            newValue *= [[theLengths objectAtIndex:j] intValue];
        }
        //NSLog(@"new Length: %i",newValue);
        [theResetLengths addObject:[NSNumber numberWithInt:newValue]];
    }
    switch([self variableNC_TYPE])
    {
        case NC_BYTE:
        {
            bytes = 1;
        }
        break;
        case NC_CHAR:
        {
            bytes = 1;
        }
        break;
        case NC_SHORT:
        {
            bytes = 2;
        }
        break;
        case NC_INT:
        {
            bytes = 4;
        }
        break;
        case NC_FLOAT:
        {
            bytes = 4;
        }
        break;
        case NC_DOUBLE:
        {
            bytes = 8;
        }
        break;
        default:
            bytes = 1;
            break;
    }
    //int unitSize,unitCount,totalUnits;
    unitSize = bytes * [[theResetLengths objectAtIndex:flippedDim] intValue];
    unitCount = [[theLengths objectAtIndex:flippedDim] intValue];
    totalUnits = [theData length]/(unitSize * unitCount);
    theRange.length = unitSize;
    //NSLog(@"data length should be 81, is %i",[theData length]);
    //NSLog(@"Total Units %i",totalUnits);
    //NSLog(@"unitCount %i",unitCount);
    //NSLog(@"unitSize %i",unitSize);
    //NSLog([[[NSString alloc]  initWithData:theData encoding:NSASCIIStringEncoding] autorelease]);
    //NSLog([theData description]);
    for(i=0;i<totalUnits;i++)
    {
        NSMutableArray *theArrayOfData = [[NSMutableArray alloc] init];
        for(j=0;j<unitCount;j++)
        {
            theRange.location = (i*unitSize*unitCount) + j *unitSize;
            [theArrayOfData addObject:[theData subdataWithRange:theRange]];
        }
        for(j=unitCount-1;j>-1;j--)
        {
            [theFinalData appendData:[theArrayOfData objectAtIndex:j]];
        }
        [theArrayOfData release];
        
        
    }
    //[self writeAllVariableData:[NSData dataWithData:theFinalData]];
    //NSLog([[[NSString alloc]  initWithData:theFinalData encoding:NSASCIIStringEncoding] autorelease]);
    //NSLog([theFinalData description]);
    returnData = [[NSData dataWithData:theFinalData] retain];
    [theFinalData release];
    return [returnData autorelease];
    
}

-(BOOL)shiftAndStoreDataAlongDimensionName:(NSString *)theDimName shift:(int)theShift
{
        NSData *theData = [[self shiftDataAlongDimensionName:theDimName shift:theShift] retain];
    if(theData != NULL)
    {
        [self writeAllVariableData:theData];
        [theData release];
        return YES;
    }
    else
        return NO;
}

-(NSData *)shiftDataAlongDimensionName:(NSString *)theDimName shift:(int)theShift
{
    /*QA tested for shifts of 5 for 1, 2, and 3d cases.*/
    NSArray *theVarDims = [self allVariableDimInformation];
    NSArray *theLengths = [self lengthArray];
    int i,j,flippedDim,bytes;
    NSMutableArray *theResetLengths = [[NSMutableArray alloc] init];
    NSData *theData = [self readAllVariableData];
    NSMutableData *theFinalData = [[NSMutableData alloc] initWithCapacity:[theData length]];
    NSRange theRange;
    int unitSize,unitCount,totalUnits;
    NSData *returnData;
    flippedDim = -1;
    bytes = 0;
    //get all variable dims and determine which is flipped
    for(i=0;i<[theVarDims count];i++)
    {
        if([[[theVarDims objectAtIndex:i] dimensionName] isEqualToString:theDimName])
            flippedDim = i;
    }
    if(flippedDim == -1)
        return NO;
        
    //estimate new lengths from theLengths - lengths for each dim
    //here what we want to do is figure the minimum unit that needs flipping.  We also want to know about how that will work with other dimensions.
    for(i=0;i<[theLengths count];i++)
    {
        
        int newValue = 1;
        for(j=i+1;j<[theLengths count];j++)
        {
            newValue *= [[theLengths objectAtIndex:j] intValue];
        }
        //NSLog(@"new Length: %i",newValue);
        [theResetLengths addObject:[NSNumber numberWithInt:newValue]];
    }
    switch([self variableNC_TYPE])
    {
        case NC_BYTE:
        {
            bytes = 1;
        }
        break;
        case NC_CHAR:
        {
            bytes = 1;
        }
        break;
        case NC_SHORT:
        {
            bytes = 2;
        }
        break;
        case NC_INT:
        {
            bytes = 4;
        }
        break;
        case NC_FLOAT:
        {
            bytes = 4;
        }
        break;
        case NC_DOUBLE:
        {
            bytes = 8;
        }
        break;
        default:
            bytes = 1;
            break;
    }
    //int unitSize,unitCount,totalUnits;
    unitSize = bytes * [[theResetLengths objectAtIndex:flippedDim] intValue];
    unitCount = [[theLengths objectAtIndex:flippedDim] intValue];
    totalUnits = [theData length]/(unitSize * unitCount);
    theRange.length = unitSize;
    //NSLog(@"data length should be 81, is %i",[theData length]);
    //NSLog(@"Total Units %i",totalUnits);
    //NSLog(@"unitCount %i",unitCount);
    //NSLog(@"unitSize %i",unitSize);
    //NSLog([[[NSString alloc]  initWithData:theData encoding:NSASCIIStringEncoding] autorelease]);
    //NSLog([theData description]);
    for(i=0;i<totalUnits;i++)
    {
        NSMutableArray *theArrayOfData = [[NSMutableArray alloc] init];
        for(j=0;j<unitCount;j++)
        {
            theRange.location = (i*unitSize*unitCount) + j *unitSize;
            [theArrayOfData addObject:[theData subdataWithRange:theRange]];
        }
        //recalculate shift point - eliminates the possibility of emptying theArrayOfData
        if(theShift>0)
        {
            while(theShift>=unitCount)
                theShift -= unitCount;
        }
        else if(theShift<0)
        {
            while(theShift<=unitCount)
                theShift += unitCount;
        }
        //shift point
        if(theShift>0)
        {
            NSData *someData;
            for(j=0;j<theShift;j++)
            {
                someData = [[theArrayOfData lastObject]retain];
                [theArrayOfData removeLastObject];
                [theArrayOfData insertObject:someData atIndex:0];
                [someData release];
            }
        }
        else if(theShift<0)
        {
            NSData *someData;
            theShift *= -1;
            for(j=0;j<theShift;j++)
            {
                someData = [[theArrayOfData objectAtIndex:0]retain];
                [theArrayOfData removeObjectAtIndex:0];
                [theArrayOfData addObject:someData];
                [someData release];
            }
        }
        //load into a new data object
        for(j=0;j<unitCount;j++)
        {
            [theFinalData appendData:[theArrayOfData objectAtIndex:j]];
        }
        [theArrayOfData release];
        
        
    }
    //[self writeAllVariableData:[NSData dataWithData:theFinalData]];
    //NSLog([[[NSString alloc]  initWithData:theFinalData encoding:NSASCIIStringEncoding] autorelease]);
    //NSLog([theFinalData description]);
    returnData = [[NSData dataWithData:theFinalData] retain];
    [theFinalData release];
    return [returnData autorelease];
    
}

-(NCDFAttribute *)variableAttributeByName:(NSString *)name
{
    int i;
    NSArray *theCurrentAtts = [self getVariableAttributes];
    for(i=0;i<[theCurrentAtts count];i++)
    {
        if([[[theCurrentAtts objectAtIndex:i] attributeName] isEqualToString:name])
            return [theCurrentAtts objectAtIndex:i];
    }
    return nil;
}

-(NSString *)htmlDescription
{
	NSMutableString *theString = [[[NSMutableString alloc] init]autorelease];
	NSArray *theCurrentDims = [self allVariableDimInformation];
	NSArray *theCurrentAtts = [self getVariableAttributes];
	//Step 1.  Add variable name and internal link
	
	[theString appendString:@"\n<BR>\n"];
	[theString appendFormat:@"<a name=\"var-%@\"></a><h4>%@</h4><BR>",[self variableName],[self variableName]];
	[theString appendString:@"<blockquote>\n"];
	//Step 2. Dimension information
	 if([theCurrentDims count] > 0)
	 {
		 [theString appendString:@"<b>Dimensions</b>\n<BR>\n"];
		 //Step 2a. create a table
		 [theString appendString:@"<table width=\"600\" border=\"1\" cellspacing=\"0\" cellpadding=\"0\">\n"];
		 NSEnumerator *anEnum = [theCurrentDims objectEnumerator];
		 NCDFDimension *aDim;
		 while(aDim = [anEnum nextObject])
		 {
			 [theString appendString:@"<tr>\n"];
				[theString appendString:@"<td  width=\"200\">\n"];
					[theString appendFormat:@"%@",[aDim dimensionName]];
				[theString appendString:@"</td>\n"];
				[theString appendString:@"<td>\n"];
					[theString appendFormat:@"%i",[aDim dimLength]];
				[theString appendString:@"</td>\n"];
			 [theString appendString:@"</tr>\n"];
			 
		 }
		 [theString appendString:@"</table>"];
	 }
	 else
	 {
		 [theString appendFormat:@"<b>Dimensionless</b>\n<BR>\n"];
	 }
	 [theString appendString:@"<P>"];
	//Step 3. Attribute Information
	 if([theCurrentAtts count] > 0)
	 {
		 [theString appendString:@"<b>Attributes</b>\n<BR>\n"];
		 //Step 2a. create a table
		 [theString appendString:@"<table width=\"600\" border=\"1\" cellspacing=\"0\" cellpadding=\"0\">\n"];
		 NSEnumerator *anEnum = [theCurrentAtts objectEnumerator];
		 NCDFAttribute *anAtt;
		 while(anAtt = [anEnum nextObject])
		 {
			 [theString appendString:@"<tr>\n"];
			 [theString appendString:@"<td  width=\"200\">\n"];
			 [theString appendFormat:@"%@",[anAtt attributeName]];
			 [theString appendString:@"</td>\n"];
			 [theString appendString:@"<td>\n"];
			 [theString appendFormat:@"%@",[anAtt contentDescription]];
			 [theString appendString:@"</td>\n"];
			 [theString appendString:@"</tr>\n"];
			 
		 }
		 [theString appendString:@"</table>"];
	 }
	 else
	 {
		 [theString appendFormat:@"<b>No Variable Attributes</b>\n<BR>\n"];
	 }
	 [theString appendString:@"</blockquote>\n"];
	 return [NSString stringWithString:theString];
}

-(NSString *)typeDescription
{
	switch([self variableNC_TYPE])
	{
		case NC_BYTE:
			return [NSString stringWithString:@"BYTE"];
			break;
		case NC_CHAR:
			return [NSString stringWithString:@"CHAR"];
			break;
		case NC_SHORT:
			return [NSString stringWithString:@"SHORT INTEGER"];
			break;
		case NC_INT:
			return [NSString stringWithString:@"INTEGER"];
			break;
		case NC_FLOAT:
			return [NSString stringWithString:@"FLOAT"];
			break;
		case NC_DOUBLE:
			return [NSString stringWithString:@"DOUBLE"];
			break;
		default:
			return [NSString stringWithString:@"UNKNOWN"];
	}
}

-(NSString *)stringValueForSingleValueCoordinates:(NSArray *)coordinates
{
	id result = [self getSingleValue:coordinates];
	switch([self variableNC_TYPE])
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

-(void)updateVariableWithVariable:(NCDFVariable *)aVar
{
	NSString *temp = [variableName retain];
    variableName = [[aVar variableName] copy];
	[temp autorelease];
	
    varID = [aVar variableID];
    dataType = [aVar variableNC_TYPE];
	NSArray *tempDim = [dimIDs retain];
    dimIDs = [[aVar variableDimensions] copy];
	[tempDim autorelease];
    numberOfAttributes = [aVar attributeCount];
}

-(int)variableID
{
	return varID;
}

-(int)attributeCount
{
	return numberOfAttributes;
}

-(NSComparisonResult)compare:(id)object
{	
	if([object isKindOfClass:[NCDFVariable class]])
	{
		if([self variableID] < [(NCDFVariable *)object variableID])
			return NSOrderedAscending;
		else
			return NSOrderedDescending;
	}
	else
	return NSOrderedSame;
}

-(NCDFSlab *)getSlabForStartCoordinates:(NSArray *)startCoordinates edgeLengths:(NSArray *)edgeLengths
{
	NSData *theTempData = [self getValueArrayAtLocation:startCoordinates edgeLengths:edgeLengths];
	NCDFSlab *theSlab = [[[NCDFSlab alloc] initSlabWithData:theTempData withType:[self variableNC_TYPE] withLengths:edgeLengths] autorelease];
	return [theSlab autorelease];
}


-(NCDFSlab *)getAllDataInSlab
{
	NSData *theTempData = [self readAllVariableData];
	NCDFSlab *theSlab = [[[NCDFSlab alloc] initSlabWithData:theTempData withType:[self variableNC_TYPE] withLengths:[self lengthArray]] autorelease];
	return theSlab;
}
@end
