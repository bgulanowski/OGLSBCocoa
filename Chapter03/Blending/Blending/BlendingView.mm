//
//  BlendingView.m
//  Blending
//
//  Created by Brent Gulanowski on 2014-06-22.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "BlendingView.h"

#include <GLTools.h>
#include <GLShaderManager.h>

#import <Carbon/Carbon.h>

static GLfloat blockSize = 0.2f;
static GLfloat vVerts[] = {
	-blockSize, -blockSize, 0.0f,
	blockSize, -blockSize, 0.0f,
	blockSize,  blockSize, 0.0f,
	-blockSize,  blockSize, 0.0f
};

@implementation BlendingView {

	GLShaderManager	shaderManager;

	GLBatch	squareBatch;
	GLBatch greenBatch;
	GLBatch redBatch;
	GLBatch blueBatch;
	GLBatch blackBatch;
}

- (void)setup {
	
	glClearColor(1.0f, 1.0f, 1.0f, 1.0f );
    
	shaderManager.InitializeStockShaders();
	
	// Load up a triangle fan
	squareBatch.Begin(GL_TRIANGLE_FAN, 4);
	squareBatch.CopyVertexData3f(vVerts);
	squareBatch.End();
	
    GLfloat vBlock[] = { 0.25f, 0.25f, 0.0f,
		0.75f, 0.25f, 0.0f,
		0.75f, 0.75f, 0.0f,
		0.25f, 0.75f, 0.0f};
    
    greenBatch.Begin(GL_TRIANGLE_FAN, 4);
    greenBatch.CopyVertexData3f(vBlock);
    greenBatch.End();
    
	
    GLfloat vBlock2[] = { -0.75f, 0.25f, 0.0f,
		-0.25f, 0.25f, 0.0f,
		-0.25f, 0.75f, 0.0f,
		-0.75f, 0.75f, 0.0f};
	
    redBatch.Begin(GL_TRIANGLE_FAN, 4);
    redBatch.CopyVertexData3f(vBlock2);
    redBatch.End();
    
	
    GLfloat vBlock3[] = { -0.75f, -0.75f, 0.0f,
		-0.25f, -0.75f, 0.0f,
		-0.25f, -0.25f, 0.0f,
		-0.75f, -0.25f, 0.0f};
	
    blueBatch.Begin(GL_TRIANGLE_FAN, 4);
    blueBatch.CopyVertexData3f(vBlock3);
    blueBatch.End();
	
	
    GLfloat vBlock4[] = { 0.25f, -0.75f, 0.0f,
		0.75f, -0.75f, 0.0f,
		0.75f, -0.25f, 0.0f,
		0.25f, -0.25f, 0.0f};
	
    blackBatch.Begin(GL_TRIANGLE_FAN, 4);
    blackBatch.CopyVertexData3f(vBlock4);
    blackBatch.End();
}

- (void)drawRect:(NSRect)dirtyRect {
    
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 0.5f };
    GLfloat vGreen[] = { 0.0f, 1.0f, 0.0f, 1.0f };
    GLfloat vBlue[] = { 0.0f, 0.0f, 1.0f, 1.0f };
    GLfloat vBlack[] = { 0.0f, 0.0f, 0.0f, 1.0f };
	
	
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vGreen);
    greenBatch.Draw();
	
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vRed);
    redBatch.Draw();
	
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vBlue);
    blueBatch.Draw();
	
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vBlack);
    blackBatch.Draw();
	
	
	
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vRed);
    squareBatch.Draw();
    glDisable(GL_BLEND);
	
	[[self openGLContext] flushBuffer];
}

- (void)keyDown:(NSEvent *)theEvent {
	
	unsigned short key = [theEvent keyCode];
	
	GLfloat stepSize = 0.025f;
	
	GLfloat blockX = vVerts[0];  // Upper left X
	GLfloat blockY = vVerts[7];  // Upper left Y
	
	if(key == kVK_UpArrow) {
		blockY += stepSize;
	}
	else if(key == kVK_DownArrow) {
		blockY -= stepSize;
	}
	else if(key == kVK_LeftArrow) {
		blockX -= stepSize;
	}
	else if(key == kVK_RightArrow) {
		blockX += stepSize;
	}
	else {
		return;
	}
	
	// Collision detection
	if(blockX < -1.0f) blockX = -1.0f;
	if(blockX > (1.0f - blockSize * 2)) blockX = 1.0f - blockSize * 2;;
	if(blockY < -1.0f + blockSize * 2)  blockY = -1.0f + blockSize * 2;
	if(blockY > 1.0f) blockY = 1.0f;
	
	// Recalculate vertex positions
	vVerts[0] = blockX;
	vVerts[1] = blockY - blockSize*2;
	
	vVerts[3] = blockX + blockSize*2;
	vVerts[4] = blockY - blockSize*2;
	
	vVerts[6] = blockX + blockSize*2;
	vVerts[7] = blockY;
	
	vVerts[9] = blockX;
	vVerts[10] = blockY;
	
	squareBatch.CopyVertexData3f(vVerts);
	
	[self setNeedsDisplay:YES];
}

@end
