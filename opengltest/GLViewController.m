//
//  ViewController.m
//  opengltest
//
//  Created by Bryce Redd on 11/14/16.
//  Copyright © 2016 Bryce Redd. All rights reserved.
//

#import "GLViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CaptureController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#import "CameraShader.h"
#import "BackgroundTask.h"

void glCheckError() {
  GLenum err;
  while ((err = glGetError()) != GL_NO_ERROR) {
    NSLog(@"GL Error: %d", err);
  }
}

@interface GLViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, GLKViewDelegate> {
  CaptureController *_cameraCapture;
  CameraShader *_shader;
  CVOpenGLESTextureCacheRef _textureCache;
  CVOpenGLESTextureRef _texture;
  EAGLContext *_context;
  BackgroundTask *_task;
  dispatch_queue_t _queue;
  BOOL _subviewNeedsDisplay;
  __weak IBOutlet UILabel *_label;

  GLuint _positionVBO;
  GLuint _textureVBO;
}
@end

@implementation GLViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _task = [BackgroundTask new];

  [self setupOpenGL];
  [self setupTextureCaching];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  CaptureControllerConfig *config = [CaptureControllerConfig new];
  config.delegate = self;
  config.videoMirrored = YES;
  config.position = AVCaptureDevicePositionFront;
  _cameraCapture = [[CaptureController alloc] init];
  [_cameraCapture startSessionWithConfig:config];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_cameraCapture stopSession];
}

- (void)setupOpenGL
{
  _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  if (!_context) {
    return;
  }
  [EAGLContext setCurrentContext:_context];
  
  GLKView *glkView = (GLKView *)self.view;
  glkView.backgroundColor = [UIColor blackColor];
  glkView.context = _context;
  glkView.delegate = self;
  
  _shader = [CameraShader new];
  [_shader loadShader];
  glUseProgram(_shader.program);
  glUniform1i(_shader.uVideoframe, 0);
  
  const GLfloat squareVertices[] = {
    -1.0f, -1.0f, // bottom left
    1.0f, -1.0f, // bottom right
    -1.0f,  1.0f, // top left
    1.0f,  1.0f, // top right
  };
  
  glGenBuffers(1, &_positionVBO);
  glBindBuffer(GL_ARRAY_BUFFER, _positionVBO);
  glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertices) * 8, &squareVertices, GL_STATIC_DRAW);
  glEnableVertexAttribArray(_shader.aPosition);
  glVertexAttribPointer(_shader.aPosition, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);

  const GLfloat textureVertices[] = {
    0.0f, 1.0f, // bottom left -> top left
    1.0f, 1.0f, // bottom right -> top right
    0.0f, 0.0f, // top left -> bottom left
    1.0f, 0.0f, // top right -> bottom right
  };

  glGenBuffers(1, &_textureVBO);
  glBindBuffer(GL_ARRAY_BUFFER, _textureVBO);
  glBufferData(GL_ARRAY_BUFFER, sizeof(textureVertices) * 8, &textureVertices, GL_STATIC_DRAW);
  glEnableVertexAttribArray(_shader.aTexturecoordinate);
  glVertexAttribPointer(_shader.aTexturecoordinate, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);

  glCheckError();
}

- (void)setupTextureCaching
{
  CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_textureCache);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
  [self runBackgroundTask];
  glClear(GL_COLOR_BUFFER_BIT);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  glCheckError();
}

- (void)cleanupPreviousFrame
{
  if (_texture) {
    CFRelease(_texture);
  }
  CVOpenGLESTextureCacheFlush(_textureCache, 0);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
  [self cleanupPreviousFrame];

  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

  glActiveTexture(GL_TEXTURE0);
  CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                               _textureCache,
                                               imageBuffer,
                                               NULL,
                                               GL_TEXTURE_2D,
                                               GL_RGBA,
                                               (GLsizei)CVPixelBufferGetWidth(imageBuffer),
                                               (GLsizei)CVPixelBufferGetHeight(imageBuffer),
                                               GL_BGRA,
                                               GL_UNSIGNED_BYTE,
                                               0,
                                               &_texture);
  glBindTexture(CVOpenGLESTextureGetTarget(_texture), CVOpenGLESTextureGetName(_texture));
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glCheckError();
}

- (void)runBackgroundTask
{
  [_task run:^(float time) {
    dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"%.02fms", time * -1000);
      if (_subviewNeedsDisplay) {
        //        [self.view setNeedsDisplay]; does not work
        //        [subview setNeedsDisplay]; does not work
        //        [[UIApplication sharedApplication].keyWindow setNeedsDisplay]; does not work
        //        [_label setNeedsDisplay]; // does not work
        [_label setText:[NSString stringWithFormat:@"%.02fms", time * -1000]];
      }
    });
  }];
}

- (IBAction)toggleLabel:(id)sender
{
  _subviewNeedsDisplay = !_subviewNeedsDisplay;
}

@end
