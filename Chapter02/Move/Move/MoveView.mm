//
//  MoveView.m
//  Move
//
//  Created by Brent Gulanowski on 2014-06-12.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "MoveView.h"

#import <GLTools.h>
#import <GLBatch.h>
#import <GLShaderManager.h>

#import <Carbon/Carbon.h>

static GLfloat const blockSize = 0.1f;
static GLfloat vVerts[] = {
	-blockSize, -blockSize, 0.0f,
	 blockSize, -blockSize, 0.0f,
	 blockSize,  blockSize, 0.0f,
	-blockSize,  blockSize, 0.0f
};

@implementation MoveView {
	GLBatch	*_squareBatch;
	GLShaderManager	*_shaderManager;
}

- (instancetype)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format {
	self = [super initWithFrame:frameRect pixelFormat:format];
	if (self) {
		[self setup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)dealloc {
	delete _squareBatch;
	delete _shaderManager;
}

- (void)setup {
	
	[[self openGLContext] makeCurrentContext];
	
	_squareBatch = new GLBatch();
	_shaderManager = new GLShaderManager();
	
	glClearColor(0.0f, 0.0f, 1.0f, 1.0f );
    
	if (!_shaderManager->InitializeStockShaders()) {
		NSLog(@"Failed to init shaders");
		exit(EXIT_FAILURE);
	}
	
	// Load up a triangle
	_squareBatch->Begin(GL_TRIANGLE_FAN, 4);
	_squareBatch->CopyVertexData3f(vVerts);
	_squareBatch->End();
}

- (void)drawRect:(NSRect)dirtyRect {
	
	// Clear the window with current clearing color
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
	_shaderManager->UseStockShader(GLT_SHADER_IDENTITY, vRed);
	_squareBatch->Draw();
	
	[[self openGLContext] flushBuffer];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
	
	const GLfloat stepSize = 0.025f;
	
	GLfloat blockX = vVerts[0];  // Upper left X
	GLfloat blockY = vVerts[7];  // Upper left Y
	
	unsigned key = [theEvent keyCode];
	
	BOOL notX = NO;
	
	if (key == kVK_UpArrow) {
		blockY += stepSize;
	}
	else if (key == kVK_DownArrow) {
		blockY -= stepSize;
	}
	else {
		notX = YES;
	}
	
	if(key == kVK_LeftArrow) {
		blockX -= stepSize;
	}
	else if(key == kVK_RightArrow) {
		blockX += stepSize;
	}
	else if (notX) {
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
	
	[[self openGLContext] makeCurrentContext];
	
	_squareBatch->CopyVertexData3f(vVerts);
	
	[self setNeedsDisplay:YES];
}

- (void)reshape {
	CGRect bounds = [self bounds];
	[[self openGLContext] makeCurrentContext];
	glViewport(0, 0, bounds.size.width, bounds.size.height);
	[self setNeedsDisplay:YES];
}

@end
