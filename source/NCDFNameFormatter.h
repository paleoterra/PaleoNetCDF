//
//  NCDFNameFormatter.h
//  netcdf
//
//  Created by Tom Moore on Thu Nov 14 2002.
//  Copyright (c) 2002 Argonne National Laboratory. All rights reserved.
//

/*!
	@header
	@class NCDFNameFormatter
	@abstract NCDFNameFormatter is a subclass of NSFormatter designed to turn a number into a byte size report for display.
	@discussion This method is a convenience method for GUI interface elements.  It should be attached to any NSTextField for which a user can define a name of an attribute, dimension, or variable.  This class will prevent the user from passing illegal names.
*/
#import <Foundation/Foundation.h>


@interface NCDFNameFormatter : NSFormatter {

}

-(NSString *)parseNameString:(NSString *)theString;
@end
