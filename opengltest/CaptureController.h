//
//  CaptureController.h
//  opengltest
//
//  Created by Bryce Redd on 11/14/16.
//  Copyright © 2016 Bryce Redd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface CaptureControllerConfig : NSObject

@property (atomic, assign) AVCaptureDevicePosition position;
@property (atomic, assign) AVCaptureVideoOrientation orientation;
@property (atomic, assign) dispatch_queue_t queue;
@property (atomic, assign) OSType color;
@property (atomic, assign) BOOL videoMirrored;
@property (atomic, copy) NSString *sessionPreset;
@property (atomic, weak) id<AVCaptureVideoDataOutputSampleBufferDelegate> delegate;

@end

@interface CaptureController : NSObject

- (void)startSession;

- (void)startSessionWithConfig:(CaptureControllerConfig *)config;

- (void)stopSession;

- (void)changeCamera;

- (void)changeCameraOrientation:(AVCaptureVideoOrientation)orientation;

- (AVCaptureDevicePosition)currentCameraPosition;

@end
