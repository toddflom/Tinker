//
//  ViewController.m
//  Tinker
//
//  Created by Todd Flom on 1/30/13.
//  Copyright (c) 2013 Carmichael Lynch. All rights reserved.
//

#import "ViewController.h"
#import "PaintingView.h"
#import "EaglLayerController.h"


//CONSTANTS:

#define kPaletteHeight			30

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0




@interface ViewController ()

@property (weak, nonatomic) IBOutlet PaintingView *maskPaintingView;

@end

@implementation ViewController
@synthesize maskPaintingView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect rect = [[UIScreen mainScreen] applicationFrame];

    
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
	segmentedControl.tintColor = [UIColor darkGrayColor];
	// Set the third color (index values start at 0)
	segmentedControl.selectedSegmentIndex = 2;
	
	// Add the control to the window
	[self.view addSubview:segmentedControl];

    EaglLayerController *shared = [EaglLayerController sharedInstance]; 
    
    NSMutableArray *colors = shared.startingBrushColor;
        
    [maskPaintingView setBrushColorWithRed:[colors objectAtIndex:0] green:[colors objectAtIndex:1] blue:[colors objectAtIndex:2]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMaskPaintingView:nil];
    [super viewDidUnload];
}
@end
