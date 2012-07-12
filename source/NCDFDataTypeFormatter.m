//
//  NCDFDataTypeFormatter.m
//  netcdf
//
//  Created by Tom Moore on Tue Nov 12 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

#import "NCDFDataTypeFormatter.h"
#import "netcdf.h"

@implementation NCDFDataTypeFormatter


-(NSString *)stringForObjectValue:(id)anObject
{
    if(![anObject isKindOfClass:[NSNumber class]])
        return nil;
    switch([anObject intValue])
    {
        case NC_BYTE:
            return [NSString stringWithString:@"NC_BYTE"];
            break;
        case NC_CHAR:
            return [NSString stringWithString:@"NC_CHAR"];
            break;
        case NC_SHORT:
            return [NSString stringWithString:@"NC_SHORT"];
            break;
        case NC_INT:
            return [NSString stringWithString:@"NC_INT"];
            break;
        case NC_FLOAT:
            return [NSString stringWithString:@"NC_FLOAT"];
            break;
        case NC_DOUBLE:
            return [NSString stringWithString:@"NC_DOUBLE"];
            break;
        default:
            return nil;
    }
    return nil;
}
@end
