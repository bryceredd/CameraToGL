// Copyright 2004-present Facebook. All Rights Reserved.

#import "ShaderLoader.h"

#import <GLKit/GLKit.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@implementation ShaderLoader

+ (GLuint)loadShaderFromBundle:(NSString *)textureName extension:(NSString *)extension shaderType:(GLenum)shaderType
{
  NSString *shaderPath = [[NSBundle mainBundle] pathForResource:textureName ofType:extension];
  NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
  return [self buildShader:[shaderString cStringUsingEncoding:NSUTF8StringEncoding]
                      with:shaderType];
}

+ (GLuint)createProgramWithShaders:(GLuint[])shaders length:(size_t)length
{
  GLuint programHandle = glCreateProgram();
  for (int i = 0; i < length; i++) {
    glAttachShader(programHandle, shaders[i]);
  }
  glLinkProgram(programHandle);

  // Check for errors
  GLint linkSuccess;
  glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);

  if (linkSuccess == GL_FALSE)
  {
    GLchar messages[1024];
    glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
    NSLog(@"GLSL error: %s", messages);
  }

  // Delete shaders
  for (int i = 0; i < length; i++) {
    glDeleteShader(shaders[i]);
  }

  return programHandle;
}

+ (GLuint)buildShader:(const char *)source with:(GLenum)shaderType
{
  // Create the shader object
  GLuint shaderHandle = glCreateShader(shaderType);

  // Load the shader source
  glShaderSource(shaderHandle, 1, &source, 0);

  // Compile the shader
  glCompileShader(shaderHandle);

  // Check for errors
  GLint compileSuccess;
  glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
  if (compileSuccess == GL_FALSE)
  {
    GLchar messages[1024];
    glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
    NSLog(@"GLSL error: %s", messages);
  }

  return shaderHandle;
}

@end
