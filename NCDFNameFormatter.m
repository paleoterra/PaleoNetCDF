//
//  NCDFNameFormatter.m
//  netcdf
//
//  Created by Tom Moore on Thu Nov 14 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

#import "NCDFNameFormatter.h"

@implementation NCDFNameFormatter

-(NSString *)stringForObjectValue:(id)anObject
{

    if([anObject isKindOfClass:[NSString class]])
    {
        return [self parseNameString:(NSString *)anObject];
    }
    return nil;
}

-(NSString *)parseNameString:(NSString *)theString
{
    /*This method ensures that a name for creation or renaming of an netcdf object does not contain white spaces.  All white spaces are replaced with "_" values.*/
    /*Validation*/
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
        theRange.location = [theScanner scanLocation];       
        if(theRange.location!=[theString length])
            [mutString replaceCharactersInRange:theRange withString:@"_"];
    }
    newString = [[NSString stringWithString:mutString] retain];
    return [newString autorelease];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
    BOOL result = NO;
    NSString *aString;
    NSString *err = [NSString stringWithString:@"Name Not Properly Formatted"];

    aString = [self parseNameString:string];
    if([aString isEqualToString:string])
        result = YES;
    else
        result = NO;
    *anObject = aString;

    error = &err;

    return result;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
    BOOL result = NO;
    NSString *aString;
    NSString *err = [NSString stringWithString:@"Name Not Properly Formatted"];
    //NSLog(@"I'm here");
    aString = [self parseNameString:partialString];
    //NSLog(@"I'm here 2");
    *newString = aString;
    //NSLog(partialString);
    //NSLog(aString);
    //NSLog(*newString);
    if([aString isEqualToString:partialString])
        result = YES;
    else
    {
        //newString = &aString;
        result = NO;
    }
    error = &err;
    return result;
}
@end
