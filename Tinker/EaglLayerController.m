//
//  EaglLayerController.m
//  Tinker
//
//  Created by Todd Flom on 1/30/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//

#import "EaglLayerController.h"



//CONSTANTS:

#define kPaletteSize			5


//CONSTANTS:

#define kLuminosity			0.75
#define kSaturation			1.0



//FUNCTIONS:
/*
 HSL2RGB Converts hue, saturation, luminance values to the equivalent red, green and blue values.
 For details on this conversion, see Fundamentals of Interactive Computer Graphics by Foley and van Dam (1982, Addison and Wesley)
 You can also find HSL to RGB conversion algorithms by searching the Internet.
 See also http://en.wikipedia.org/wiki/HSV_color_space for a theoretical explanation
 */
static void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
	float			temp1,
    temp2;
	float			temp[3];
	int				i;
	
	// Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
	if(s == 0.0) {
		if(outR)
			*outR = l;
		if(outG)
			*outG = l;
		if(outB)
			*outB = l;
		return;
	}
	
	// Test for luminance and compute temporary values based on luminance and saturation
	if(l < 0.5)
		temp2 = l * (1.0 + s);
	else
		temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;
	
	// Compute intermediate values based on hue
	temp[0] = h + 1.0 / 3.0;
	temp[1] = h;
	temp[2] = h - 1.0 / 3.0;
    
	for(i = 0; i < 3; ++i) {
		
		// Adjust the range
		if(temp[i] < 0.0)
			temp[i] += 1.0;
		if(temp[i] > 1.0)
			temp[i] -= 1.0;
		
		
		if(6.0 * temp[i] < 1.0)
			temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
		else {
			if(2.0 * temp[i] < 1.0)
				temp[i] = temp2;
			else {
				if(3.0 * temp[i] < 2.0)
					temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
				else
					temp[i] = temp1;
			}
		}
	}
	
	// Assign temporary values to R, G, B
	if(outR)
		*outR = temp[0];
	if(outG)
		*outG = temp[1];
	if(outB)
		*outB = temp[2];
}





@implementation EaglLayerController

@synthesize drawingView;


@synthesize someData;



#pragma mark Singleton Implementation

static EaglLayerController *sharedObject;

+ (EaglLayerController*)sharedInstance
{
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;
}


#pragma mark Shared Public Methods
+(NSString *) getSomeData {
    // Ensure we are using the shared instance
    EaglLayerController *shared = [EaglLayerController sharedInstance];
    return shared.someData;
}

+(void) setSomeData:(NSString *)someData {
    // Ensure we are using the shared instance
    EaglLayerController *shared = [EaglLayerController sharedInstance];
    shared.someData = someData;
}



// Change the brush color
- (NSMutableArray *) getNewBrushColorWithHue:(NSInteger)senderID {
    
    
    
    NSLog(@"Red: %f, Blue: %f, Green: %f", (CGFloat)senderID, kSaturation, kLuminosity);

    
    CGFloat	components[3];
    // Define a starting color
	HSL2RGB((CGFloat)senderID / (CGFloat)kPaletteSize , kSaturation, kLuminosity, &components[0], &components[1], &components[2]);
    
    NSMutableArray *arrayPoints = [[NSMutableArray alloc]init];
    [arrayPoints addObject:[NSNumber numberWithFloat:components[0]]];
    [arrayPoints addObject:[NSNumber numberWithFloat:components[1]]];
    [arrayPoints addObject:[NSNumber numberWithFloat:components[2]]];
    
    return arrayPoints;
    
}



@end
