//
//  NCDFAttribute.m
//  netcdf
//
//  Created by tmoore on Wed Feb 13 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

#import "NCDFNetCDF.h"

@implementation NCDFAttribute

-(id)initWithPath:(NSString *)thePath name:(NSString *)theName variableID:(int)theID length:(size_t)dataLength type:(nc_type)theType handle:(NCDFHandle *)handle
{
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: initWithPath");
#endif

    [super init];
    fileName = [thePath copy];
    attName = [theName copy];
    variableID = theID;
    type = theType;
    length = dataLength;
    //need to load values
    [self loadValues];
    theHandle = handle;
    return self;
}

-(id)initWithName:(NSString *)theName length:(size_t)dataLength type:(nc_type)theType valueArray:(NSArray *)newValues
{
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: initWithName");
#endif
    [super init];
    fileName = nil;
    attName = [theName copy];
    variableID = -1;
    type = theType;
    length = dataLength;
    //need to load values
    [self setValueArray:newValues];
    theHandle = nil;
    return self;
}

-(id)initWithAttribute:(NCDFAttribute *)anAttribute
{
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: initWithAttribute");
#endif
    [super init];
    fileName = nil;
    attName = [[anAttribute attributeName] copy];
    variableID = -1;
    type = [anAttribute attributeNC_TYPE];
    length = [anAttribute attributeLength];
    //need to load values
    [self setValueArray:[anAttribute getAttributeValueArray]];
    theHandle = nil;
    return self;
}

-(void)dealloc
{
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: dealloc");
#endif
    if(fileName)
        [fileName release];
    if(attName)
        [attName release];
    if(theValues)
        [theValues release];
    
    [super dealloc];
    
}

-(void)loadValues
{
    int ncid;
    int status;
    NSMutableArray *tempValues;
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: loadValues");
#endif
    if(theErrorHandle == nil)
        theErrorHandle = [NCDFErrorHandle defaultErrorHandle];
    if(theValues)
        [theValues release];
    tempValues = [[NSMutableArray alloc] init];
    status = nc_open([fileName cString],NC_NOWRITE,&ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Opening netCDF file" errorCode:status];
        return;
    }
    switch (type){
        case NC_BYTE:
        {
            unsigned char *theText;
            NSData *theData;
            theText = (unsigned char *)malloc(sizeof(unsigned char)*length);
            status = nc_get_att_uchar (ncid,variableID,[attName cString],theText);
            if(status!=NC_NOERR)
            {
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Fail to read byte data" errorCode:status];
                free(theText);
                return;
            }
            theData = [NSData dataWithBytes:theText length:length];
            [tempValues addObject:theData];
            free(theText);
            break;
        }
        case NC_CHAR:
        {
            unsigned char *theText;
            NSString *theString;
            theText = (char *)malloc(sizeof(char)*length+1);
            status = nc_get_att_text (ncid,variableID,[attName cString],theText);
            if(status!=NC_NOERR)
            {
                free(theText);
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Fail to read character data" errorCode:status];
                return;
            }

            theText[length] = '\0';
            theString = [NSString stringWithCString:theText];
            [tempValues addObject:theString];
            free(theText);
            break;
        }
        case NC_SHORT:
        {
            int i;
            short *array;
            array = (short *)malloc(sizeof(short)*length);
            status = nc_get_att_short (ncid,variableID,[attName cString],array);
            if(status!=NC_NOERR)
            {
                free(array);
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Fail to read short data" errorCode:status];
                return;
            }

            for(i=0;i<length;i++)
                [tempValues addObject:[NSNumber numberWithShort:array[i]]];
            free(array);
            break;
        }
        case NC_INT:
        {
            int i;
            int *array;
            array = (int *)malloc(sizeof(int)*length);
            status = nc_get_att_int (ncid,variableID,[attName cString],array);
            if(status!=NC_NOERR)
            {
                free(array);
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Fail to read integer data" errorCode:status];
                return;
            }
            for(i=0;i<length;i++)
                [tempValues addObject:[NSNumber numberWithInt:array[i]]];
            free(array);
            break;
        }
        case NC_FLOAT:
        {
            int i;
            float *array;
            array = (float *)malloc(sizeof(float)*length);
            status = nc_get_att_float (ncid,variableID,[attName cString],array);
            if(status!=NC_NOERR)
            {
                free(array);
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Fail to read float data" errorCode:status];
                return;
            }
            for(i=0;i<length;i++)
                [tempValues addObject:[NSNumber numberWithFloat:array[i]]];
            free(array);
            break;
        }
        case NC_DOUBLE:
        {
            int i;
            double *array;
            array = (double *)malloc(sizeof(double)*length);
            status = nc_get_att_double (ncid,variableID,[attName cString],array);
            if(status!=NC_NOERR)
            {
                free(array);
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Fail to read double data" errorCode:status];
                return;
            }
            for(i=0;i<length;i++)
                [tempValues addObject:[NSNumber numberWithDouble:array[i]]];
            free(array);
            break;
        }
        case NC_NAT:
        {
            [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Case NC_Nat not hanlded" errorCode:status];
        }
    }
    
    theValues = [tempValues copy];
    [tempValues release];
    nc_close(ncid);
    
    //NSLog(@"theValues count:%i",[theValues count]);
}

-(void)setValueArray:(NSArray *)anArray
{
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: setValueArray");
#endif
    if(theValues)
        [theValues release];
    if(anArray)
        theValues = [anArray copy];
    else
        theValues = [[NSArray alloc] init];
}

-(NSString *)attributeName
{
    /*Returns the name of the reciever.*/
    /*Accessor*/
    /*Validated*/
    return attName;
}

-(NSString *)contentDescription
{
    /*Returns a NSString version of all the values stored in the attribute.  If the returned value is modified by a character, then it is either a short integer (s), integer(i), floating point value (f), or double precision floating point value (d).*/
    /*Accessor: Values*/
    /*Validated For:
        BYTE = NO
        CHAR = YES
        SHORT = NO
        INT = NO
        FLOAT = NO
        DOUBLE = NO
        */
    int i;
    NSString *initial;
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: contentDescription");
#endif
    initial = [NSString stringWithString:@""];
    for(i=0;i<[theValues count];i++)
    {
        initial = [initial stringByAppendingString:[self stringFromObject:[theValues objectAtIndex:i]]];
    
    }
    [initial retain];
    return [initial autorelease];
}

-(NSString *)stringFromObject:(id)object
{
    NSString *theString;
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: stringFromObject");
#endif
    theString = [NSString stringWithString:@""];
    switch (type){
        case NC_BYTE:
        {	
            unsigned char *theByteData = (unsigned char *)malloc([(NSData *)object length]);
            int i;
            NSMutableString *mutString = [[NSMutableString alloc] init];
            [(NSData *)object getBytes:theByteData];
            for(i=0;i<[(NSData *)object length];i++)
            {
                [mutString appendFormat:@"%u ",theByteData[i]];
            }
            theString = [[NSString stringWithString:mutString] retain];
            [mutString release];
            break;
        }
        case NC_CHAR:
        {
            theString = [[NSString stringWithString:object] retain];
            break;
        }
        case NC_SHORT:
        {
            theString = [[NSString stringWithFormat:@"%i ",[object intValue]] retain];
            break;
        }
        case NC_INT:
        {
            theString = [[NSString stringWithFormat:@"%i ",[object intValue]] retain];
            break;
        }
        case NC_FLOAT:
        {
            theString = [[NSString stringWithFormat:@"%f ",[object floatValue]] retain];
            break;
        }
        case NC_DOUBLE:
        {
            theString = [[NSString stringWithFormat:@"%f ",[object floatValue]] retain];
            break;
        }
        case NC_NAT:
        {
            NSLog(@"Case NC_NAT not handled");
        }
    }
    if(theString)
        return [theString autorelease];
    else
        return [NSString stringWithString:@""];
}


-(NSString *)parseNameString:(NSString *)theString
{
    NSString *newString;
    NSMutableString *mutString;
    NSRange theRange;
    NSScanner *theScanner = [NSScanner scannerWithString:theString];
    NSCharacterSet *theSet = [NSCharacterSet whitespaceCharacterSet];
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: parseNameString");
#endif
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

-(BOOL)renameAttribute:(NSString *)newName
{
    int status;
    int ncid;
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: renameAttribute");
#endif
    if(theErrorHandle == nil)
        theErrorHandle = [NCDFErrorHandle defaultErrorHandle];
    newName = [self parseNameString:newName];
    status = nc_open([fileName cString],NC_WRITE,&ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"renameAttribute" subMethod:@"Open netCDF failed" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"renameAttribute" subMethod:@"Redefine mode failed" errorCode:status];
        nc_close(ncid);
        return NO;
    }
    status = nc_rename_att(ncid,variableID,[attName cString],[newName cString]);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"renameAttribute" subMethod:@"Rename attribute failed" errorCode:status];
        nc_close(ncid);
        return NO;
    }
    nc_close(ncid);
    return YES;
    
}

-(NSArray *)getAttributeValueArray
{

    return theValues;
}

-(BOOL)isEqualToAttribute:(NCDFAttribute *)anAttribute
{
    if([attName isEqualToString:[anAttribute attributeName]])
        return YES;
    else
        return NO;
}

-(nc_type)attributeNC_TYPE
{
    return type;
}

-(size_t)attributeLength
{
    return length;
}

-(NSString *)attributeOwnerName
{
    NSArray *theArray;
    if(variableID == NC_GLOBAL)
        return [NSString stringWithString:@"Global"];
    else
    {
        theArray = [theHandle getVariables];
        return [[theArray objectAtIndex:variableID] variableName];
    }
    return nil;

}

-(BOOL)isGlobal
{
    if(variableID==NC_GLOBAL)
        return YES;
    return NO;
}

-(int)ownerVariableID
{
    return variableID;
}

-(NSDictionary *)propertyList
{
    NSDictionary *thePropertyList;
    NSMutableDictionary *theTemp;
    theTemp = [[NSMutableDictionary alloc] init];
    [theTemp setObject:fileName forKey:@"fileName"];
    [theTemp setObject:[NSNumber numberWithInt:variableID] forKey:@"variableID"];
    [theTemp setObject:attName forKey:@"attributeName"];
    [theTemp setObject:[NSNumber numberWithInt:(int)type] forKey:@"nc_type"];
    [theTemp setObject:[NSNumber numberWithInt:(int)length] forKey:@"length"];
    [theTemp setObject:[NSArray arrayWithArray:theValues] forKey:@"values"];
    thePropertyList = [[NSDictionary dictionaryWithDictionary:theTemp] retain];
    [theTemp release];
    return [thePropertyList autorelease];

}
@end
