//
//  PointSet.m
//  GLTools
//
//  Created by Brent Gulanowski on 2014-06-02.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "PointSet.h"

#import "Drawing.h"

@interface PointSet () <Drawing>

@end

@implementation PointSet {
	GLuint vertexArrayName;
	GLuint normalArrayName;
	GLuint colorArrayName;
	GLuint *textureCoordArrayName;
}

- (instancetype)initWithType:(GLuint)type count:(GLuint)count {
	self = [super init];
	if (self) {
		
	}
	return self;
}

- (void)draw {
	
}

@end
