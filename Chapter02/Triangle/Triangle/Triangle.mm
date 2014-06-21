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

@implementation Triangle {
	GLBatch	*_triangleBatch;
	GLShaderManager	*_shaderManager;
}

- (void)dealloc {
	delete _triangleBatch;
	delete _shaderManager;
}

- (void)setup {
	
	// Blue background
	glClearColor(0.0f, 0.0f, 1.0f, 1.0f );
	
	_shaderManager = new GLShaderManager();
	_shaderManager->InitializeStockShaders();
	
	// Load up a triangle
	GLfloat vVerts[] = { -0.5f, 0.0f, 0.0f,
		0.5f, 0.0f, 0.0f,
		0.0f, 0.5f, 0.0f };
	
	_triangleBatch = new GLBatch();
	_triangleBatch->Begin(GL_TRIANGLES, 3);
	_triangleBatch->CopyVertexData3f(vVerts);
	_triangleBatch->End();
}

- (void)drawRect:(NSRect)dirtyRect {
	
	// Clear the window with current clearing color
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
	_shaderManager->UseStockShader(GLT_SHADER_IDENTITY, vRed);
	_triangleBatch->Draw();
	
	[self.openGLContext flushBuffer];
}

@end
