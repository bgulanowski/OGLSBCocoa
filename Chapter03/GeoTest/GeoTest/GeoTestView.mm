//
//  GeoTestView.m
//  GeoTest
//
//  Created by Brent Gulanowski on 2014-06-22.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "GeoTestView.h"

#include <GLTools.h>	// OpenGL toolkit
#include <GLMatrixStack.h>
#include <GLFrame.h>
#include <GLFrustum.h>
#include <GLGeometryTransform.h>

#import <Carbon/Carbon.h>

@implementation GeoTestView {
	
	GLFrame             viewFrame;
	GLFrustum           viewFrustum;
	GLTriangleBatch     torusBatch;
	GLMatrixStack       modelViewMatix;
	GLMatrixStack       projectionMatrix;
	GLGeometryTransform transformPipeline;
	GLShaderManager     shaderManager;

	int iCull;
	int iDepth;
}

- (void)setup {
	
	glClearColor(0.3f, 0.3f, 0.3f, 1.0f );
	
    shaderManager.InitializeStockShaders();
    transformPipeline.SetMatrixStacks(modelViewMatix, projectionMatrix);
    viewFrame.MoveForward(7.0f);
	
    // Make the torus
    gltMakeTorus(torusBatch, 1.0f, 0.3f, 52, 26);
	
    glPointSize(4.0f);
}

- (void)keyDown:(NSEvent *)theEvent {
	
	unsigned short key = [theEvent keyCode];
	
	if(key == kVK_UpArrow) {
		viewFrame.RotateWorld(m3dDegToRad(-5.0), 1.0f, 0.0f, 0.0f);
	}
	else if(key == kVK_DownArrow) {
		viewFrame.RotateWorld(m3dDegToRad(5.0), 1.0f, 0.0f, 0.0f);
	}
	else if(key == kVK_LeftArrow) {
		viewFrame.RotateWorld(m3dDegToRad(-5.0), 0.0f, 1.0f, 0.0f);
	}
	else if(key == kVK_RightArrow) {
		viewFrame.RotateWorld(m3dDegToRad(5.0), 0.0f, 1.0f, 0.0f);
	}
	else {
		return;
	}
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// Turn culling on if flag is set
	if(iCull)
		glEnable(GL_CULL_FACE);
	else
		glDisable(GL_CULL_FACE);
	
	// Enable depth testing if flag is set
	if(iDepth)
		glEnable(GL_DEPTH_TEST);
	else
		glDisable(GL_DEPTH_TEST);
	
	
    modelViewMatix.PushMatrix(viewFrame);
	
    GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
//    shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vRed);
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vRed);
	
    torusBatch.Draw();
	
    modelViewMatix.PopMatrix();
	
	[[self openGLContext] flushBuffer];
}

- (void)reshape {
	CGRect bounds = [self bounds];
	[super reshape];
    viewFrustum.SetPerspective(35.0f, CGRectGetWidth(bounds)/CGRectGetHeight(bounds), 1.0f, 100.0f);
	projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
}

- (IBAction)menuSelection:(NSMenuItem *)sender {
	
	[[self openGLContext] makeCurrentContext];
	
	switch([sender tag])
	{
		case 1:
			iDepth = !iDepth;
			break;
			
		case 2:
			iCull = !iCull;
			break;
			
        case 3:
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
            break;
			
        case 4:
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            break;
			
        case 5:
            glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
            break;
			
		default:
			return;
	}
	
	[self setNeedsDisplay:YES];
}

@end
