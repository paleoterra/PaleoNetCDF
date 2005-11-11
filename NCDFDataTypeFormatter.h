//
//  NCDFDataTypeFormatter.h
//  netcdf
//
//  Created by Tom Moore on Tue Nov 12 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

/*!
	@header
  @class NCDFDataTypeFormatter
@abstract NCDFDataTypeFormatter is a subclass of NSFormatter designed to turn nc_types into NSString objects for display.
    @discussion This class is a convenience class for GUI interface elements, such as NSTableViews. Instead of requiring a conversion technique for each time the nc_type needs to be displayed, this formatter can be attached to a cell and the cell can be sent an NSNumber containing the nc_type value as an integer.  It will automatically convert the number into a string: NC_BYTE, NC_CHAR, NC_SHORT, NC_INT, NC_FLOAT, and NC_DOUBLE.
*/

#import <Foundation/Foundation.h>


@interface NCDFDataTypeFormatter : NSFormatter {

}

@end
