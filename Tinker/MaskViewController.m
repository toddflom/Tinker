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


//CONSTANTS:

#define kPaletteHeight			30
#define kMinEraseInterval		0.5

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0





@interface MaskViewController () {
    EaglLayerController *shared;
    CFTimeInterval		lastTime;

}

@property (weak, nonatomic) IBOutlet UIButton *eraseButton;
@property (weak, nonatomic) IBOutlet UIButton *redrawButton;
@property (weak, nonatomic) IBOutlet UISwitch *eraseSwitch;
@property (weak, nonatomic) IBOutlet UIButton *getMaskButton;

@property (strong, nonatomic) IBOutlet PaintingView *maskPaintingView;

- (IBAction)eraseBoard:(id)sender;
- (IBAction)redraw:(id)sender;
- (IBAction)eraseSwitchToggle:(id)sender;
- (IBAction)saveImageToAlbum:(id)sender;

@end

@implementation MaskViewController
@synthesize maskPaintingView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect rect = [[UIScreen mainScreen] applicationFrame];


    /*
    // Create a segmented control so that the user can choose the brush color.
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"Red.png"],
                                             [UIImage imageNamed:@"Yellow.png"],
                                             [UIImage imageNamed:@"Green.png"],
                                             [UIImage imageNamed:@"Blue.png"],
                                             [UIImage imageNamed:@"Purple.png"],
                                             nil]];
	
	// Compute a rectangle that is positioned correctly for the segmented control you'll use as a brush color palette
	CGRect frame = CGRectMake(rect.origin.x + kLeftMargin, rect.size.height - kPaletteHeight - kTopMargin, rect.size.width - (kLeftMargin + kRightMargin), kPaletteHeight);
	segmentedControl.frame = frame;
	// When the user chooses a color, the method changeBrushColor: is called.
	[segmentedControl addTarget:self action:@selector(changeBrushColor:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	// Make sure the color of the color complements the black background
	segmentedControl.tintColor = [UIColor lightGrayColor];
	// Set the third color (index values start at 0)
	segmentedControl.selectedSegmentIndex = 2;
	
	// Add the control to the window
	[self.view addSubview:segmentedControl];
    */
    
    
    
    // Create a segmented control so that the user can choose the brush size.
	UISegmentedControl *brushSizeSegControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"brush_small.png"],
                                             [UIImage imageNamed:@"brush_medium.png"],
                                             [UIImage imageNamed:@"brush_large.png"],
                                             nil]];
	
	// Compute a rectangle that is positioned correctly for the segmented control you'll use as a brush color palette
	CGRect frame2 = CGRectMake(rect.origin.x + kLeftMargin, (rect.size.height - 50 - kTopMargin), rect.size.width - (kLeftMargin + kRightMargin), 50);
	brushSizeSegControl.frame = frame2;
	// When the user chooses a color, the method changeBrushColor: is called.
	[brushSizeSegControl addTarget:self action:@selector(changeBrushSize:) forControlEvents:UIControlEventValueChanged];
	brushSizeSegControl.segmentedControlStyle = UISegmentedControlStyleBar;
	// Make sure the color of the color complements the black background
	brushSizeSegControl.tintColor = [UIColor lightGrayColor];
	// Set the third color (index values start at 0)
	brushSizeSegControl.selectedSegmentIndex = 1;
	
	// Add the control to the window
	[self.view addSubview:brushSizeSegControl];

    
    
    
    [maskPaintingView erase];

    shared = [EaglLayerController sharedInstance]; 
    
   // NSMutableArray *colors = shared.startingBrushColor;

//    [self changeBrushColor:segmentedControl];
    
//    [self changeBrushSize:brushSizeSegControl];
    

    [maskPaintingView setBrushColorWithRed:1.0 green:0.0 blue:0.0];
    
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
    
    [maskPaintingView getMaskFromDrawing];
}




@end





