//
//  ImagePickerViewController.h
//  Tinker
//
//  Created by Todd Flom on 2/1/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>



//delegate to return amount entered by the user
@protocol ImagePickerDelegate <NSObject>

-(void) finishedImagePick;

@end




@interface ImagePickerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
//     id<ImagePickerDelegate> delegate;
}


@property (nonatomic, weak) id <ImagePickerDelegate> delegate;

@end
