//
//  EaglLayerController.h
//  Tinker
//
//  Created by Todd Flom on 1/30/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PaintingView;

@interface EaglLayerController : NSObject {
    // Instance variables:
    //   - Declare as usual.  The alloc/sharedIntance.
    NSString *someData;

	PaintingView        *drawingView;
    

}

// Properties as usual
@property (nonatomic, retain) NSString *someData;

@property (nonatomic, retain) IBOutlet PaintingView *drawingView;



// Required: A method to retrieve the shared instance
+(EaglLayerController *) sharedInstance;


// Shared Public Methods:
//   - Using static methods for opertations is a nice convenience
//   - Each method should ensure it is using the above sharedInstance
+(NSString *) getSomeData;
+(void) setSomeData:(NSString *)someData;


- (NSMutableArray *) getNewBrushColorWithHue:(NSInteger)senderID;
// Instance Methods: Declare and implement as usual




@end
