//
//  PositionMaskImage_VC.m
//  Tinker
//
//  Created by Todd Flom on 2/4/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//

#import "PositionMaskImage_VC.h"
#import "imageFileWriter.h"


@interface PositionMaskImage_VC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PositionMaskImage_VC

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
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]];
    self.view.backgroundColor = patternColor;

    
    UIImage *startImage = [ImageFileWriter getSavedImage];
    _imageView.image = startImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}
@end
