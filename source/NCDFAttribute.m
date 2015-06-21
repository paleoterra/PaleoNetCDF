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

    self = [super init];
    fileName = [thePath copy];
    attName = [theName copy];
    variableID = theID;
    type = theType;
    length = dataLength;
    //need to load values
    
    theHandle = handle;
	[self loadValues];
    return self;
}


-(id)initWithName:(NSString *)theName length:(size_t)dataLength type:(nc_type)theType valueArray:(NSArray *)newValues
{
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: initWithName");
#endif
    self = [super init];
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
    self = [super init];
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

-(NSLock *)handleLock
{
	return [theHandle handleLock];
}


-(void)loadValues
{
    int32_t ncid;
    int32_t status;
    NSMutableArray *tempValues;
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: loadValues");
#endif
	//NSLog(@"%s %i",__FUNCTION__,__LINE__);
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    tempValues = [[NSMutableArray alloc] init];
	//NSLog(@"%s %i ncid %@ ",__FUNCTION__,__LINE__,[theHandle description]);
	ncid = [theHandle ncidWithOpenMode:NC_SHARE status:&status];
	//NSLog(@"%s %i ncid %i ",__FUNCTION__,__LINE__,ncid);
	if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Opening netCDF file" errorCode:status];
        return;
    }
    switch (type){
        case NC_BYTE:
        {
            uint8 *theText;
            NSData *theData;
            theText = (uint8 *)malloc(sizeof(uint8)*length);
            status = nc_get_att_uchar (ncid,variableID,[attName cStringUsingEncoding:NSUTF8StringEncoding],theText);
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
            char *theText;
            NSString *theString;
            theText = (char *)malloc(sizeof(char)*length+1);
			//NSLog(@"%s %i length %i",__FUNCTION__,__LINE__,length);
            status = nc_get_att_text (ncid,variableID,[attName cStringUsingEncoding:NSUTF8StringEncoding],theText);
            if(status!=NC_NOERR)
            {
                free(theText);
                [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"loadValues" subMethod:@"Fail to read character data" errorCode:status];
                return;
            }

            theText[length] = '\0';
			theString = [NSString stringWithCString:theText encoding:NSUTF8StringEncoding];
           
            [tempValues addObject:theString];
            free(theText);
            break;
        }
        case NC_SHORT:
        {
            int32_t i;
            int16_t *array;
            array = (int16_t *)malloc(sizeof(int16_t)*length);
            status = nc_get_att_short (ncid,variableID,[attName cStringUsingEncoding:NSUTF8StringEncoding],array);
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
            int32_t i;
            int32_t *array;
            array = (int32_t *)malloc(sizeof(int)*length);
            status = nc_get_att_int (ncid,variableID,[attName cStringUsingEncoding:NSUTF8StringEncoding],array);
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
            int32_t i;
            float *array;
            array = (float *)malloc(sizeof(float)*length);
            status = nc_get_att_float (ncid,variableID,[attName cStringUsingEncoding:NSUTF8StringEncoding],array);
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
            int32_t i;
            double *array;
            array = (double *)malloc(sizeof(double)*length);
            status = nc_get_att_double (ncid,variableID,[attName cStringUsingEncoding:NSUTF8StringEncoding],array);
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
    //NSLog(@"tempValues %@",[tempValues description]);
    theValues = [tempValues copy];
	

	//NSLog(@"%@",[theValues description]);
    [theHandle closeNCID:ncid];
    
    //NSLog(@"theValues count:%i",[theValues count]);
}

-(void)setValueArray:(NSArray *)anArray
{
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: setValueArray");
#endif
    if(anArray)
        theValues = [NSMutableArray arrayWithArray:anArray];
    else
        theValues = [[NSMutableArray alloc] init];
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
    int32_t i;
    NSMutableString *initial;
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: contentDescription");
#endif
    initial = [[NSMutableString alloc] init];
    for(i=0;i<[theValues count];i++)
    {
        [initial appendString:[self stringFromObject:[theValues objectAtIndex:i]]];
    
    }
    
    return [NSString stringWithString:initial];
}

-(NSString *)stringFromObject:(id)object
{
    NSString *theString;
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: stringFromObject");
#endif
    
    switch (type){
        case NC_BYTE:
        {	
            uint8 *theByteData = (uint8 *)malloc([(NSData *)object length]);
            int32_t i;
            NSMutableString *mutString = [[NSMutableString alloc] init];
            [(NSData *)object getBytes:theByteData];
            for(i=0;i<[(NSData *)object length];i++)
            {
                [mutString appendFormat:@"%u ",theByteData[i]];
            }
            theString = [NSString stringWithString:mutString];
            break;
        }
        case NC_CHAR:
        {
            theString = [NSString stringWithString:object];
            break;
        }
        case NC_SHORT:
        {
            theString = [NSString stringWithFormat:@"%i ",[object intValue]];
            break;
        }
        case NC_INT:
        {
            theString = [NSString stringWithFormat:@"%i ",[object intValue]];
            break;
        }
        case NC_FLOAT:
        {
            theString = [NSString stringWithFormat:@"%f ",[object floatValue]];
            break;
        }
        case NC_DOUBLE:
        {
            theString = [NSString stringWithFormat:@"%f ",[object floatValue]];
            break;
        }
        case NC_NAT:
        {
            NSLog(@"Case NC_NAT not handled");
        }
    }
    
	return theString;
    
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
    newString = [NSString stringWithString:mutString];
    return newString;
}

-(BOOL)renameAttribute:(NSString *)newName
{
    int32_t status;
    int32_t ncid;
#ifdef DEBUG_NCDFAttribute
    NSLog(@"NCDFAttribute: renameAttribute");
#endif
    if(theErrorHandle == nil)
        theErrorHandle = [theHandle theErrorHandle];
    newName = [self parseNameString:newName];
	ncid = [theHandle ncidWithOpenMode:NC_WRITE status:&status];
    
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"renameAttribute" subMethod:@"Open netCDF failed" errorCode:status];
        return NO;
    }
    status = nc_redef(ncid);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"renameAttribute" subMethod:@"Redefine mode failed" errorCode:status];
        [theHandle closeNCID:ncid];
        return NO;
    }
    status = nc_rename_att(ncid,variableID,[attName cStringUsingEncoding:NSUTF8StringEncoding],[newName cStringUsingEncoding:NSUTF8StringEncoding]);
    if(status!=NC_NOERR)
    {
        [theErrorHandle addErrorFromSource:fileName className:@"NCDFAttribute" methodName:@"renameAttribute" subMethod:@"Rename attribute failed" errorCode:status];
        [theHandle closeNCID:ncid];
        return NO;
    }
    [theHandle closeNCID:ncid];
	[theHandle refresh];
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
        return @"Global";
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
    thePropertyList = [NSDictionary dictionaryWithDictionary:theTemp];
    return thePropertyList;

}

-(void)updateAttributeWithAttribute:(NCDFAttribute *)anAtt
{

    variableID = [anAtt variableID];
    type = [anAtt attributeNC_TYPE];
    length = [anAtt attributeLength];
    //need to load values
    [self setValueArray:[anAtt getAttributeValueArray]];

}

-(int)variableID
{
	return variableID;
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
@end
