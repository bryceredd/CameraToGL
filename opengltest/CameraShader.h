// Copyright 2004-present Facebook. All Rights Reserved.

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface CameraShader : NSObject

// Program Handle
@property (atomic, assign, readwrite) GLint program;

// Attribute Handles
@property (atomic, assign, readwrite) GLuint aPosition;
@property (atomic, assign, readwrite) GLuint aTexturecoordinate;

// Uniform Handles
@property (atomic, assign, readwrite) GLint uVideoframe;

// Methods
- (void)loadShader;

@end
