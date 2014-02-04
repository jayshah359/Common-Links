//
//  UIColor+Utilities.m
//  DorkForest
//
//  Created by Jonathan Backer on 2/7/13.
//  Copyright (c) 2013 Jonathan Backer. All rights reserved.
//

#import "UIColor+Utilities.h"

@implementation UIColor (Utilities)

- (UIColor*)colorBetweenColor:(UIColor*)color {
    UIColor* retVal = self;
    
    if (color != nil) {
        CGFloat red1, green1, blue1, alpha1, white1, hue1, sat1, bright1;
        CGFloat red2, green2, blue2, alpha2, white2, hue2, sat2, bright2;
        
        if ([self getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1] && [color getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2]) {
            // RGB colors converted successfully
            // calculate middle color
            retVal = [UIColor colorWithRed:[self clampValue:(red1 + red2) / 2.0     from:0.0 to:1.0]
                                     green:[self clampValue:(green1 + green2) / 2.0 from:0.0 to:1.0]
                                      blue:[self clampValue:(blue1 + blue2) / 2.0   from:0.0 to:1.0]
                                     alpha:[self clampValue:(alpha1 + alpha2) / 2.0 from:0.0 to:1.0]];
            
        } else if ([self getWhite:&white1 alpha:&alpha1] && [color getWhite:&white2 alpha:&alpha2]) {
            // WHITE colors converted successfully
            // calculate middle color
            retVal = [UIColor colorWithWhite:[self clampValue:(white1 + white2) / 2.0 from:0.0 to:1.0]
                                       alpha:[self clampValue:(alpha1 + alpha2) / 2.0 from:0.0 to:1.0]];
            
        } else if ([self getHue:&hue1 saturation:&sat1 brightness:&bright1 alpha:&alpha1] && [color getHue:&hue2 saturation:&sat2 brightness:&bright2 alpha:&alpha2]) {
            // HSB colors converted successfully
            // calculate middle color
            retVal = [UIColor colorWithHue:[self clampValue:(hue1 + hue2) / 2.0         from:0.0 to:1.0]
                                saturation:[self clampValue:(sat1 + sat2) / 2.0         from:0.0 to:1.0]
                                brightness:[self clampValue:(bright1 + bright2) / 2.0   from:0.0 to:1.0]
                                     alpha:[self clampValue:(alpha1 + alpha2) /2.0      from:0.0 to:1.0]];
        }
    }
    
    return retVal;
}

- (UIColor*)colorByAdjustingBrightnessPercentage:(CGFloat)percentage {
    UIColor* retVal = self;
    
    CGFloat red, green, blue, alpha, white, hue, sat, bright;
    
    // convert colors
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        // RGB colors converted successfully
        // calculate adjusted color
        retVal = [UIColor colorWithRed:[self clampValue:red * percentage from:0.0 to:1.0]
                                 green:[self clampValue:green * percentage from:0.0 to:1.0]
                                  blue:[self clampValue:blue * percentage from:0.0 to:1.0]
                                 alpha:alpha];
    } else if ([self getWhite:&white alpha:&alpha]) {
        // WHITE colors converted successfully
        // calculate adjusted color
        retVal = [UIColor colorWithWhite:[self clampValue:white * percentage from:0.0 to:1.0]
                                   alpha:alpha];
    } else if ([self getHue:&hue saturation:&sat brightness:&bright alpha:&alpha]) {
        // HSB colors converted successfully
        // calculate adjusted color
        retVal = [UIColor colorWithHue:hue
                            saturation:sat
                            brightness:[self clampValue:bright * percentage from:0.0 to:1.0]
                                 alpha:alpha];
    }
    
    return retVal;
}

- (CGFloat)clampValue:(CGFloat)value from:(CGFloat)fromValue to:(CGFloat)toValue {
    CGFloat retVal = value;
    
    if (retVal < fromValue) {
        retVal = fromValue;
    } else if (retVal > toValue) {
        retVal = toValue;
    }
    
    return retVal;
}

+ (UIColor*)colorWithHexString:(NSString*)hexString {
    return [[self class] colorWithHexString:hexString alpha:1.0];
}

+ (UIColor*)colorWithHexString:(NSString*)hexString alpha:(CGFloat)alpha {
    // remove # from color
    NSString* colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat calpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            calpha = alpha;
            red   = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue  = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            calpha = [self colorComponentFrom:colorString start:0 length:1];
            red   = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue  = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            calpha = alpha;
            red   = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue  = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            calpha = [self colorComponentFrom:colorString start:0 length:2];
            red   = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue  = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            // nil color does not show error
            if (hexString != nil) {
                NSLog(@"Error: Color \"%@\" is invalid. Use hex value forms: #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            }
            // cannot parse, use black as default
            calpha = alpha;
            red =   0.0f;
            green = 0.0f;
            blue =  0.0f;
            break;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:calpha];
}

+ (CGFloat)colorComponentFrom:(NSString*)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end
