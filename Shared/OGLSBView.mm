//
//  OGLSBView.m
//  Primitives
//
//  Created by Brent Gulanowski on 2014-06-21.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "OGLSBView.h"

#import <OpenGL/gl.h>
#import <CoreVideo/CVDisplayLink.h>

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink,
									const CVTimeStamp *inNow,
									const CVTimeStamp *inOutputTime,
									CVOptionFlags flagsIn,
									CVOptionFlags *flagsOut,
									void *oglsbView) {
	[(__bridge OGLSBView *)oglsbView setNeedsDisplay:YES];
	return kCVReturnSuccess;
}

@implementation OGLSBView {
	CVDisplayLinkRef _displayLink;
}

@dynamic useDisplayLink;

- (BOOL)useDisplayLink {
	return NO;
}

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

- (void)dealloc {
	if (_displayLink) {
		CVDisplayLinkRelease(_displayLink), _displayLink = NULL;
	}
}

- (void)setup {
	if ([self useDisplayLink]) {
		CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
		CVDisplayLinkSetOutputCallback(_displayLink, DisplayLinkCallback, (__bridge void *)self);
	}
}

- (void)awakeFromNib {
	if ([self useDisplayLink]) {
		CVDisplayLinkStart(_displayLink);
	}
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)reshape {
	CGRect bounds = [self bounds];
	[[self openGLContext] makeCurrentContext];
	glViewport(0, 0, bounds.size.width, bounds.size.height);
	[self setNeedsDisplay:YES];
}

@end
