//
//  ObjectsView.m
//  Objects
//
//  Created by Brent Gulanowski on 2014-06-23.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "ObjectsView.h"

#include <GLTools.h>	// OpenGL toolkit
#include <GLMatrixStack.h>
#include <GLFrame.h>
#include <GLFrustum.h>
#include <GLBatch.h>
#include <GLGeometryTransform.h>

#import <Carbon/Carbon.h>

static GLfloat vGreen[] = { 0.0f, 1.0f, 0.0f, 1.0f };
static GLfloat vBlack[] = { 0.0f, 0.0f, 0.0f, 1.0f };

@implementation ObjectsView {
	
	GLShaderManager		shaderManager;
	GLMatrixStack		modelViewMatrix;
	GLMatrixStack		projectionMatrix;
	GLFrame				cameraFrame;
	GLFrame             objectFrame;
	GLFrustum			viewFrustum;
	
	GLTriangleBatch     sphereBatch;
	GLTriangleBatch     torusBatch;
	GLTriangleBatch     cylinderBatch;
	GLTriangleBatch     coneBatch;
	GLTriangleBatch     diskBatch;
	
	
	GLGeometryTransform	transformPipeline;
	M3DMatrix44f		shadowMatrix;
	
	int nStep;
}

- (void)setup {
	
    // Black background
    glClearColor(0.7f, 0.7f, 0.7f, 1.0f );
	
	shaderManager.InitializeStockShaders();
	
	glEnable(GL_DEPTH_TEST);
	
	transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);
	
	cameraFrame.MoveForward(-15.0f);
	
    
    // Sphere
    gltMakeSphere(sphereBatch, 3.0, 10, 20);
	
    // Torus
    gltMakeTorus(torusBatch, 3.0f, 0.75f, 15, 15);
    
    // Cylinder
    gltMakeCylinder(cylinderBatch, 2.0f, 2.0f, 3.0f, 13, 2);
    
    // Cone
    gltMakeCylinder(coneBatch, 2.0f, 0.0f, 3.0f, 13, 2);
    
    // Disk
    gltMakeDisk(diskBatch, 1.5f, 3.0f, 13, 3);
}

- (void)drawWireFrameBatch:(GLTriangleBatch *)pBatch {
	
    shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vGreen);
    pBatch->Draw();
    
    // Draw black outline
    glPolygonOffset(-1.0f, -1.0f);
    glEnable(GL_LINE_SMOOTH);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_POLYGON_OFFSET_LINE);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glLineWidth(2.5f);
    shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vBlack);
    pBatch->Draw();
    
    // Restore polygon mode and depht testing
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glDisable(GL_POLYGON_OFFSET_LINE);
    glLineWidth(1.0f);
    glDisable(GL_BLEND);
    glDisable(GL_LINE_SMOOTH);
}

- (void)drawRect:(NSRect)dirtyRect {

	// Clear the window with current clearing color
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	modelViewMatrix.PushMatrix();
	M3DMatrix44f mCamera;
	cameraFrame.GetCameraMatrix(mCamera);
	modelViewMatrix.MultMatrix(mCamera);
	
	M3DMatrix44f mObjectFrame;
	objectFrame.GetMatrix(mObjectFrame);
	modelViewMatrix.MultMatrix(mObjectFrame);
	
	shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vBlack);
	
	GLTriangleBatch *batch;
	
	switch(nStep) {
		case 0:
			batch = &sphereBatch;
			break;
		case 1:
			batch = &torusBatch;
			break;
		case 2:
			batch = &cylinderBatch;
			break;
		case 3:
			batch = &coneBatch;
			break;
		default:
			batch = &diskBatch;
			break;
	}
	
	[self drawWireFrameBatch:batch];
	
	modelViewMatrix.PopMatrix();

	[[self openGLContext] flushBuffer];
}

- (void)keyDown:(NSEvent *)theEvent {
	
	static NSArray *titles;
	if (titles == nil) {
		titles = @[@"Sphere", @"Torus", @"Cylinder", @"Cone", @"Disk"];
	}
	unsigned short key = [theEvent keyCode];
	
	if(key != kVK_Space) {
		return;
	}
	
	nStep = (nStep + 1) % 5;
	[self setNeedsDisplay:YES];
	
	[[self window] setTitle:titles[nStep]];
}

- (void)reshape {
	[super reshape];
	CGRect bounds = [self bounds];
	viewFrustum.SetPerspective(35.0f, CGRectGetWidth(bounds) / CGRectGetHeight(bounds), 1.0f, 500.0f);
	projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
	modelViewMatrix.LoadIdentity();
}

@end
