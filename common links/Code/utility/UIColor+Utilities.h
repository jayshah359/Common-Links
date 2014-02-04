//
//  UIColor+Utilities.h
//  DorkForest
//
//  Created by Jonathan Backer on 2/7/13.
//  Copyright (c) 2013 Jonathan Backer. All rights reserved.
//

#ifndef __UICOLOR_UTILITIES_H__
#define __UICOLOR_UTILITIES_H__

#import <UIKit/UIKit.h>

#if PRAGMA_ONCE
#pragma once
#endif

@interface UIColor (Utilities)

/*
 UIColors must be the same colorspace (RGBA, WhiteA, HSBA)
 */
- (UIColor*)colorBetweenColor:(UIColor*)color;
- (UIColor*)colorByAdjustingBrightnessPercentage:(CGFloat)percentage;

/*!
 Returns a color based on the given hexadecimal color string.
 
 Examples of the format are #RGB, #ARGB, #RRGGB, and #AARRGGBB, where R, G, and B are hexadecimal characters (0-F) representing
 red, green, and blue channels respectively.  The A value is optional and represents the alpha (transparency) component of the
 color.  If the color cannot be parsed from the given string, black is returned.  The leading # character is optional.
 @param hexString A string of hexadecimal color values.
 @return Returns the color based on the hexadecimal color string.
 */
+ (UIColor*)colorWithHexString:(NSString*)hexString;
+ (UIColor*)colorWithHexString:(NSString*)hexString alpha:(CGFloat)alpha;

@end

#endif
