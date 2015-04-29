//
//  ViewController.m
//  FFBarcodeScanner
//
//  Created by Felix Ayala on 4/29/15.
//  Copyright (c) 2015 Felix Ayala. All rights reserved.
//

#import "ViewController.h"
@import AVFoundation;

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic) BOOL isReading;
@property (nonatomic) BOOL canScan;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Initially make the captureSession object nil.
	self.captureSession = nil;
	
	// Set vars
	self.isReading = NO;
	self.canScan = YES;
	
	[self startReading];
}
#pragma mark - Private method implementation
- (BOOL)startReading {
	NSError *error;
	
	// Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
	// as the media type parameter.
	AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	// Get an instance of the AVCaptureDeviceInput class using the previous device object.
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
	
	if (!input) {
		// If any error occurs, simply log the description of it and don't continue any more.
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	// Initialize the captureSession object.
	self.captureSession = [[AVCaptureSession alloc] init];
	// Set the input device on the capture session.
	[self.captureSession addInput:input];
	
	// Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
	AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
	[self.captureSession addOutput:captureMetadataOutput];
	
	// Create a new serial dispatch queue.
	dispatch_queue_t dispatchQueue;
	dispatchQueue = dispatch_queue_create("myQueue", NULL);
	[captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
	[captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:
												   AVMetadataObjectTypeUPCECode,
												   AVMetadataObjectTypeCode39Code,
												   AVMetadataObjectTypeCode39Mod43Code,
												   AVMetadataObjectTypeEAN13Code,
												   AVMetadataObjectTypeEAN8Code,
												   AVMetadataObjectTypeCode93Code,
												   AVMetadataObjectTypeCode128Code,
												   AVMetadataObjectTypePDF417Code,
												   AVMetadataObjectTypeQRCode,
												   AVMetadataObjectTypeAztecCode,
												   AVMetadataObjectTypeInterleaved2of5Code,
												   AVMetadataObjectTypeITF14Code,
												   AVMetadataObjectTypeDataMatrixCode,
												   AVMetadataObjectTypeUPCECode,
												   nil]];
	
	// Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
	self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
	[self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self.videoPreviewLayer setFrame:self.view.layer.bounds];
	[self.view.layer addSublayer:self.videoPreviewLayer];
	
	// Start video capture.
	[self.captureSession startRunning];
	
	return YES;
}

- (void)stopReading {
	// Stop video capture and make the capture session object nil.
	[self.captureSession stopRunning];
	self.captureSession = nil;
	
	// Remove the video preview layer from the viewPreview view's layer.
	[self.videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
	
	if (self.canScan == YES) {
		
		// Check if the metadataObjects array is not nil and it contains at least one object.
		if (metadataObjects != nil && [metadataObjects count] > 0) {
			// Get the metadata object.
			AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
			// Everything is done on the main thread.
			
			self.canScan = NO;
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Barcode Scanner"
															message:[NSString stringWithFormat:@"Metadata Founded: %@", [metadataObj stringValue]]
														   delegate:self
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
			
			[alert show];
			
			NSLog(@"Metadata Founded: %@", [metadataObj stringValue]);
		}
	}
	
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"buttonIndex: %li", (long)buttonIndex);
	if (buttonIndex == 0) {
		self.canScan = YES;
	}
}

@end
