// Copyright 2004-present Facebook. All Rights Reserved.

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ShaderLoader : NSObject

+ (GLuint)loadShaderFromBundle:(NSString *)textureName extension:(NSString *)extension shaderType:(GLenum)shaderType;
+ (GLuint)createProgramWithShaders:(GLuint[])shaders length:(size_t)length;

@end
