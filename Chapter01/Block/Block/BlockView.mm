//
//  BlockView.m
//  Block
//
//  Created by Brent Gulanowski on 2014-06-16.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "BlockView.h"

#include <GLTools.h>	// OpenGL toolkit
#include <GLMatrixStack.h>
#include <GLFrame.h>
#include <GLFrustum.h>
#include <GLBatch.h>
#include <GLGeometryTransform.h>

#import <Carbon/Carbon.h>

GLfloat lightAmbient[] = { 0.2f, 0.2f, 0.2f, 1.0f };
GLfloat lightDiffuse[] = { 0.7f, 0.7f, 0.7f, 1.0f };
GLfloat lightSpecular[] = { 0.9f, 0.9f, 0.9f };
GLfloat vLightPos[] = { -8.0f, 20.0f, 100.0f, 1.0f };

@implementation BlockView {
	
	GLShaderManager		*_shaderManager;
	GLFrame				*_cameraFrame;
	GLFrustum			*_viewFrustum;
	GLBatch				*_cubeBatch;
	GLBatch				*_floorBatch;
	GLBatch				*_topBlock;
	GLBatch				*_frontBlock;
	GLBatch				*_leftBlock;
	
	GLMatrixStack		_modelViewMatrix;
	GLMatrixStack		_projectionMatrix;
	GLGeometryTransform	_transformPipeline;
	M3DMatrix44f		_shadowMatrix;
	
	GLuint _textures[4];

	int nStep;
}

- (id)initWithFrame:(NSRect)frame pixelFormat:(NSOpenGLPixelFormat *)format {
    self = [super initWithFrame:frame pixelFormat:format];
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
	delete _shaderManager;
	delete _cameraFrame;
	delete _viewFrustum;
	delete _cubeBatch;
	delete _floorBatch;
	delete _topBlock;
	delete _frontBlock;
	delete _leftBlock;
	glDeleteTextures(4, _textures);
}

- (void)setup {

	[[self openGLContext] makeCurrentContext];
	
	GLuint test[10];
	glGenVertexArrays(10, test);
	glDeleteVertexArrays(10, test);
	
	_viewFrustum = new GLFrustum();
	
	// Prepare shader manager
	_shaderManager = new GLShaderManager();
	_shaderManager->InitializeStockShaders();
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f );
	glEnable(GL_DEPTH_TEST);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
	
	_transformPipeline.SetMatrixStacks(_modelViewMatrix, _projectionMatrix);
	
	// Prepare camera frame
	_cameraFrame = new GLFrame();
	_cameraFrame->MoveForward(-15.0f);
	_cameraFrame->MoveUp(6.0f);
	_cameraFrame->RotateLocalX(float(m3dDegToRad(20.0f)));
	
	// Create shadow projection matrix
	GLfloat floorPlane[] = { 0.0f, 1.0f, 0.0f, 1.0f};
	m3dMakePlanarShadowMatrix(_shadowMatrix, floorPlane, vLightPos);
	
	[self loadTextures];

	[self makeFloor];
	[self makeCube];
	
	[self makeTop];
	[self makeFront];
	[self makeLeft];
}

- (void)makeTop {

	_topBlock = new GLBatch();
	_topBlock->Begin(GL_TRIANGLE_FAN, 4, 1);
	_topBlock->Normal3f(0.0f, 1.0f, 0.0f);
	_topBlock->MultiTexCoord2f(0, 0.0f, 0.0f);
	_topBlock->Vertex3f(-1.0f, 1.0f, 1.0f);
	
	_topBlock->Normal3f(0.0f, 1.0f, 0.0f);
	_topBlock->MultiTexCoord2f(0, 1.0f, 0.0f);
	_topBlock->Vertex3f(1.0f, 1.0f, 1.0f);
	
	_topBlock->Normal3f(0.0f, 1.0f, 0.0f);
	_topBlock->MultiTexCoord2f(0, 1.0f, 1.0f);
	_topBlock->Vertex3f(1.0f, 1.0f, -1.0f);
	
	_topBlock->Normal3f(0.0f, 1.0f, 0.0f);
	_topBlock->MultiTexCoord2f(0, 0.0f, 1.0f);
	_topBlock->Vertex3f(-1.0f, 1.0f, -1.0f);
	_topBlock->End();
}

- (void)makeFront {
	_frontBlock = new GLBatch();
	_frontBlock->Begin(GL_TRIANGLE_FAN, 4, 1);
	_frontBlock->Normal3f(0.0f, 0.0f, 1.0f);
	_frontBlock->MultiTexCoord2f(0, 0.0f, 0.0f);
	_frontBlock->Vertex3f(-1.0f, -1.0f, 1.0f);
	
	_frontBlock->Normal3f(0.0f, 0.0f, 1.0f);
	_frontBlock->MultiTexCoord2f(0, 1.0f, 0.0f);
	_frontBlock->Vertex3f(1.0f, -1.0f, 1.0f);
	
	_frontBlock->Normal3f(0.0f, 0.0f, 1.0f);
	_frontBlock->MultiTexCoord2f(0, 1.0f, 1.0f);
	_frontBlock->Vertex3f(1.0f, 1.0f, 1.0f);
	
	_frontBlock->Normal3f(0.0f, 0.0f, 1.0f);
	_frontBlock->MultiTexCoord2f(0, 0.0f, 1.0f);
	_frontBlock->Vertex3f(-1.0f, 1.0f, 1.0f);
	_frontBlock->End();
}

- (void)makeLeft {
	_leftBlock = new GLBatch();
	_leftBlock->Begin(GL_TRIANGLE_FAN, 4, 1);
	_leftBlock->Normal3f(-1.0f, 0.0f, 0.0f);
	_leftBlock->MultiTexCoord2f(0, 0.0f, 0.0f);
	_leftBlock->Vertex3f(-1.0f, -1.0f, -1.0f);
	
	_leftBlock->Normal3f(-1.0f, 0.0f, 0.0f);
	_leftBlock->MultiTexCoord2f(0, 1.0f, 0.0f);
	_leftBlock->Vertex3f(-1.0f, -1.0f, 1.0f);
	
	_leftBlock->Normal3f(-1.0f, 0.0f, 0.0f);
	_leftBlock->MultiTexCoord2f(0, 1.0f, 1.0f);
	_leftBlock->Vertex3f(-1.0f, 1.0f, 1.0f);
	
	_leftBlock->Normal3f(-1.0f, 0.0f, 0.0f);
	_leftBlock->MultiTexCoord2f(0, 0.0f, 1.0f);
	_leftBlock->Vertex3f(-1.0f, 1.0f, -1.0f);
	_leftBlock->End();
}

- (void)loadTextures {
	
    GLbyte *pBytes;
    GLint nWidth, nHeight, nComponents;
    GLenum format;
	
	// Load up four textures
	glGenTextures(4, _textures);
	
	// Wood floor
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource:@"floor" ofType:@"tga" inDirectory:nil];
    pBytes = gltReadTGABits([path cStringUsingEncoding:NSUTF8StringEncoding], &nWidth, &nHeight, &nComponents, &format);
    glBindTexture(GL_TEXTURE_2D, _textures[0]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexImage2D(GL_TEXTURE_2D,0,nComponents,nWidth, nHeight, 0,
				 format, GL_UNSIGNED_BYTE, pBytes);
	free(pBytes);
	
	// One of the block faces
	path = [bundle pathForResource:@"Block4" ofType:@"tga" inDirectory:nil];
	pBytes = gltReadTGABits([path cStringUsingEncoding:NSUTF8StringEncoding], &nWidth, &nHeight, &nComponents, &format);
    glBindTexture(GL_TEXTURE_2D, _textures[1]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexImage2D(GL_TEXTURE_2D,0,nComponents,nWidth, nHeight, 0,
				 format, GL_UNSIGNED_BYTE, pBytes);
	free(pBytes);
	
	// Another block face
	path = [bundle pathForResource:@"Block5" ofType:@"tga" inDirectory:nil];
	pBytes = gltReadTGABits([path cStringUsingEncoding:NSUTF8StringEncoding], &nWidth, &nHeight, &nComponents, &format);
	glBindTexture(GL_TEXTURE_2D, _textures[2]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexImage2D(GL_TEXTURE_2D,0,nComponents,nWidth, nHeight, 0,
				 format, GL_UNSIGNED_BYTE, pBytes);
	free(pBytes);
	
	// Yet another block face
	path = [bundle pathForResource:@"Block6" ofType:@"tga" inDirectory:nil];
	pBytes = gltReadTGABits([path cStringUsingEncoding:NSUTF8StringEncoding], &nWidth, &nHeight, &nComponents, &format);
	glBindTexture(GL_TEXTURE_2D, _textures[3]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexImage2D(GL_TEXTURE_2D,0,nComponents,nWidth, nHeight, 0,
				 format, GL_UNSIGNED_BYTE, pBytes);
	free(pBytes);
}

- (void)makeCube {
	
	_cubeBatch = new GLBatch();

	_cubeBatch->Begin(GL_TRIANGLES, 36, 1);
	
	/////////////////////////////////////////////
	// Top of cube
	_cubeBatch->Normal3f(0.0f, 1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(1.0f, 1.0f, 1.0f);
	
	_cubeBatch->Normal3f(0.0f, 1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 0.0f);
	_cubeBatch->Vertex3f(1.0f, 1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, 1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, 1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(1.0f, 1.0f, 1.0f);
	
	_cubeBatch->Normal3f(0.0f, 1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, 1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 1.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, 1.0f);
	
	////////////////////////////////////////////
	// Bottom of cube
	_cubeBatch->Normal3f(0.0f, -1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(-1.0f, -1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, -1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 0.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, -1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, 1.0f);
	
	_cubeBatch->Normal3f(0.0f, -1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 1.0f);
	_cubeBatch->Vertex3f(-1.0f, -1.0f, 1.0f);
	
	_cubeBatch->Normal3f(0.0f, -1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(-1.0f, -1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, -1.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, 1.0f);
	
	///////////////////////////////////////////
	// Left side of cube
	_cubeBatch->Normal3f(-1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, 1.0f);
	
	_cubeBatch->Normal3f(-1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 0.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, -1.0f);
	
	_cubeBatch->Normal3f(-1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(-1.0f, -1.0f, -1.0f);
	
	_cubeBatch->Normal3f(-1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, 1.0f);
	
	_cubeBatch->Normal3f(-1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(-1.0f, -1.0f, -1.0f);
	
	_cubeBatch->Normal3f(-1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 1.0f);
	_cubeBatch->Vertex3f(-1.0f, -1.0f, 1.0f);
	
	// Right side of cube
	_cubeBatch->Normal3f(1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, -1.0f);
	
	_cubeBatch->Normal3f(1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 0.0f);
	_cubeBatch->Vertex3f(1.0f, 1.0f, -1.0f);
	
	_cubeBatch->Normal3f(1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(1.0f, 1.0f, 1.0f);
	
	_cubeBatch->Normal3f(1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(1.0f, 1.0f, 1.0f);
	
	_cubeBatch->Normal3f(1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 1.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, 1.0f);
	
	_cubeBatch->Normal3f(1.0f, 0.0f, 0.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, -1.0f);
	
	// Front and Back
	// Front
	_cubeBatch->Normal3f(0.0f, 0.0f, 1.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 0.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, 1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, 1.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(1.0f, 1.0f, 1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, 1.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 1.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, 1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, 1.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 1.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, 1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, 1.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(-1.0f, -1.0f, 1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, 1.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 0.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, 1.0f);
	
	// Back
	_cubeBatch->Normal3f(0.0f, 0.0f, -1.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 0.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, -1.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_cubeBatch->Vertex3f(-1.0f, -1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, -1.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 1.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, -1.0f);
	_cubeBatch->MultiTexCoord2f(0, 0.0f, 1.0f);
	_cubeBatch->Vertex3f(-1.0f, 1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, -1.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_cubeBatch->Vertex3f(1.0f, 1.0f, -1.0f);
	
	_cubeBatch->Normal3f(0.0f, 0.0f, -1.0f);
	_cubeBatch->MultiTexCoord2f(0, 1.0f, 0.0f);
	_cubeBatch->Vertex3f(1.0f, -1.0f, -1.0f);
	
	_cubeBatch->End();
}

- (void)makeFloor {
	
	GLfloat x = 5.0f;
    GLfloat y = -1.0f;
	
	_floorBatch = new GLBatch();

	_floorBatch->Begin(GL_TRIANGLE_FAN, 4, 1);
	_floorBatch->MultiTexCoord2f(0, 0.0f, 0.0f);
	_floorBatch->Vertex3f(-x, y, x);
	
	_floorBatch->MultiTexCoord2f(0, 1.0f, 0.0f);
	_floorBatch->Vertex3f(x, y, x);
	
	_floorBatch->MultiTexCoord2f(0, 1.0f, 1.0f);
	_floorBatch->Vertex3f(x, y, -x);
	
	_floorBatch->MultiTexCoord2f(0, 0.0f, 1.0f);
	_floorBatch->Vertex3f(-x, y, -x);
	_floorBatch->End();
}

- (void)drawRect:(NSRect)dirtyRect {
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	_modelViewMatrix.PushMatrix();
	M3DMatrix44f mCamera;
	_cameraFrame->GetCameraMatrix(mCamera);
	_modelViewMatrix.MultMatrix(mCamera);
	
	// Reflection step... draw cube upside down, the floor
	// blended on top of it
	if(nStep == 5) {
		glDisable(GL_CULL_FACE);
		_modelViewMatrix.PushMatrix();
		_modelViewMatrix.Scale(1.0f, -1.0f, 1.0f);
		_modelViewMatrix.Translate(0.0f, 2.0f, 0.0f);
		_modelViewMatrix.Rotate(35.0f, 0.0f, 1.0f, 0.0f);
		[self renderBlock];
		_modelViewMatrix.PopMatrix();
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		[self renderFloor];
		glDisable(GL_BLEND);
	}
	
	
	_modelViewMatrix.PushMatrix();
	
	// Draw normally
	_modelViewMatrix.Rotate(35.0f, 0.0f, 1.0f, 0.0f);
	[self renderBlock];
	_modelViewMatrix.PopMatrix();
	
	
	// If not the reflection pass, draw floor last
	if(nStep != 5) {
		[self renderFloor];
	}
	
	_modelViewMatrix.PopMatrix();
	
	[[self openGLContext] flushBuffer];
}

- (void)renderFloor {
	
	GLfloat vBrown [] = { 0.55f, 0.292f, 0.09f, 1.0f};
	GLfloat vFloor[] = { 1.0f, 1.0f, 1.0f, 0.6f };
	
	switch(nStep)
	{
			// Wire frame
		case 0:
			glEnable(GL_BLEND);
			glEnable(GL_LINE_SMOOTH);
			_shaderManager->UseStockShader(GLT_SHADER_FLAT, _transformPipeline.GetModelViewProjectionMatrix(), vBrown);
			glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
			glDisable(GL_CULL_FACE);
			break;
			
			// Wire frame, but not the back side.. and only where stencil == 0
		case 1:
			glEnable(GL_BLEND);
			glEnable(GL_LINE_SMOOTH);
			
			glEnable(GL_STENCIL_TEST);
			glStencilFunc(GL_EQUAL, 0, 0xff);
			
			_shaderManager->UseStockShader(GLT_SHADER_FLAT, _transformPipeline.GetModelViewProjectionMatrix(), vBrown);
			glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
			break;
			
			// Solid
		case 2:
		case 3:
			_shaderManager->UseStockShader(GLT_SHADER_FLAT, _transformPipeline.GetModelViewProjectionMatrix(), vBrown);
			break;
			
			// Textured
		case 4:
		case 5:
		default:
			glBindTexture(GL_TEXTURE_2D, _textures[0]);
			_shaderManager->UseStockShader(GLT_SHADER_TEXTURE_MODULATE, _transformPipeline.GetModelViewProjectionMatrix(), vFloor, 0);
			break;
	}
	
	// Draw the floor
	_floorBatch->Draw();
	
	// Put everything back
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glEnable(GL_CULL_FACE);
	glDisable(GL_BLEND);
	glDisable(GL_LINE_SMOOTH);
	glDisable(GL_STENCIL_TEST);
}

- (void)renderBlock {
	
	GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f};
	GLfloat vWhite[] = { 1.0f, 1.0f, 1.0f, 1.0f };
	
	switch(nStep)
	{
			// Wire frame
		case 0:
			glEnable(GL_BLEND);
			glEnable(GL_LINE_SMOOTH);
			_shaderManager->UseStockShader(GLT_SHADER_FLAT, _transformPipeline.GetModelViewProjectionMatrix(), vRed);
			glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
			glDisable(GL_CULL_FACE);
			
			// Draw the cube
			_cubeBatch->Draw();
			
			break;
			
			// Wire frame, but not the back side... we also want the block to be in the stencil buffer
		case 1:
			_shaderManager->UseStockShader(GLT_SHADER_FLAT, _transformPipeline.GetModelViewProjectionMatrix(), vRed);
			
			// Draw solid block in stencil buffer
			// Back face culling prevents the back sides from showing through
			// The stencil pattern is used to mask when we draw the floor under it
			// to keep it from showing through.
			glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
			glEnable(GL_STENCIL_TEST);
			glStencilFunc(GL_NEVER, 0, 0);
			glStencilOp(GL_INCR, GL_INCR, GL_INCR);
			_cubeBatch->Draw();
			glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
			glDisable(GL_STENCIL_TEST);
			
			glEnable(GL_BLEND);
			glEnable(GL_LINE_SMOOTH);
			glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
			
			// Draw the front side cube
			_cubeBatch->Draw();
			break;
			
			// Solid
		case 2:
			_shaderManager->UseStockShader(GLT_SHADER_FLAT, _transformPipeline.GetModelViewProjectionMatrix(), vRed);
			
			// Draw the cube
			_cubeBatch->Draw();
			break;
			
			// Lit
		case 3:
			_shaderManager->UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF, _modelViewMatrix.GetMatrix(),
										 _projectionMatrix.GetMatrix(), vLightPos, vRed);
			
			// Draw the cube
			_cubeBatch->Draw();
			break;
			
			// Textured & Lit
		case 4:
		case 5:
		default:
			glBindTexture(GL_TEXTURE_2D, _textures[2]);
			_shaderManager->UseStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF, _modelViewMatrix.GetMatrix(),
										 _projectionMatrix.GetMatrix(), vLightPos, vWhite, 0);
			
			glBindTexture(GL_TEXTURE_2D, _textures[1]);
			_topBlock->Draw();
			glBindTexture(GL_TEXTURE_2D, _textures[2]);
			_frontBlock->Draw();
			glBindTexture(GL_TEXTURE_2D, _textures[3]);
			_leftBlock->Draw();
			
			break;
	}
	
	// Put everything back
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glEnable(GL_CULL_FACE);
	glDisable(GL_BLEND);
	glDisable(GL_LINE_SMOOTH);
	glDisable(GL_STENCIL_TEST);
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
	if ([theEvent keyCode] == kVK_Space) {
		nStep = (nStep + 1) % 6;
		[self setNeedsDisplay:YES];
	}
}

- (void)reshape {
	CGRect bounds = [self bounds];
	[[self openGLContext] makeCurrentContext];
	glViewport(0, 0, bounds.size.width, bounds.size.height);
	_viewFrustum->SetPerspective(35.0f, float(bounds.size.width) / float(bounds.size.height), 1.0f, 500.0f);
	_projectionMatrix.LoadMatrix(_viewFrustum->GetProjectionMatrix());
	_modelViewMatrix.LoadIdentity();
	[self setNeedsDisplay:YES];
}

@end
