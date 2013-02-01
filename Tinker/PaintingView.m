

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "PaintingView.h"



#define ROUND_UP(N, S) ((((N) + (S) - 1) / (S)) * (S))


//CLASS IMPLEMENTATIONS:

// A class extension to declare private methods
@interface PaintingView (private)

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (UIImage *) drawableToCGImage;

@end

@implementation PaintingView

@synthesize  location;
@synthesize  previousLocation;
//@synthesize recordingArray;

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    	
//	NSMutableArray*	recordedPaths;
	CGImageRef		brushImage;
	CGContextRef	brushContext;
	GLubyte			*brushData;
	size_t			width, height;
    
    if ((self = [super initWithCoder:coder])) {
        
        self.alpha = 0.5f;
        
//        recordingArray = [[NSMutableArray alloc]init];
        
        brushScale = 2;
        
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		//eaglLayer.opaque = YES;
        eaglLayer.opaque = NO;
		// In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if (!context || ![EAGLContext setCurrentContext:context]) {
		//	[self release];
			return nil;
		}
		
		// Create a texture from an image
		// First create a UIImage object from the data in a image file, and then extract the Core Graphics image
		brushImage = [UIImage imageNamed:@"Particle.png"].CGImage;
		
		// Get the width and height of the image
		width = CGImageGetWidth(brushImage);
		height = CGImageGetHeight(brushImage);
		
		// Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
		// you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.
		
		// Make sure the image exists
		if(brushImage) {
			// Allocate  memory needed for the bitmap context
			brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
			// Use  the bitmatp creation function provided by the Core Graphics framework. 
			brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
			// After you create the context, you can draw the  image to the context.
			CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
			// You don't need the context at this point, so you need to release it to avoid memory leaks.
			CGContextRelease(brushContext);
			// Use OpenGL ES to generate a name for the texture.
			glGenTextures(1, &brushTexture);
			// Bind the texture name. 
			glBindTexture(GL_TEXTURE_2D, brushTexture);
			// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			// Specify a 2D texture image, providing the a pointer to the image data in memory
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
			// Release  the image data; it's no longer needed
            free(brushData);
		}
		
		// Set the view's scale factor
		self.contentScaleFactor = 1.0;
	
		// Setup OpenGL states
		glMatrixMode(GL_PROJECTION);
		CGRect frame = self.bounds;
		CGFloat scale = self.contentScaleFactor;
		// Setup the view port in Pixels
		glOrthof(0, frame.size.width * scale, 0, frame.size.height * scale, -1, 1);
		glViewport(0, 0, frame.size.width * scale, frame.size.height * scale);
		glMatrixMode(GL_MODELVIEW);
		
		glDisable(GL_DITHER);
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		
	    glEnable(GL_BLEND);
		// Set a blending function appropriate for premultiplied alpha pixel data
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		
		glEnable(GL_POINT_SPRITE_OES);
		glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
        //    glPointSize(width / kBrushScale);
		glPointSize(width / brushScale);
		
		// Make sure to start with a cleared buffer
		needsErase = YES;
		
		// Playback recorded path, which is "Shake Me"
	//	recordedPaths = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Recording" ofType:@"data"]];
	//	if([recordedPaths count])
	//		[self performSelector:@selector(playback:) withObject:recordedPaths afterDelay:0.2];
	}
	
	return self;
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	
	// Clear the framebuffer the first time it is allocated
	if (needsErase) {
		[self erase];
		needsErase = NO;
	}
}

- (BOOL)createFramebuffer
{
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

// Releases resources when they are not longer needed.
- (void) dealloc
{
	if (brushTexture)
	{
		glDeleteTextures(1, &brushTexture);
		brushTexture = 0;
	}
	
	if([EAGLContext currentContext] == context)
	{
		[EAGLContext setCurrentContext:nil];
	}
	
	//[context release];
	//[super dealloc];
}

// Erases the screen
- (void) erase
{
	[EAGLContext setCurrentContext:context];
	
	// Clear the buffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

// Drawings a line onscreen based on where the user touches
- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
	static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0,
						count,
						i;
	
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	// Convert locations from Points to Pixels
	CGFloat scale = self.contentScaleFactor;
	start.x *= scale;
	start.y *= scale;
	end.x *= scale;
	end.y *= scale;
	
	// Allocate vertex array buffer
	if(vertexBuffer == NULL)
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
	
	// Add points to the buffer so there are drawing points every X pixels
	count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
	for(i = 0; i < count; ++i) {
		if(vertexCount == vertexMax) {
			vertexMax = 2 * vertexMax;
			vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
		}
		
		vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
		vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
		vertexCount += 1;
	}
	
	// Render the vertex array
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
	glDrawArrays(GL_POINTS, 0, vertexCount);
	
	// Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


/*
- (void)playRecordedData {
    
    if(recordingArray != NULL){
        
        for(int l = 0; l < [recordingArray count]; l++){
            //replays my writRay -1 because of location point
            for(int p = 0; p < [[recordingArray objectAtIndex:l]count] -1; p ++){
                [self renderLineFromPoint:[[[recordingArray objectAtIndex:l]objectAtIndex:p]CGPointValue] toPoint:[[[recordingArray objectAtIndex:l]objectAtIndex:p + 1]CGPointValue]];
            }
        }
    }
}
 */


/*
// Reads previously recorded points and draws them onscreen. This is the Shake Me message that appears when the application launches.
- (void) playback:(NSMutableArray*)recordedPaths
{
	NSData*				data = [recordedPaths objectAtIndex:0];
	CGPoint*			point = (CGPoint*)[data bytes];
	NSUInteger			count = [data length] / sizeof(CGPoint),
						i;
	
	// Render the current path
	for(i = 0; i < count - 1; ++i, ++point)
		[self renderLineFromPoint:*point toPoint:*(point + 1)];
	
	// Render the next path after a short delay 
	[recordedPaths removeObjectAtIndex:0];
	if([recordedPaths count])
		[self performSelector:@selector(playback:) withObject:recordedPaths afterDelay:0.01];
}
*/


// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGRect				bounds = [self bounds];
    UITouch*	touch = [[event touchesForView:self] anyObject];
	firstTouch = YES;
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
	location = [touch locationInView:self];
	location.y = bounds.size.height - location.y;
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  
   	  
	CGRect				bounds = [self bounds];
	UITouch*			touch = [[event touchesForView:self] anyObject];
		
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
	if (firstTouch) {
		firstTouch = NO;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
        
//        /******************* create a new array for this stroke's points **************/
//        [recordingArray addObject:[[NSMutableArray alloc]init]];
//        /***** add 1st point *********/
//        [[recordingArray objectAtIndex:[recordingArray count] -1]addObject:[NSValue valueWithCGPoint:previousLocation]];

	} else {
		location = [touch locationInView:self];
	    location.y = bounds.size.height - location.y;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
        
//        /********* add additional points *********/
//        [[recordingArray objectAtIndex:[recordingArray count] -1]addObject:[NSValue valueWithCGPoint:previousLocation]];
        
    }
		
	// Render the stroke
	[self renderLineFromPoint:previousLocation toPoint:location];
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGRect				bounds = [self bounds];
    UITouch*	touch = [[event touchesForView:self] anyObject];
	if (firstTouch) {
		firstTouch = NO;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
		[self renderLineFromPoint:previousLocation toPoint:location];
	}
    
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	// If appropriate, add code necessary to save the state of the application.
	// This application is not saving state.
    
    
}



- (void) getMaskFromDrawing {
    
  // UIImage *image = [self drawableToCGImage];
    
     UIImage *imageOrig = [self glToUIImage];
    
    UIImage *image = [self seperatAlphaFromImage:imageOrig];
    
    
  // UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    
    NSString *imageName = @"OpenGLImage.png";
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString * documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSString *dataPath = [documentsDirectoryPath  stringByAppendingPathComponent:imageName];
    
    NSLog(@"%@", dataPath);

    
    NSData* settingsData = UIImagePNGRepresentation(image);
    
    [settingsData writeToFile:dataPath atomically:YES];

}




- (UIImage *) glToUIImage {
    NSInteger myDataLength = 320 * 480 * 4;
	
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, 320, 480, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
	
    // gl renders \"upside down\" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y <480; y++)
    {
        for(int x = 0; x <320 * 4; x++)
        {
            buffer2[(479 - y) * 320 * 4 + x] = buffer[y * 4 * 320 + x];
        }
    }
	
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
	
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * 320;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	
    //xxxxxx This is the line of code that I found in multiple solutions throughout the web but doesn't deal with the transparency
    // CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    //xxxxxx
    
    //*******This is the code I used to handle the tranparency!!!
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    //*******
    
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(320, 480, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
	
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save the image in the photo album"
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    else
        alert = [[UIAlertView alloc] initWithTitle:@"Succes"
                                           message:@"The image has been saved."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    [alert show];
   // [alert release];
}



- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
	// Set the brush color using premultiplied alpha values
	glColor4f(red	* kBrushOpacity,
			  green * kBrushOpacity,
			  blue	* kBrushOpacity,
			  kBrushOpacity);
}


- (void)setBrushSize:(NSInteger)num {
    switch (num) {
        case 0:
            brushScale = 4;
            break;
        case 1:
            brushScale = 2;
            break;
        case 2:
            brushScale = 1;
            break;
            
        default:
            break;
    }
    
    CGImageRef brushImage2 = [UIImage imageNamed:@"Particle.png"].CGImage;
    
    // Get the width and height of the image
    CGFloat width = CGImageGetWidth(brushImage2);
    glPointSize(width / brushScale);
}



-(UIImage *) drawableToCGImage 
{
    GLint backingWidth2, backingHeight2;
    //Bind the color renderbuffer used to render the OpenGL ES view
    // If your application only creates a single color renderbuffer which is already bound at this point,
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    // Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth2);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight2);
    
    NSInteger x = 0, y = 0, width2 = backingWidth2, height2 = backingHeight2;
    NSInteger dataLength = width2 * height2 * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width2, height2, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width2, height2, 8, 32, width2 * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        CGFloat scale = self.contentScaleFactor;
        widthInPoints = width2 / scale;
        heightInPoints = height2 / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        widthInPoints = width2;
        heightInPoints = height2;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
 //   CGImageRef finalMaskImage = [self createMaskWithImageAlpha:cgcontext];

 //   UIImage *maskImage = [UIImage imageWithCGImage:finalMaskImage];
 //   [self imageDump:finalMaskImage];

    
    UIImage *maskImage = [self seperatAlphaFromImage:image];
    
    
    
    
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    
 //   CGImageRelease(finalMaskImage);

    
    
  //  UIImage *flippedImg = [self flipImageVertically:image];
    
//    return image;
    return maskImage;
}




- (UIImage*)seperatAlphaFromImage:(UIImage*)pngImage
{
    CGRect imageRect = CGRectMake(0, 0, pngImage.size.width, pngImage.size.height);
    
    //Pixel Buffer
    uint32_t* piPixels = (uint32_t*)malloc(imageRect.size.width * imageRect.size.height * sizeof(uint32_t));
    if (piPixels == NULL)
    {
        return nil;
    }
    memset(piPixels, 0, imageRect.size.width * imageRect.size.height * sizeof(uint32_t));
    
    //Drawing image in the buffer
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context2 = CGBitmapContextCreate(piPixels, imageRect.size.width, imageRect.size.height, 8, sizeof(uint32_t) * imageRect.size.width, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    
    CGContextSetFillColorWithColor(context2, [[UIColor blackColor] CGColor]);
    CGContextFillRect(context2, imageRect );
    
    
    CGContextDrawImage(context2, imageRect, pngImage.CGImage);
    
    //Copying the alpha values to the red values of the image and setting the alpha to 1
    for (uint32_t y = 0; y < imageRect.size.height; y++)
    {
        for (uint32_t x = 0; x < imageRect.size.width; x++)
        {
            uint8_t* rgbaValues = (uint8_t*)&piPixels[y * (uint32_t)imageRect.size.width + x];
            
            //alpha = 0, red = 1, green = 2, blue = 3.
            
            rgbaValues[0] = rgbaValues[0];
            rgbaValues[1] = rgbaValues[3];
            rgbaValues[2] = rgbaValues[3];
            rgbaValues[3] = rgbaValues[3];
        }
    }
    
    //Creating image whose red values will preserve the alpha values
    CGImageRef newCGImage = CGBitmapContextCreateImage(context2);
    UIImage* newImage = [[UIImage alloc] initWithCGImage:newCGImage];
    CGImageRelease(newCGImage);
    
    return newImage;    
}






- (CGImageRef) createMaskWithImageAlpha: (CGContextRef) originalImageContext {
    
    UInt8 *data = (UInt8 *)CGBitmapContextGetData(originalImageContext);
    
    float width = CGBitmapContextGetBytesPerRow(originalImageContext) / 4;
    float height = CGBitmapContextGetHeight(originalImageContext);
    
    // Make a bitmap context that's only 1 alpha channel
    // WARNING: the bytes per row probably needs to be a multiple of 4
    int strideLength = ROUND_UP(width * 1, 4);
    unsigned char * alphaData = (unsigned char * )calloc(strideLength * height, 1);
    CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData,
                                                          width,
                                                          height,
                                                          8,
                                                          strideLength,
                                                          NULL,
                                                          kCGImageAlphaOnly);
    
    // Draw the RGBA image into the alpha-only context.
    //CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), originalMaskImage);
    
    // Walk the pixels and invert the alpha value. This lets you colorize the opaque shapes in the original image.
    // If you want to do a traditional mask (where the opaque values block) just get rid of these loops.
    
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            //unsigned char val = alphaData[y*strideLength + x];
            unsigned char val = data[y*(int)width*4 + x*4 + 3];
            val = 255 - val;
            alphaData[y*strideLength + x] = val;
        }
    }
    
    
    CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
    CGContextRelease(alphaOnlyContext);
    free(alphaData);
    
    // Make a mask
    CGImageRef finalMaskImage = CGImageMaskCreate(CGImageGetWidth(alphaMaskImage),
                                                  CGImageGetHeight(alphaMaskImage),
                                                  CGImageGetBitsPerComponent(alphaMaskImage),
                                                  CGImageGetBitsPerPixel(alphaMaskImage),
                                                  CGImageGetBytesPerRow(alphaMaskImage),
                                                  CGImageGetDataProvider(alphaMaskImage),     NULL, false);
    CGImageRelease(alphaMaskImage);
    
    return finalMaskImage;
}







@end
