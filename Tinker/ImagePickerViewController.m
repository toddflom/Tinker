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
- (IBAction)switchImage:(id)sender;
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


- (IBAction)switchImage:(id)sender {
    [imageView setImage:[UIImage imageNamed:@"mickiWithArragement.jpg"]];

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
    
//    controller.controlFlag = YES;
//    controller.controlFlag2 = NO; // Just examples
    
    //These flags will be set before the viewDidLoad of MenuScreenViewController
    //Therefore any code you write before pushing or presenting the view will be present after
    
   [self.navigationController pushViewController:controller animated:YES];
   // [self presentViewController:controller animated:YES];
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
    
    [ImageFileWriter setSavedImage: pickedImage];

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










