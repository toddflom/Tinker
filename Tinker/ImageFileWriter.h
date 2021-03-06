//
//  ImageFileWriter.h
//  Tinker
//
//  Created by Todd Flom on 2/2/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageFileWriter : NSObject {
    // Instance variables:
    //   - Declare as usual.  The alloc/sharedIntance.
    UIImage *savedImage;
    BOOL isFirstImgSet;
}

// Properties as usual
@property (nonatomic, retain) UIImage *savedImage;
@property (nonatomic, readwrite) BOOL isFirstImgSet;

// Required: A method to retrieve the shared instance
+(ImageFileWriter *) sharedInstance;


// Shared Public Methods:
//   - Using static methods for opertations is a nice convenience
//   - Each method should ensure it is using the above sharedInstance
+(BOOL) getIsFirstImgSet;
+(void) setIsFirstImgSet:(BOOL)isFirstImgSet;

+(UIImage *) getSavedImage;
+(void) setSavedImage:(UIImage *)savedImage;


+(void) writeImageToFile:(UIImage *)image;
+(UIImage *) readImageFromFIle;

// Instance Methods: Declare and implement as usual
@end
