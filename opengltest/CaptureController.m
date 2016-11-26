//
//  CaptureController.m
//  opengltest
//
//  Created by Bryce Redd on 11/14/16.
//  Copyright © 2016 Bryce Redd. All rights reserved.
//

#import "CaptureController.h"

@implementation CaptureControllerConfig

- (instancetype)init
{
  self = [super init];
  if (self) {
    _position = AVCaptureDevicePositionFront;
    _orientation = AVCaptureVideoOrientationPortrait;
    _sessionPreset = AVCaptureSessionPresetHigh;
    _queue = dispatch_get_main_queue();
    _color = kCVPixelFormatType_32BGRA;
    _videoMirrored = false;
  }
  return self;
}

@end

@implementation CaptureController
{
  CaptureControllerConfig *_config;
  AVCaptureSession *_session;
  AVCaptureDeviceInput *_deviceInput;
  AVCaptureVideoOrientation _currentOrientation;
  dispatch_queue_t _queue;
  OSType _color;
}

- (void)startSession
{
  CaptureControllerConfig *config = [[CaptureControllerConfig alloc] init];
  [self startSessionWithConfig:config];
}

- (void)startSessionWithConfig:(CaptureControllerConfig *)config
{
  _config = config;
  _currentOrientation = config.orientation;
  _color = config.color;

  _session = [[AVCaptureSession alloc] init];
  _session.sessionPreset = config.sessionPreset;
  [_session beginConfiguration];

  AVCaptureDevice *device = [CaptureController deviceWithMediaType:AVMediaTypeVideo
                                                preferringPosition:config.position];

  AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];

  _deviceInput = input;
  [_session addInput:input];

  AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
  [_session addOutput:output];

  _queue = config.queue;
  [self setVideoDataOutput:output withOrientation:_currentOrientation];

  AVCaptureConnection *dataConnection = [output connectionWithMediaType:AVMediaTypeVideo];
  dataConnection.videoMirrored = config.videoMirrored;

  [_session commitConfiguration];
  [_session startRunning];
}

- (void)stopSession
{
  [_session stopRunning];
  for (AVCaptureInput *input in _session.inputs) {
    [_session removeInput:input];
  }
  for (AVCaptureOutput *output in _session.outputs) {
    [_session removeOutput:output];
  }
  _session = nil;
}

- (void)changeCamera
{
  AVCaptureDevice *currentVideoDevice = _deviceInput.device;
  AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
  AVCaptureDevicePosition currentPosition = currentVideoDevice.position;

  switch (currentPosition) {
    case AVCaptureDevicePositionUnspecified:
    case AVCaptureDevicePositionFront:
      preferredPosition = AVCaptureDevicePositionBack;
      break;
    case AVCaptureDevicePositionBack:
      preferredPosition = AVCaptureDevicePositionFront;
      break;
  }
  AVCaptureDevice *videoDevice = [CaptureController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
  AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
  [_session beginConfiguration];

  // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
  for (AVCaptureInput *input in _session.inputs) {
    [_session removeInput:input];
  }
  if ( [_session canAddInput:videoDeviceInput] ) {
    [_session addInput:videoDeviceInput];
    _deviceInput = videoDeviceInput;
  }
  for (AVCaptureOutput *output in _session.outputs) {
    [_session removeOutput: output];
  }
  AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
  [_session addOutput:output];

  [self setVideoDataOutput:output withOrientation:_currentOrientation];
  [_session commitConfiguration];
}

- (void)changeCameraOrientation:(AVCaptureVideoOrientation)orientation
{
  _currentOrientation = orientation;
  AVCaptureDevice *currentVideoDevice = _deviceInput.device;
  AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:currentVideoDevice error:nil];
  [_session beginConfiguration];
  for (AVCaptureInput *input in _session.inputs) {
    [_session removeInput:input];
  }
  if ( [_session canAddInput:videoDeviceInput] ) {
    [_session addInput:videoDeviceInput];
    _deviceInput = videoDeviceInput;
  }
  for (AVCaptureOutput *output in _session.outputs) {
    [_session removeOutput: output];
  }
  AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
  [_session addOutput:output];

  [self setVideoDataOutput:output withOrientation:_currentOrientation];
  [_session commitConfiguration];
}

- (void)setVideoDataOutput:(AVCaptureVideoDataOutput *)output
           withOrientation:(AVCaptureVideoOrientation)orientation
{
  AVCaptureConnection *dataConnection = [output connectionWithMediaType:AVMediaTypeVideo];
  dataConnection.videoOrientation = orientation;
  [output setSampleBufferDelegate:_config.delegate queue:_queue];
  output.videoSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(_color)};
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
  AVCaptureDevice *captureDevice = devices.firstObject;

  for ( AVCaptureDevice *device in devices ) {
    if ( device.position == position ) {
      captureDevice = device;
      break;
    }
  }

  return captureDevice;
}

- (AVCaptureDevicePosition)currentCameraPosition
{
  return _deviceInput.device.position;
}

@end
