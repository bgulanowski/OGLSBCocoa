//
//  Pyramid.m
//  Pyramid
//
//  Created by Brent Gulanowski on 2014-07-09.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "Pyramid.h"

#import <GLTools.h>
#import <GLFrame.h>
#import <GLShaderManager.h>

@implementation Pyramid {
//	GLBatch	*_pyramidBatch;
//	GLShaderManager	*_shaderManager;

	GLShaderManager		shaderManager;
	GLMatrixStack		modelViewMatrix;
	GLMatrixStack		projectionMatrix;
	GLFrame				cameraFrame;
	GLFrame             objectFrame;
	GLFrustum			viewFrustum;
	
	GLBatch             pyramidBatch;
	
	GLuint              textureID;
	
	GLGeometryTransform	transformPipeline;
	M3DMatrix44f		shadowMatrix;
}

- (void)dealloc {
//	delete _pyramidBatch;
//	delete _shaderManager;
}

- (void)setup {
	
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
}

@end
