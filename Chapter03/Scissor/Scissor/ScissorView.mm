//
//  ScissorView.m
//  Scissor
//
//  Created by Brent Gulanowski on 2014-06-23.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "ScissorView.h"

#import <OpenGL/gl.h>

@implementation ScissorView

- (void)drawRect:(NSRect)dirtyRect {

	glClearColor(0.0f, 0.0f, 1.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Now set scissor to smaller red sub region
	glClearColor(1.0f, 0.0f, 0.0f, 0.0f);
	glScissor(100, 100, 600, 400);
	glEnable(GL_SCISSOR_TEST);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Finally, an even smaller green rectangle
	glClearColor(0.0f, 1.0f, 0.0f, 0.0f);
	glScissor(200, 200, 400, 200);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Turn scissor back off for next render
	glDisable(GL_SCISSOR_TEST);
	
	[[self openGLContext] flushBuffer];
}

@end
