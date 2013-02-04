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

@implementation PositionMaskImage_VC {
    
    float mCurrentScale;
    float mLastScale;
    
}


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
    
    [self startMoveImage];

}




-(void)handlePinch:(UIPinchGestureRecognizer*)sender {
    
//    NSLog(@"latscale = %f",mLastScale);
    
    mCurrentScale += [sender scale] - mLastScale;
    mLastScale = [sender scale];
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        mLastScale = 1.0;
    }
    
    CGAffineTransform currentTransform = CGAffineTransformIdentity;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform,mCurrentScale, mCurrentScale);
    _imageView.transform = newTransform;
    
}




-(void) startMoveImage{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    //Zoom Photo
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchGesture];
    mCurrentScale = 0;
    mLastScale = 0;

}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        
        CGPoint position = [gesture locationInView:[_imageView superview]];
        [_imageView setCenter:position];
    }
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
