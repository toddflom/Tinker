//
//  ImagePickerViewController.m
//  Tinker
//
//  Created by Todd Flom on 2/1/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "imageFileWriter.h"


@interface ImagePickerViewController () {
    BOOL newMedia;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)UseImage:(id)sender;




@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;


@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *useImageButton;

@end

@implementation ImagePickerViewController
@synthesize cameraButton;
@synthesize cameraRollButton;
@synthesize cancelButton;
@synthesize useImageButton;

@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setCancelButton:nil];
    [self setUseImageButton:nil];
    [self setCameraButton:nil];
    [self setCameraRollButton:nil];
    [super viewDidUnload];
}



- (IBAction)useCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = YES;
    }
}

- (IBAction)useCameraRoll:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        
    }
}

- (IBAction)cancel:(id)sender {
    imageView.image = nil;
    [self switchControls];
}

- (IBAction)UseImage:(id)sender {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle: nil];
    
    UIViewController *controller = (UIViewController*)[mainStoryboard
                                                       instantiateViewControllerWithIdentifier: @"MaskView"];
    
   [self.navigationController pushViewController:controller animated:YES];
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissModalViewControllerAnimated:YES];
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    imageView.image = pickedImage;
    
    [self switchControls];
    
    if (newMedia) {
        UIImageWriteToSavedPhotosAlbum(pickedImage, self,
                                       @selector(image:finishedSavingWithError:contextInfo:),
                                       nil);
    }
    
    pickedImage = [self scaleAndRotateImage:pickedImage];
    
    [ImageFileWriter setSavedImage: pickedImage];

 //   [ImageFileWriter writeImageToFile:pickedImage];
}



- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 1280; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
   // [self setRotatedImage:imageCopy];
    return imageCopy;
}



- (void) switchControls {
    
    [cameraButton setHidden:!cameraButton.hidden];
    [cameraRollButton setHidden:!cameraRollButton.hidden];
    [cancelButton setHidden:!cancelButton.hidden];
    [useImageButton setHidden:!useImageButton.hidden];

}


-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}




-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissModalViewControllerAnimated:YES];
}


@end










