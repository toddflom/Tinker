//
//  ImageFileWriter.m
//  Tinker
//
//  Created by Todd Flom on 2/2/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//


static NSString *ImageFileName = @"SavedRendering.png";


#import "ImageFileWriter.h"

@implementation ImageFileWriter


@synthesize savedImage, isFirstImgSet;

#pragma mark Singleton Implementation
static ImageFileWriter *sharedObject;
+ (ImageFileWriter*)sharedInstance
{
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;
}



#pragma mark Shared Public Methods
+(BOOL) getSomeData {
    ImageFileWriter *shared = [ImageFileWriter sharedInstance];
    return shared.isFirstImgSet;
}

+(void) setSomeData:(BOOL)isFirstImgSet {
    ImageFileWriter *shared = [ImageFileWriter sharedInstance];
    shared.isFirstImgSet = isFirstImgSet;
}



+(NSString *) getSavedImage {
    ImageFileWriter *shared = [ImageFileWriter sharedInstance];
    return shared.savedImage;
}

+(void) setSavedImage:(NSString *)savedImage {
    ImageFileWriter *shared = [ImageFileWriter sharedInstance];
    shared.savedImage = savedImage;
}



+(void) writeImageToFile:(UIImage *)image {
    
    
   // NSString *imageName = @"OpenGLImage.png";
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString * documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSString *dataPath = [documentsDirectoryPath  stringByAppendingPathComponent:ImageFileName];
    
    NSLog(@"%@", dataPath);
    
    
    NSData* settingsData = UIImagePNGRepresentation(image);
    
    [settingsData writeToFile:dataPath atomically:YES];

}


+(UIImage *) readImageFromFIle {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDir stringByAppendingPathComponent:ImageFileName];
    UIImage *imageFromDisk = [UIImage imageWithContentsOfFile:savedImagePath];
    return imageFromDisk;
}


@end










