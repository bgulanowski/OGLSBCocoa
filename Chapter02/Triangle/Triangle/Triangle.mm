//
//  Triangle.m
//  Triangle
//
//  Created by Brent Gulanowski on 2014-06-02.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "Triangle.h"

#include <GLTools.h>
#include <GLShaderManager.h>

// heap objects

GLBatch	triangleBatch;
GLShaderManager	shaderManager;


@implementation Triangle

- (instancetype)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format {
	self = [super initWithFrame:frameRect pixelFormat:format];
	if (self) {
		[self setup];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self.openGLContext makeCurrentContext];
		[self setup];
	}
	return self;
}

- (void)setup {
	
	// Blue background
	glClearColor(0.0f, 0.0f, 1.0f, 1.0f );
	
	shaderManager.InitializeStockShaders();
	
	// Load up a triangle
	GLfloat vVerts[] = { -0.5f, 0.0f, 0.0f,
		0.5f, 0.0f, 0.0f,
		0.0f, 0.5f, 0.0f };
	
	triangleBatch.Begin(GL_TRIANGLES, 3);
	triangleBatch.CopyVertexData3f(vVerts);
	triangleBatch.End();
}

- (void)drawRect:(NSRect)dirtyRect {
	
	// Clear the window with current clearing color
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
	shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vRed);
	triangleBatch.Draw();
	
	[self.openGLContext flushBuffer];
}

@end
