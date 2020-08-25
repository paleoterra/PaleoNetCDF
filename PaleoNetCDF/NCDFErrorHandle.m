//
//  NCDFErrorHandle.m
//  netcdf
//
//  Created by Tom Moore on Wed Jul 31 2002.
//  Copyright (c) 2001 Argonne National Laboratory. All rights reserved.
//

#import "NCDFErrorHandle.h"
#import "NCDFError.h"

NCDFErrorHandle *theDefaultErrorHandle;

@implementation NCDFErrorHandle

-(id)init
{
    self = [super init];
    theErrors = [[NSMutableArray alloc] init];
    return self;
}

+(id)defaultErrorHandle
{
    if(theDefaultErrorHandle)
        return theDefaultErrorHandle;
    else
    {
        theDefaultErrorHandle = [[NCDFErrorHandle alloc] init];
        return theDefaultErrorHandle;
    }
}

-(void)addError:(NCDFError *)anError
{
    [theErrors addObject:anError];
#ifdef Debug_NCDFErrorHandle
    [self logLastError];
#endif
}

-(void)addErrorFromSource:(NSString *)sourceFile className:(NSString *)className methodName:(NSString *)methodName subMethod:(NSString *)subMethod errorCode:(int)errorCode
{
    [theErrors addObject:[[NCDFError alloc] initErrorFromSourceName:sourceFile theClass:className fromMethod:methodName fromSubmethod:subMethod withError:errorCode]];
#ifdef Debug_NCDFErrorHandle
    [self logLastError];
#endif
}

-(NCDFError *)lastError
{
    if([theErrors count]<1)
        return nil;
    else
        return [theErrors lastObject];
}

-(int)errorCount
{
    return (int)[theErrors count];
}

-(NCDFError *)errorAtIndex:(int)index
{
    return theErrors[index];
}

-(NSArray *)allErrors
{
    return theErrors;
}

-(void)deleteError:(int)index
{
    [theErrors removeObjectAtIndex:index];
}

-(void)removeLastError
{
    [theErrors removeLastObject];
}

-(void)removeAllErrors
{
    [theErrors removeAllObjects];
}


-(NSString *)lastErrorString
{
    NSArray *theArray = [[theErrors lastObject] alertArray];
    return [NSString stringWithFormat:@"Error: %@\nFile: %@\nClass: %@\nMethod %@\nSub-Method %@\nCode: %i\n",theArray[0],theArray[1],theArray[2],theArray[3],theArray[4],[theArray[5] intValue]];
}

-(NSArray *)lastErrorForAlert
{
    return [[theErrors lastObject] alertArray];
}

-(NSArray *)lastErrorLocalizedForAlert
{
    return [[theErrors lastObject] localizedAlertArray];
}

-(void)logLastError
{
    [[theErrors lastObject] logString];
}

-(void)logAllErrors
{
    int32_t i;
    for(i=0;i<[theErrors count];i++)
    {
        [theErrors[i] logString];
    }
}

-(void)dealloc
{
    theErrors = nil;
}
@end
