//
//  PrimitivesView.m
//  Primitives
//
//  Created by Brent Gulanowski on 2014-06-20.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "PrimitivesView.h"

#import <GLTools.h>
#import <GLMatrixStack.h>
#import <GLFrame.h>
#import <GLFrustum.h>
#import <GLBatch.h>
#import <GLGeometryTransform.h>

#import <Carbon/Carbon.h>

static GLfloat vGreen[] = { 0.0f, 1.0f, 0.0f, 1.0f };
static GLfloat vBlack[] = { 0.0f, 0.0f, 0.0f, 1.0f };

@implementation PrimitivesView {
	
	GLShaderManager		*_shaderManager;
	GLMatrixStack		*_modelViewMatrix;
	GLMatrixStack		*_projectionMatrix;
	GLFrame				*_cameraFrame;
	GLFrame             *_objectFrame;
	GLFrustum			*_viewFrustum;
	
	GLBatch				*_pointBatch;
	GLBatch				*_lineBatch;
	GLBatch				*_lineStripBatch;
	GLBatch				*_lineLoopBatch;
	GLBatch				*_triangleBatch;
	GLBatch             *_triangleStripBatch;
	GLBatch             *_triangleFanBatch;

	GLGeometryTransform	*_transformPipeline;
//	M3DMatrix44f		shadowMatrix;
	
	int _nStep;
}

- (void)dealloc {
	delete _shaderManager;
	delete _modelViewMatrix;
	delete _projectionMatrix;
	delete _cameraFrame;
	delete _objectFrame;
	delete _viewFrustum;
	
	delete _pointBatch;
	delete _lineBatch;
	delete _lineStripBatch;
	delete _lineLoopBatch;
	delete _triangleBatch;
	delete _triangleFanBatch;
	delete _triangleStripBatch;
	
	delete _transformPipeline;
}

- (void)setup {
	
	glClearColor(0.7f, 0.7f, 0.7f, 1.0f );
	
	_modelViewMatrix = new GLMatrixStack();
	_projectionMatrix = new GLMatrixStack();
	_viewFrustum = new GLFrustum();
	
	_shaderManager = new GLShaderManager();
	_shaderManager->InitializeStockShaders();
	
	glEnable(GL_DEPTH_TEST);
	
	_transformPipeline = new GLGeometryTransform();
	_transformPipeline->SetMatrixStacks(*_modelViewMatrix, *_projectionMatrix);
	
	_cameraFrame = new GLFrame();
	_cameraFrame->MoveForward(-15.0f);
	_objectFrame = new GLFrame();
	
	//////////////////////////////////////////////////////////////////////
	// Some points, more or less in the shape of Florida
	GLfloat vCoast[24][3] = {{2.80, 1.20, 0.0 }, {2.0,  1.20, 0.0 },
		{2.0,  1.08, 0.0 },  {2.0,  1.08, 0.0 },
		{0.0,  0.80, 0.0 },  {-.32, 0.40, 0.0 },
		{-.48, 0.2, 0.0 },   {-.40, 0.0, 0.0 },
		{-.60, -.40, 0.0 },  {-.80, -.80, 0.0 },
		{-.80, -1.4, 0.0 },  {-.40, -1.60, 0.0 },
		{0.0, -1.20, 0.0 },  { .2, -.80, 0.0 },
		{.48, -.40, 0.0 },   {.52, -.20, 0.0 },
		{.48,  .20, 0.0 },   {.80,  .40, 0.0 },
		{1.20, .80, 0.0 },   {1.60, .60, 0.0 },
		{2.0, .60, 0.0 },    {2.2, .80, 0.0 },
		{2.40, 1.0, 0.0 },   {2.80, 1.0, 0.0 }};
	
	// Load point batch
	_pointBatch = new GLBatch();
	_pointBatch->Begin(GL_POINTS, 24);
	_pointBatch->CopyVertexData3f(vCoast);
	_pointBatch->End();
	
	// Load as a bunch of line segments
	_lineBatch = new GLBatch();
	_lineBatch->Begin(GL_LINES, 24);
	_lineBatch->CopyVertexData3f(vCoast);
	_lineBatch->End();
	
	// Load as a single line segment
	_lineStripBatch = new GLBatch();
	_lineStripBatch->Begin(GL_LINE_STRIP, 24);
	_lineStripBatch->CopyVertexData3f(vCoast);
	_lineStripBatch->End();
	
	// Single line, connect first and last points
	_lineLoopBatch = new GLBatch();
	_lineLoopBatch->Begin(GL_LINE_LOOP, 24);
	_lineLoopBatch->CopyVertexData3f(vCoast);
	_lineLoopBatch->End();
	
	// For Triangles, we'll make a Pyramid
	GLfloat vPyramid[12][3] = { -2.0f, 0.0f, -2.0f,
		2.0f, 0.0f, -2.0f,
		0.0f, 4.0f, 0.0f,
		
		2.0f, 0.0f, -2.0f,
		2.0f, 0.0f, 2.0f,
		0.0f, 4.0f, 0.0f,
		
		2.0f, 0.0f, 2.0f,
		-2.0f, 0.0f, 2.0f,
		0.0f, 4.0f, 0.0f,
		
		-2.0f, 0.0f, 2.0f,
		-2.0f, 0.0f, -2.0f,
		0.0f, 4.0f, 0.0f};
	
	_triangleBatch = new GLBatch();
	_triangleBatch->Begin(GL_TRIANGLES, 12);
	_triangleBatch->CopyVertexData3f(vPyramid);
	_triangleBatch->End();
	
	
	// For a Triangle fan, just a 6 sided hex. Raise the center up a bit
	GLfloat vPoints[100][3];    // Scratch array, more than we need
	int nVerts = 0;
	GLfloat r = 3.0f;
	vPoints[nVerts][0] = 0.0f;
	vPoints[nVerts][1] = 0.0f;
	vPoints[nVerts][2] = 0.0f;
	
	for(GLfloat angle = 0; angle < M3D_2PI; angle += M3D_2PI / 6.0f) {
		nVerts++;
		vPoints[nVerts][0] = float(cos(angle)) * r;
		vPoints[nVerts][1] = float(sin(angle)) * r;
		vPoints[nVerts][2] = -0.5f;
	}
	
	// Close the fan
	nVerts++;
	vPoints[nVerts][0] = r;
	vPoints[nVerts][1] = 0;
	vPoints[nVerts][2] = 0.0f;
	
	// Load it up
	_triangleFanBatch = new GLBatch();
	_triangleFanBatch->Begin(GL_TRIANGLE_FAN, 8);
	_triangleFanBatch->CopyVertexData3f(vPoints);
	_triangleFanBatch->End();
	
	// For triangle strips, a little ring or cylinder segment
	int iCounter = 0;
	GLfloat radius = 3.0f;
	for(GLfloat angle = 0.0f; angle <= (2.0f*M3D_PI); angle += 0.3f)
	{
		GLfloat x = radius * sin(angle);
		GLfloat y = radius * cos(angle);
		
		// Specify the point and move the Z value up a little
		vPoints[iCounter][0] = x;
		vPoints[iCounter][1] = y;
		vPoints[iCounter][2] = -0.5;
		iCounter++;
		
		vPoints[iCounter][0] = x;
		vPoints[iCounter][1] = y;
		vPoints[iCounter][2] = 0.5;
		iCounter++;
	}
	
	// Close up the loop
	vPoints[iCounter][0] = vPoints[0][0];
	vPoints[iCounter][1] = vPoints[0][1];
	vPoints[iCounter][2] = -0.5;
	iCounter++;
	
	vPoints[iCounter][0] = vPoints[1][0];
	vPoints[iCounter][1] = vPoints[1][1];
	vPoints[iCounter][2] = 0.5;
	iCounter++;
	
	// Load the triangle strip
	_triangleStripBatch = new GLBatch();
	_triangleStripBatch->Begin(GL_TRIANGLE_STRIP, iCounter);
	_triangleStripBatch->CopyVertexData3f(vPoints);
	_triangleStripBatch->End();
}

- (void)drawRect:(NSRect)dirtyRect
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	_modelViewMatrix->PushMatrix();
	M3DMatrix44f mCamera;
	_cameraFrame->GetCameraMatrix(mCamera);
	_modelViewMatrix->MultMatrix(mCamera);
	
	M3DMatrix44f mObjectFrame;
	_objectFrame->GetMatrix(mObjectFrame);
	_modelViewMatrix->MultMatrix(mObjectFrame);
	
	_shaderManager->UseStockShader(GLT_SHADER_FLAT, _transformPipeline->GetModelViewProjectionMatrix(), vBlack);
	
	switch(_nStep) {
		case 0:
			glPointSize(4.0f);
			_pointBatch->Draw();
			glPointSize(1.0f);
			break;
		case 1:
			glLineWidth(2.0f);
			_lineBatch->Draw();
			glLineWidth(1.0f);
			break;
		case 2:
			glLineWidth(2.0f);
			_lineStripBatch->Draw();
			glLineWidth(1.0f);
			break;
		case 3:
			glLineWidth(2.0f);
			_lineLoopBatch->Draw();
			glLineWidth(1.0f);
			break;
		case 4:
			[self drawWireFramedBatch:_triangleBatch];
			break;
		case 5:
			[self drawWireFramedBatch:_triangleStripBatch];
			break;
		case 6:
			[self drawWireFramedBatch:_triangleFanBatch];
			break;
	}
	
	_modelViewMatrix->PopMatrix();
	
	[[self openGLContext] flushBuffer];
}

- (void)drawWireFramedBatch:(GLBatch *)pBatch {
	
	_shaderManager->UseStockShader(GLT_SHADER_FLAT, _transformPipeline->GetModelViewProjectionMatrix(), vGreen);
	pBatch->Draw();
	
	// Draw black outline
	glPolygonOffset(-1.0f, -1.0f);      // Shift depth values
	glEnable(GL_POLYGON_OFFSET_LINE);
	
	// Draw lines antialiased
	glEnable(GL_LINE_SMOOTH);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	// Draw black wireframe version of geometry
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	glLineWidth(2.5f);
	_shaderManager->UseStockShader(GLT_SHADER_FLAT, _transformPipeline->GetModelViewProjectionMatrix(), vBlack);
	pBatch->Draw();
	
	// Put everything back the way we found it
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glDisable(GL_POLYGON_OFFSET_LINE);
	glLineWidth(1.0f);
	glDisable(GL_BLEND);
	glDisable(GL_LINE_SMOOTH);
}

- (void)reshape {
	[super reshape];
	CGRect bounds = [self bounds];
	_viewFrustum->SetPerspective(35.0f, CGRectGetWidth(bounds) / CGRectGetHeight(bounds), 1.0f, 500.0f);
	_projectionMatrix->LoadMatrix(_viewFrustum->GetProjectionMatrix());
	_modelViewMatrix->LoadIdentity();
}

- (void)keyDown:(NSEvent *)theEvent {
	static NSArray *titles;
	if (!titles) {
		titles = @[ @"GL_POINTS", @"GL_LINES", @"GL_LINE_STRIP", @"GL_LINE_LOOP", @"GL_TRIANGLES", @"GL_TRIANGLE_STRIP", @"GL_TRIANGLE_FAN"];
	}
	
	switch ([theEvent keyCode]) {
		case kVK_Space:
			_nStep = (_nStep + 1) % 7;
			[[self window] setTitle:titles[_nStep]];
			break;
			
		case kVK_UpArrow:
			_objectFrame->RotateWorld(m3dDegToRad(-5.0f), 1.0f, 0.0f, 0.0f);
			break;
			
		case kVK_DownArrow:
			_objectFrame->RotateWorld(m3dDegToRad(5.0f), 1.0f, 0.0f, 0.0f);
			break;
			
		case kVK_LeftArrow:
			_objectFrame->RotateWorld(m3dDegToRad(-5.0f), 0.0f, 1.0f, 0.0f);
			break;
			
		case kVK_RightArrow:
			_objectFrame->RotateWorld(m3dDegToRad(5.0f), 0.0f, 1.0f, 0.0f);
			break;
			
		default:
			return;
			break;
	}

	[self setNeedsDisplay:YES];
}

@end
