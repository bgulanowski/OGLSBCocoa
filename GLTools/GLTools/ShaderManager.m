//
//  ShaderManager.m
//  GLTools
//
//  Created by Brent Gulanowski on 2014-06-01.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "ShaderManager.h"

#import "StockShaders.h"

@implementation ShaderManager

+ (void)prepareShaders {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
	});
}

- (id)init {
	self = [super init];
	if (self) {
		
	}
	return self;
}

@end
