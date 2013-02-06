//
//  BaseImageViewController.m
//  Tinker
//
//  Created by Todd Flom on 2/6/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//

#import "BaseImageViewController.h"
#import "ImageFileWriter.h"

@interface BaseImageViewController ()

@end

@implementation BaseImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    ImagePickerViewController * enterAmountVC = [[ImagePickerViewController alloc]init];
    
    enterAmountVC.delegate = self;
}

- (void) finishedImagePick {
    
    [ImageFileWriter setIsFirstImgSet:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    
    UIViewController *controller = (UIViewController*)[mainStoryboard
                                                       instantiateViewControllerWithIdentifier: @"MaskView"];
    
    [self.navigationController pushViewController:controller animated:YES];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
