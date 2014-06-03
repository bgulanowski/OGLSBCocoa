//
//  PointSet.h
//  GLTools
//
//  Created by Brent Gulanowski on 2014-06-02.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PointSet : NSObject

@property (nonatomic, readonly) GLuint type;
@property (nonatomic, readonly) GLuint count;

- (instancetype)initWithType:(GLuint)type count:(GLuint)count;

@end
