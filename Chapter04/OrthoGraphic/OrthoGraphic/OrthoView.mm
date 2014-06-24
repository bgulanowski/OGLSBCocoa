//
//  OrthoView.m
//  OrthoGraphic
//
//  Created by Brent Gulanowski on 2014-06-24.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "OrthoView.h"

#include <GLTools.h>	// OpenGL toolkit
#include <GLMatrixStack.h>
#include <GLFrame.h>
#include <GLFrustum.h>
#include <GLGeometryTransform.h>
#include <GLBatch.h>

#import <Carbon/Carbon.h>

@implementation OrthoView {
	GLFrame             viewFrame;
	GLFrustum           viewFrustum;
	GLBatch             tubeBatch;
	GLBatch             innerBatch;
	GLMatrixStack       modelViewMatix;
	GLMatrixStack       projectionMatrix;
	GLGeometryTransform transformPipeline;
	GLShaderManager     shaderManager;
}

- (void)setup {
	
	glClearColor(0.0f, 0.0f, 0.75f, 1.0f );
	
//    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
	
    shaderManager.InitializeStockShaders();
	
    tubeBatch.Begin(GL_QUADS, 200);
    
    float fZ = 100.0f;
    float bZ = -100.0f;
	
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, 100.0f);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
	
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f,50.0f,fZ);
    
    // Right Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
	
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f,-50.0f,fZ);
    
    // Top Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 35.0f, fZ);
	
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f,fZ);
    
    // Bottom Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -35.0f,fZ);
    
    // Top length section ////////////////////////////
    // Normal points up Y axis
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
	
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f,50.0f,bZ);
    
    // Bottom section
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
	
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    // Left section
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    // Right Section
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
	
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
	
    
    // Pointing straight out Z
    // Left Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f,50.0f,fZ);
    
    // Right Panel
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f,-50.0f,fZ);
    
    // Top Panel
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 50.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 35.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 35.0f, fZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f,fZ);
    
    // Bottom Panel
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -35.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -35.0f,fZ);
	
    // Top length section ////////////////////////////
    // Normal points up Y axis
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f,50.0f,bZ);
    
    // Bottom section
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    // Left section
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    // Right Section
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, bZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
	
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
		
	// Left Panel
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(-35.0f,50.0f,bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(-35.0f, -50.0f, bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(-50.0f, 50.0f, bZ);
	
	// Right Panel
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(50.0f,-50.0f,bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(35.0f, -50.0f, bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(35.0f, 50.0f, bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
	
	// Top Panel
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(35.0f, 50.0f, bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(35.0f, 35.0f, bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(-35.0f, 35.0f, bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(-35.0f, 50.0f, bZ);
    
	// Bottom Panel
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(35.0f, -35.0f,bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(35.0f, -50.0f, bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(-35.0f, -50.0f, bZ);
	
	tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
	tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
	tubeBatch.Vertex3f(-35.0f, -35.0f, bZ);
    
	tubeBatch.End();
	
	
	innerBatch.Begin(GL_QUADS, 40);
	
	// Insides /////////////////////////////
	// Normal points up Y axis
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
	innerBatch.Vertex3f(-35.0f, 35.0f, fZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
	innerBatch.Vertex3f(35.0f, 35.0f, fZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
	innerBatch.Vertex3f(35.0f, 35.0f, bZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
	innerBatch.Vertex3f(-35.0f,35.0f,bZ);
	
	// Bottom section
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
	innerBatch.Vertex3f(-35.0f, -35.0f, fZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
	innerBatch.Vertex3f(-35.0f, -35.0f, bZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
	innerBatch.Vertex3f(35.0f, -35.0f, bZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
	innerBatch.Vertex3f(35.0f, -35.0f, fZ);
	
	// Left section
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
	innerBatch.Vertex3f(-35.0f, 35.0f, fZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
	innerBatch.Vertex3f(-35.0f, 35.0f, bZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
	innerBatch.Vertex3f(-35.0f, -35.0f, bZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
	innerBatch.Vertex3f(-35.0f, -35.0f, fZ);
	
	// Right Section
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
	innerBatch.Vertex3f(35.0f, 35.0f, fZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
	innerBatch.Vertex3f(35.0f, -35.0f, fZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
	innerBatch.Vertex3f(35.0f, -35.0f, bZ);
	innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
	innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
	innerBatch.Vertex3f(35.0f, 35.0f, bZ);
	
	innerBatch.End();
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

	// Clear the window and the depth buffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	//    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
	
	
    modelViewMatix.PushMatrix(viewFrame);
	
    GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    GLfloat vGray[] = { 0.75f, 0.75f, 0.75f, 1.0f };
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vRed);
    tubeBatch.Draw();
	
	
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vGray);
    innerBatch.Draw();
	
    modelViewMatix.PopMatrix();
	
	[[self openGLContext] flushBuffer];
}

- (void)reshape {
	[super reshape];
	viewFrustum.SetOrthographic(-130.0f, 130.0f, -130.0f, 130.0f, -130.0f, 130.0f);
    
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    transformPipeline.SetMatrixStacks(modelViewMatix, projectionMatrix);
}

@end
