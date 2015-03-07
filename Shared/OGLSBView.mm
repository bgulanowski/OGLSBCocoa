//
//  OGLSBView.m
//  Primitives
//
//  Created by Brent Gulanowski on 2014-06-21.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import "OGLSB_private.h"

#import <Carbon/Carbon.h>

#import <OpenGL/gl.h>
#import <CoreVideo/CVDisplayLink.h>

#import <GLFrame.h>

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

@end
