//
//  ViewController.m
//  Tinker
//
//  Created by Todd Flom on 1/30/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//

#import "MaskViewController.h"
#import "PaintingView.h"
#import "EaglLayerController.h"
#import "imageFileWriter.h"


//CONSTANTS:

#define kPaletteHeight			30
#define kMinEraseInterval		0.5

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0


#define radians( degrees ) ( ( degrees ) / 180.0 * M_PI )



@interface MaskViewController () {
    EaglLayerController *shared;
    CFTimeInterval		lastTime;

}

@property (weak, nonatomic) IBOutlet UIButton *eraseButton;
@property (weak, nonatomic) IBOutlet UIButton *redrawButton;
@property (weak, nonatomic) IBOutlet UISwitch *eraseSwitch;
@property (weak, nonatomic) IBOutlet UIButton *getMaskButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;


@property (strong, nonatomic) IBOutlet PaintingView *maskPaintingView;

- (IBAction)eraseBoard:(id)sender;
- (IBAction)redraw:(id)sender;
- (IBAction)eraseSwitchToggle:(id)sender;
- (IBAction)saveImageToAlbum:(id)sender;

@end

@implementation MaskViewController
@synthesize imageView = _imageView;
@synthesize maskPaintingView;


/*
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
*/


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
                                            
    
    CGRect rect = [[UIScreen mainScreen] applicationFrame];

    UIImage *startImage = [ImageFileWriter getSavedImage];
    _imageView.image = startImage;
    
    
    // Create a segmented control so that the user can choose the brush size.
	UISegmentedControl *brushSizeSegControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"brush_small.png"],
                                             [UIImage imageNamed:@"brush_medium.png"],
                                             [UIImage imageNamed:@"brush_large.png"],
                                             nil]];
	
	// Compute a rectangle that is positioned correctly for the segmented control you'll use as a brush size palette
	CGRect frame2 = CGRectMake(rect.origin.x + kLeftMargin, (rect.size.height - 50 - kTopMargin), rect.size.width - (kLeftMargin + kRightMargin), 50);
	brushSizeSegControl.frame = frame2;
	// When the user chooses a size, the method changeBrushSize: is called.
	[brushSizeSegControl addTarget:self action:@selector(changeBrushSize:) forControlEvents:UIControlEventValueChanged];
	brushSizeSegControl.segmentedControlStyle = UISegmentedControlStyleBar;
	// Make sure the color of the color complements the black background
	brushSizeSegControl.tintColor = [UIColor lightGrayColor];
	// Set the middle brush size (index values start at 0)
	brushSizeSegControl.selectedSegmentIndex = 1;
	
	// Add the control to the window
	[self.view addSubview:brushSizeSegControl];

    
    
    
    [maskPaintingView erase];

    shared = [EaglLayerController sharedInstance]; 
    
   // NSMutableArray *colors = shared.startingBrushColor;

//    [self changeBrushColor:segmentedControl];
    
//    [self changeBrushSize:brushSizeSegControl];
    

    [maskPaintingView setBrushColorWithRed:1.0 green:0.0 blue:0.0];
    
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(_imageView.bounds)/imageSize.width, CGRectGetHeight(_imageView.bounds)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(floorf(0.5f*(CGRectGetWidth(_imageView.bounds)-scaledImageSize.width)), floorf(0.5f*(CGRectGetHeight(_imageView.bounds)-scaledImageSize.height)), scaledImageSize.width, scaledImageSize.height);
    NSLog(@"%@", NSStringFromCGRect(imageFrame));
    
    maskPaintingView.frame = CGRectMake( maskPaintingView.frame.origin.x + imageFrame.origin.x , maskPaintingView.frame.origin.y + imageFrame.origin.y, imageFrame.size.width, imageFrame.size.height );
    
}


- (void) changeBrushSize:(id)sender {
    
     [maskPaintingView setBrushSize:[sender selectedSegmentIndex]];
}



- (void) changeBrushColor:(id)sender {
    NSMutableArray *colors = [shared getNewBrushColorWithHue:[sender selectedSegmentIndex]];
    
    [maskPaintingView setBrushColorWithRed:[[colors objectAtIndex:0] floatValue]  green:[[colors objectAtIndex:1] floatValue] blue:[[colors objectAtIndex:2] floatValue]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setMaskPaintingView:nil];
    [self setEraseButton:nil];
    [self setRedrawButton:nil];
    [self setEraseSwitch:nil];
    [self setGetMaskButton:nil];
    [self setImageView:nil];
    [self setBackgroundView:nil];
    [super viewDidUnload];
}


- (IBAction)eraseBoard:(id)sender {
    if(CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval) {
        [maskPaintingView erase];
        lastTime = CFAbsoluteTimeGetCurrent();
    }
}

- (IBAction)redraw:(id)sender {
//    [maskPaintingView playRecordedData];
}

- (IBAction)eraseSwitchToggle:(UISwitch *)sender {
    
    if (sender.on) {
        glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
    } else {
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    }
        
}

- (IBAction)saveImageToAlbum:(id)sender {
    CGSize siz = _imageView.image.size;
    
    
  
    

    CGImageRef maskRef = [maskPaintingView getMaskFromDrawing:siz].CGImage;
 //   CGImageRef maskRef = [UIImage imageNamed:@"mask.png"].CGImage;
   

    
    UIImage *inputImage = _imageView.image;
	
// Isn't needed, maskRef is already built using  CGImageMaskCreate
//    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
//                                        CGImageGetHeight(maskRef),
//                                        CGImageGetBitsPerComponent(maskRef),
//                                        CGImageGetBitsPerPixel(maskRef),
//                                        CGImageGetBytesPerRow(maskRef),
//                                        CGImageGetDataProvider(maskRef), NULL, false);

    CGImageRef masked = CGImageCreateWithMask([inputImage CGImage], maskRef);
//    CGImageRelease(mask);
    
    
  //  [inputImage rotate:UIImageOrientationLeft];
    
    
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
 //   UIImage *maskedImage = [self maskImage:inputImage withMask:[maskPaintingView getMaskFromDrawing:siz]];
    
    CGImageRelease(masked);
    
    
    [maskPaintingView erase];
    
    [ImageFileWriter setSavedImage:maskedImage];
    
    _imageView.image = maskedImage;
//    _imageView.image = [ImageFileWriter getSavedImage];

  //  [ImageFileWriter writeImageToFile:maskedImage];
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    
    UIViewController *controller = (UIViewController*)[mainStoryboard
                                                       instantiateViewControllerWithIdentifier: @"PositionMask"];
        
    [self.navigationController pushViewController:controller animated:YES];
    
    
    

}




// This is what we have to do if the image comes directly from UIPicker (it's rotated 
/*
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //UIImage *maskImage = [UIImage imageNamed:@"mask.png"];
    CGImageRef maskImageRef = [maskImage CGImage];
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGFloat ratio = 0;
    
    ratio = image.size.width/ maskImage.size.width;
    
    if(ratio *  maskImage.size.height < image.size.height) {
        ratio = image.size.width/ maskImage.size.width;
    }
    
//    CGRect rect1  = {{0, 0}, {image.size.width, image.size.height}};
    CGRect rect1  = {{0, 0}, {image.size.height, image.size.width}};
    CGRect rect2  = {{-((maskImage.size.width*ratio)-image.size.width)/2 , -((maskImage.size.height*ratio)-image.size.height)/2}, {maskImage.size.width*ratio, maskImage.size.height*ratio}};
    
    
    CGContextClipToMask(mainViewContentContext, rect2, maskImageRef);
    
    CGContextRotateCTM (mainViewContentContext, radians(270)); // rotating -90
    CGContextTranslateCTM(mainViewContentContext, -image.size.height, 0); // -rect2.size.height); // to bring the image back into the context
    
    CGContextDrawImage(mainViewContentContext, rect1, image.CGImage);
    
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    // return the image
    return theImage;
}
*/






- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
      
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //UIImage *maskImage = [UIImage imageNamed:@"mask.png"];
    CGImageRef maskImageRef = [maskImage CGImage];
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, maskImage.size.width, maskImage.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGFloat ratio = 0;
    
    ratio = maskImage.size.width/ image.size.width;
    
  //  NSLog(@"maskimage width: %f, height: %f", maskImage.size.width, maskImage.size.height);
    
    if(ratio * image.size.height < maskImage.size.height) {
        ratio = maskImage.size.height/ image.size.height;
    }
    
    CGRect rect1  = {{0, 0}, {maskImage.size.width, maskImage.size.height}};
//    CGRect rect2  = {{-((image.size.width*ratio)-maskImage.size.width)/2 , -((image.size.height*ratio)-maskImage.size.height)/2}, {image.size.width*ratio, image.size.height*ratio}};
    CGRect rect2  = {{-((image.size.height*ratio)-maskImage.size.width)/2 , -((image.size.width*ratio)-maskImage.size.height)/2}, {image.size.height*ratio, image.size.width*ratio}}; // because we are rotating
    
    
    CGContextClipToMask(mainViewContentContext, rect1, maskImageRef);
    
  //  CGContextRotateCTM (mainViewContentContext, radians(270)); // rotating -90
  //  CGContextTranslateCTM(mainViewContentContext, -400.0, -60.0); // -rect2.size.height); // to bring the image back into the context
    
    CGContextDrawImage(mainViewContentContext, rect2, image.CGImage);
        
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    // return the image
    return theImage;
}







@end





