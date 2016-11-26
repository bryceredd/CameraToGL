// Copyright 2004-present Facebook. All Rights Reserved.

#import "CameraShader.h"

#import "ShaderLoader.h"

@implementation CameraShader

- (void)loadShader
{
  GLuint shaders[2];
  shaders[0] = [ShaderLoader loadShaderFromBundle:@"GenericTexture" extension:@"vsh" shaderType:GL_VERTEX_SHADER];
  shaders[1] = [ShaderLoader loadShaderFromBundle:@"GenericTexture" extension:@"fsh" shaderType:GL_FRAGMENT_SHADER];

  _program = [ShaderLoader createProgramWithShaders:shaders length:2];
  _aPosition = glGetAttribLocation(_program, "aPosition");
  _aTexturecoordinate = glGetAttribLocation(_program, "aTexturecoordinate");
  _uVideoframe = glGetUniformLocation(_program, "uVideoframe");
}

@end
