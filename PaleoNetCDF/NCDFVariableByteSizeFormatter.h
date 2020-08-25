//
//  NCDFVariableByteSizeFormatter.h
//  netcdf
//
//  Created by Tom Moore on Tue Nov 12 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

/*!
 @header


 @class NCDFVariableByteSizeFormatter
@abstract NCDFVariableByteSizeFormatter is a subclass of NSFormatter designed to turn a number into a byte size report for display.
    @discussion This class is a convenience class for GUI interface elements, such as NSTableViews. An integer value passed as an NSNumber object to this formatter with result in an NSString with the number converted into a byte size.  It assumes that the number is the number of bytes, and converts that to b, kb, mb, or gbs depending on the value.
*/

#import <Foundation/Foundation.h>


@interface NCDFVariableByteSizeFormatter : NSFormatter {

}

@end
