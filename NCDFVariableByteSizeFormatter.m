//
//  NCDFVariableByteSizeFormatter.m
//  netcdf
//
//  Created by Tom Moore on Tue Nov 12 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

#import "NCDFVariableByteSizeFormatter.h"
#import "NCDFVariable.h"


@implementation NCDFVariableByteSizeFormatter

-(NSString *)stringForObjectValue:(id)anObject
{
    int size = 1;
    float finalSize;
    float base = 1024.0;
    if(![anObject isKindOfClass:[NSNumber class]])
        return nil;
    size = [anObject intValue];
    finalSize = (float)size;
    if(finalSize<base)
    {
        return [NSString stringWithFormat:@"%i B",size];
    }
    finalSize /= base;
    if(finalSize<base)
    {
        return [NSString stringWithFormat:@"%.1f KB",finalSize];
    }
    finalSize /= base;
    if(finalSize<base)
    {
        return [NSString stringWithFormat:@"%.1f MB",finalSize];
    }
    finalSize /= base;
    return [NSString stringWithFormat:@"%.1f GB",finalSize];
}
@end
