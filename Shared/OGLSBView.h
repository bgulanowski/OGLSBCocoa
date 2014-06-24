//
//  OGLSBView.h
//  Primitives
//
//  Created by Brent Gulanowski on 2014-06-21.
//  Copyright (c) 2014 GLSuperBible. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OGLSBView : NSOpenGLView

// subclasses should override to return YES if needed; default is NO
@property (nonatomic, readonly) BOOL useDisplayLink;

- (void)setup;

@end
