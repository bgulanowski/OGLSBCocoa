//
//  MoveView.m
//  Move
//
//  Created by Brent Gulanowski on 2014-06-23.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "MoveView.h"

#include <GLTools.h>	// OpenGL toolkit
#include <GLShaderManager.h>
#include <math3d.h>

#import <Carbon/Carbon.h>

static GLfloat blockSize = 0.1f;
static GLfloat vVerts[] = { -blockSize, -blockSize, 0.0f,
	blockSize, -blockSize, 0.0f,
	blockSize,  blockSize, 0.0f,
	-blockSize,  blockSize, 0.0f};

@implementation MoveView {
	GLBatch	squareBatch;
	GLShaderManager	shaderManager;
	
	GLfloat xPos;
	GLfloat yPos;
}

- (void)setup {
	[super setup];

	// Black background
	glClearColor(0.0f, 0.0f, 1.0f, 1.0f );
    
	shaderManager.InitializeStockShaders();
	
	// Load up a triangle
	squareBatch.Begin(GL_TRIANGLE_FAN, 4);
	squareBatch.CopyVertexData3f(vVerts);
	squareBatch.End();
}

- (void)keyDown:(NSEvent *)theEvent {

	unsigned short key = [theEvent keyCode];
	static GLfloat stepSize = 0.025f;
	
	if(key == kVK_UpArrow) {
		yPos += stepSize;
	}
	else if(key == kVK_DownArrow) {
		yPos -= stepSize;
	}
	else if(key == kVK_LeftArrow) {
		xPos -= stepSize;
	}
	else if(key == kVK_RightArrow) {
		xPos += stepSize;
	}
	else {
		return;
	}
	
	// Collision detection
	if(xPos < (-1.0f + blockSize)) xPos = -1.0f + blockSize;
    
	if(xPos > (1.0f - blockSize)) xPos = 1.0f - blockSize;
	
    if(yPos < (-1.0f + blockSize))  yPos = -1.0f + blockSize;
    
	if(yPos > (1.0f - blockSize)) yPos = 1.0f - blockSize;
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {

	// Clear the window with current clearing color
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    
    M3DMatrix44f mFinalTransform, mTranslationMatrix, mRotationMatrix;
    
    // Just Translate
    m3dTranslationMatrix44(mTranslationMatrix, xPos, yPos, 0.0f);
    
    // Rotate 5 degrees evertyime we redraw
    static float yRot = 0.0f;
    yRot += 5.0f;
    m3dRotationMatrix44(mRotationMatrix, m3dDegToRad(yRot), 0.0f, 0.0f, 1.0f);
    
    m3dMatrixMultiply44(mFinalTransform, mTranslationMatrix, mRotationMatrix);
    
	shaderManager.UseStockShader(GLT_SHADER_FLAT, mFinalTransform, vRed);
	squareBatch.Draw();
	
	[[self openGLContext] flushBuffer];
}

@end
