//
//  SphereWorld4View.m
//  SphereWorld_4
//
//  Created by Brent Gulanowski on 2014-06-24.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "SphereWorld4View.h"

#include <GLTools.h>
#include <GLShaderManager.h>
#include <GLFrustum.h>
#include <GLBatch.h>
#include <GLFrame.h>
#include <GLMatrixStack.h>
#include <GLGeometryTransform.h>
#include <StopWatch.h>

#include <math.h>
#include <stdio.h>

#import <Carbon/Carbon.h>

#define NUM_SPHERES 50

@implementation SphereWorld4View {
	
	GLShaderManager		shaderManager;			// Shader Manager
	GLMatrixStack		modelViewMatrix;		// Modelview Matrix
	GLMatrixStack		projectionMatrix;		// Projection Matrix
	GLFrustum			viewFrustum;			// View Frustum
	GLGeometryTransform	transformPipeline;		// Geometry Transform Pipeline
	
	GLTriangleBatch		torusBatch;
	GLBatch				floorBatch;
	GLTriangleBatch     sphereBatch;
	GLFrame             cameraFrame;

	GLFrame spheres[NUM_SPHERES];
}

- (BOOL)useDisplayLink {
	return YES;
}

- (void)setup {
	[super setup];

	// Initialze Shader Manager
	shaderManager.InitializeStockShaders();
	
	glEnable(GL_DEPTH_TEST);
    
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	// This makes a torus
	gltMakeTorus(torusBatch, 0.4f, 0.15f, 30, 30);
	
    // This make a sphere
    gltMakeSphere(sphereBatch, 0.1f, 26, 13);
	
	floorBatch.Begin(GL_LINES, 324);
    for(GLfloat x = -20.0; x <= 20.0f; x+= 0.5) {
        floorBatch.Vertex3f(x, -0.55f, 20.0f);
        floorBatch.Vertex3f(x, -0.55f, -20.0f);
        
        floorBatch.Vertex3f(20.0f, -0.55f, x);
        floorBatch.Vertex3f(-20.0f, -0.55f, x);
	}
    floorBatch.End();
	
    // Randomly place the spheres
    for(int i = 0; i < NUM_SPHERES; i++) {
        GLfloat x = ((GLfloat)((rand() % 400) - 200) * 0.1f);
        GLfloat z = ((GLfloat)((rand() % 400) - 200) * 0.1f);
        spheres[i].SetOrigin(x, 0.0f, z);
	}

    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);
}

- (void)reshape {
	[super reshape];
	CGRect bounds = [self bounds];
    viewFrustum.SetPerspective(35.0f, CGRectGetWidth(bounds)/CGRectGetHeight(bounds), 1.0f, 100.0f);
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
}

- (void)drawRect:(NSRect)dirtyRect {

    // Color values
    static GLfloat vFloorColor[] = { 0.0f, 1.0f, 0.0f, 1.0f};
    static GLfloat vTorusColor[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    static GLfloat vSphereColor[] = { 0.0f, 0.0f, 1.0f, 1.0f };
	
    // Time Based animation
	static CStopWatch	rotTimer;
	float yRot = rotTimer.GetElapsedSeconds() * 60.0f;
	
	// Clear the color and depth buffers
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
    
    // Save the current modelview matrix (the identity matrix)
	modelViewMatrix.PushMatrix();
    
    M3DMatrix44f mCamera;
    cameraFrame.GetCameraMatrix(mCamera);
    modelViewMatrix.PushMatrix(mCamera);
	
    // Transform the light position into eye coordinates
    M3DVector4f vLightPos = { 0.0f, 10.0f, 5.0f, 1.0f };
    M3DVector4f vLightEyePos;
    m3dTransformVector4(vLightEyePos, vLightPos, mCamera);
	
	// Draw the ground
	shaderManager.UseStockShader(GLT_SHADER_FLAT,
								 transformPipeline.GetModelViewProjectionMatrix(),
								 vFloorColor);
	floorBatch.Draw();
    
    for(int i = 0; i < NUM_SPHERES; i++) {
        modelViewMatrix.PushMatrix();
        modelViewMatrix.MultMatrix(spheres[i]);
        shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF, transformPipeline.GetModelViewMatrix(),
									 transformPipeline.GetProjectionMatrix(), vLightEyePos, vSphereColor);
        sphereBatch.Draw();
        modelViewMatrix.PopMatrix();
	}
	
    // Draw the spinning Torus
    modelViewMatrix.Translate(0.0f, 0.0f, -2.5f);
    
    // Save the Translation
    modelViewMatrix.PushMatrix();
    
	// Apply a rotation and draw the torus
	modelViewMatrix.Rotate(yRot, 0.0f, 1.0f, 0.0f);
	shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF, transformPipeline.GetModelViewMatrix(),
								 transformPipeline.GetProjectionMatrix(), vLightEyePos, vTorusColor);
	torusBatch.Draw();
    modelViewMatrix.PopMatrix(); // "Erase" the Rotation from before
	
    // Apply another rotation, followed by a translation, then draw the sphere
    modelViewMatrix.Rotate(yRot * -2.0f, 0.0f, 1.0f, 0.0f);
    modelViewMatrix.Translate(0.8f, 0.0f, 0.0f);
    shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF, transformPipeline.GetModelViewMatrix(),
								 transformPipeline.GetProjectionMatrix(), vLightEyePos, vSphereColor);
    sphereBatch.Draw();
	
	// Restore the previous modleview matrix (the identity matrix)
	modelViewMatrix.PopMatrix();
    modelViewMatrix.PopMatrix();
	
	[[self openGLContext] flushBuffer];
}

- (void)keyDown:(NSEvent *)theEvent {
	
	static const float linear = 0.1f;
	static const float angular = float(m3dDegToRad(5.0f));

	unsigned short key = [theEvent keyCode];
	
	if(key == kVK_UpArrow) {
		cameraFrame.MoveForward(linear);
	}
	else if(key == kVK_DownArrow) {
		cameraFrame.MoveForward(-linear);
	}
	else if(key == kVK_LeftArrow) {
		cameraFrame.RotateWorld(angular, 0.0f, 1.0f, 0.0f);
	}
	else if(key == kVK_RightArrow) {
		cameraFrame.RotateWorld(-angular, 0.0f, 1.0f, 0.0f);
	}
	else {
		return;
	}
}

@end
