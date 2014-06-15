//
//  BounceView.m
//  Bounce
//
//  Created by Brent Gulanowski on 2014-06-12.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "BounceView.h"

#import <GLBatch.h>
#import <GLShaderManager.h>

#import <CoreVideo/CVDisplayLink.h>


GLfloat blockSize = 0.1f;
GLfloat vVerts[] = { -blockSize - 0.5f, -blockSize, 0.0f,
	blockSize - 0.5f, -blockSize, 0.0f,
	blockSize - 0.5f,  blockSize, 0.0f,
	-blockSize - 0.5f,  blockSize, 0.0f};

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink,
								const CVTimeStamp *inNow,
								const CVTimeStamp *inOutputTime,
								CVOptionFlags flagsIn,
								CVOptionFlags *flagsOut,
								void *bounceView) {
	[(__bridge BounceView *)bounceView setNeedsDisplay:YES];
	return kCVReturnSuccess;
}

@implementation BounceView {
	GLBatch	*_squareBatch;
	GLShaderManager	*_shaderManager;
	CVDisplayLinkRef _displayLink;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
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
	CVDisplayLinkRelease(_displayLink), _displayLink = NULL;
}

- (void)setup {
	
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	CVDisplayLinkSetOutputCallback(_displayLink, DisplayLinkCallback, (__bridge void *)self);
	
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

- (void)awakeFromNib {
	CVDisplayLinkStart(_displayLink);
}

- (void)step {
	
	static GLfloat xDir = 1.0f;
	static GLfloat yDir = 1.0f;
	
	GLfloat stepSize = 0.005f;
	
	GLfloat blockX = vVerts[0];   // Upper left X
	GLfloat blockY = vVerts[7];  // Upper left Y
	
	blockY += stepSize * yDir;
	blockX += stepSize * xDir;
	
	// Collision detection
	if(blockX < -1.0f) { blockX = -1.0f; xDir *= -1.0f; }
	if(blockX > (1.0f - blockSize * 2)) { blockX = 1.0f - blockSize * 2; xDir *= -1.0f; }
	if(blockY < -1.0f + blockSize * 2)  { blockY = -1.0f + blockSize * 2; yDir *= -1.0f; }
	if(blockY > 1.0f) { blockY = 1.0f; yDir *= -1.0f; }
	
	// Recalculate vertex positions
	vVerts[0] = blockX;
	vVerts[1] = blockY - blockSize*2;
	
	vVerts[3] = blockX + blockSize*2;
	vVerts[4] = blockY - blockSize*2;
	
	vVerts[6] = blockX + blockSize*2;
	vVerts[7] = blockY;
	
	vVerts[9] = blockX;
	vVerts[10] = blockY;
	
	_squareBatch->CopyVertexData3f(vVerts);
}

- (void)drawRect:(NSRect)dirtyRect
{
	[self step];
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
	_shaderManager->UseStockShader(GLT_SHADER_IDENTITY, vRed);
	_squareBatch->Draw();
	
	[[self openGLContext] flushBuffer];
}

@end
