//
//  MVPView.m
//  ModelViewProjection
//
//  Created by Brent Gulanowski on 2014-06-23.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "MVPView.h"

#include <GLTools.h>	// OpenGL toolkit
#include <GLMatrixStack.h>
#include <GLFrame.h>
#include <GLFrustum.h>
#include <GLGeometryTransform.h>
#include <GLBatch.h>
#include <StopWatch.h>

@implementation MVPView {
	
	// Global view frustum class
	GLFrustum           viewFrustum;
	
	// The shader manager
	GLShaderManager     shaderManager;
	
	// The torus
	GLTriangleBatch     torusBatch;
}

- (BOOL)useDisplayLink {
	return YES;
}

- (void)setup {
	
	[super setup];
	
	// Black background
	glClearColor(0.8f, 0.8f, 0.8f, 1.0f );
	
    glEnable(GL_DEPTH_TEST);
	
    shaderManager.InitializeStockShaders();
	
    // This makes a torus
    gltMakeTorus(torusBatch, 0.4f, 0.15f, 30, 30);
	
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
}

- (void)drawRect:(NSRect)dirtyRect {

    // Set up time based animation
    static CStopWatch rotTimer;
    float yRot = rotTimer.GetElapsedSeconds() * 60.0f;
    
	// Clear the window and the depth buffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
    // Matrix Variables
    M3DMatrix44f mTranslate, mRotate, mModelview, mModelViewProjection;
    
    // Create a translation matrix to move the torus back and into sight
    m3dTranslationMatrix44(mTranslate, 0.0f, 0.0f, -2.5f);
    
    // Create a rotation matrix based on the current value of yRot
    m3dRotationMatrix44(mRotate, m3dDegToRad(yRot), 0.0f, 1.0f, 0.0f);
    
    // Add the rotation to the translation, store the result in mModelView
    m3dMatrixMultiply44(mModelview, mTranslate, mRotate);
    
    // Add the modelview matrix to the projection matrix,
    // the final matrix is the ModelViewProjection matrix.
    m3dMatrixMultiply44(mModelViewProjection, viewFrustum.GetProjectionMatrix(),mModelview);
	
    // Pass this completed matrix to the shader, and render the torus
    GLfloat vBlack[] = { 0.0f, 0.0f, 0.0f, 1.0f };
    shaderManager.UseStockShader(GLT_SHADER_FLAT, mModelViewProjection, vBlack);
    torusBatch.Draw();
	
	[[self openGLContext] flushBuffer];
}

- (void)reshape {
	[super reshape];
	CGRect bounds = [self bounds];
    viewFrustum.SetPerspective(35.0f, CGRectGetWidth(bounds)/CGRectGetHeight(bounds), 1.0f, 1000.0f);
}

@end
