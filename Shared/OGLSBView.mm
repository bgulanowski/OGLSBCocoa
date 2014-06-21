//
//  OGLSBView.m
//  Primitives
//
//  Created by Brent Gulanowski on 2014-06-21.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "OGLSBView.h"
#import <OpenGL/gl.h>

@implementation OGLSBView

- (instancetype)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format {
	self = [super initWithFrame:frameRect pixelFormat:format];
	if (self) {
		[self setup];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self.openGLContext makeCurrentContext];
		[self setup];
	}
	return self;
}

- (void)setup {

}

- (void)reshape {
	CGRect bounds = [self bounds];
	[[self openGLContext] makeCurrentContext];
	glViewport(0, 0, bounds.size.width, bounds.size.height);
	[self setNeedsDisplay:YES];
}

@end
