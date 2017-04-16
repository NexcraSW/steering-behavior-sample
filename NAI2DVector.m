//
//  NAI2DVector.m
//  Object Motion Sandbox
//
//  Created by Paul De Leon on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NAI2DMatrix.h"
#import "NAI2DVector.h"

#import "cocos2d.h"

@implementation NAI2DVector

@synthesize x;
@synthesize y;


- (void) dealloc
{
//    CCLOG(@"NAI2DVector dealloc'd.");     // Logging this eats up FPS
    [super dealloc];
}


+ (id) NAI2DVectorWithXComp:(float)inX YComp:(float)inY
{
    NAI2DVector* newVector = [[[NAI2DVector alloc] initWithXComp:inX YComp:inY] autorelease];
    return newVector;
}

+ (id) NAI2DVectorWithVector:(NAI2DVector*)inVector
{
    NAI2DVector* newVector = [[[NAI2DVector alloc] initWithVector:inVector] autorelease]; 
    
    return newVector;
}


+ (id) NAI2DVectorWithAngle:(float)degreeAngle
{
    NAI2DVector* newVector = naivec(1.0, 1.0);
    float newY = tanf(nai_deg_to_radians(degreeAngle));
    
    [newVector setY:newY];
    
    return newVector;
}


-(id) init
{
    self = [super init];
    
	if (self) 
    {
        [self zero];
    }
    return self;
}


- (id) initWithXComp:(float)inX YComp:(float)inY
{
    self = [self init];
    x = inX;
    y = inY;
    
    return self;
}


- (id) initWithVector:(NAI2DVector*)inVector
{
    self = [self init];
    
    x = [inVector x];
    y = [inVector y];
    
    return self;
}


- (void) zero
{
    x = 0.0;
    y = 0.0;
}




- (void) normalize
{
    float length = [self magnitude];
    
    if (length > 0.0) 
    {
        x /= length;
        y /= length;
    }
}


- (void) perpindicular
{
    NAI2DVector* tempVector = [[[NAI2DVector alloc] init] autorelease];
    
    [tempVector setCompsFromVector:self];
    x = [tempVector y] * -1;
    y = [tempVector x];
}


- (void) addVector:(NAI2DVector*)rhsVector
{
    x += [rhsVector x];
    y += [rhsVector y];
}


- (void) subtractVector:(NAI2DVector*)rhsVector
{
    x -= [rhsVector x];
    y -= [rhsVector y];
}


- (void) scalarMult:(float)rhsScalar
{
    x *= rhsScalar;
    y *= rhsScalar;
}


- (void) vectorScalarMult:(NAI2DVector*)scalars
{
    x *= [scalars x];
    y *= [scalars y];
}



- (void) vectorScalarDiv:(NAI2DVector*)scalars
{
    if ([scalars x] != 0.0) {
        x /= [scalars x];
    }
    
    if ([scalars y] != 0.0) {    
        y /= [scalars y];
    }
}


- (void) scalarDiv:(float)rhsScalar
{
    if (rhsScalar != 0.0)
    {
        x /= rhsScalar;
        y /= rhsScalar;
    }
}


- (void) truncate:(float)max
{
    if ([self magnitude] > max) 
    {
        [self normalize];
        [self scalarMult:max];
    }
}


- (void) truncateX:(float)maxX Y:(float)maxY
{
    if (fabsf([self x]) > maxX) 
    {
        [self setX:[self x] / fabsf([self x])];
        [self setX:[self x] * maxX];
    }
    
    if (fabsf([self y]) > maxY) 
    {
        [self setY:[self y] / fabsf([self y])];
        [self setY:[self y] * maxY];
    }
}






- (NAI2DVector*) normalizeOperator
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];
    float resultLength = [result magnitude];
    
    if (resultLength > 0.0)
    {
        [result setX:([result x] / resultLength)];
        [result setY:([result y] / resultLength)];
    }
    else {
        result = [NAI2DVector NAI2DVectorWithVector:naivec(0.0, 0.0)];
    }
    
    return result;
}


- (NAI2DVector*) perpindicularOperator
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:naivec(0.0, 0.0)];
    NAI2DVector* tempVector = [NAI2DVector NAI2DVectorWithVector:self];
    
    [result setX:[tempVector y] * -1];
    [result setY:[tempVector x]];
    
    return result;
}


- (NAI2DVector*) addVectorOperator:(NAI2DVector*)rhsVector
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];
    
    [result setX:([result x] + [rhsVector x])];
    [result setY:([result y] + [rhsVector y])];
        
    return result;
}


- (NAI2DVector*) subtractVectorOperator:(NAI2DVector*)rhsVector
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];
    
    [result setX:([result x] - [rhsVector x])];
    [result setY:([result y] - [rhsVector y])];
    
    return result;
}


- (NAI2DVector*) addVectorOperatorX:(float)inX Y:(float)inY
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];
    
    [result setX:([result x] + inX)];
    [result setY:([result y] + inY)];
    
    return result;
}


- (NAI2DVector*) subtractVectorOperatorX:(float)inX Y:(float)inY
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];
    
    [result setX:([result x] - inX)];
    [result setY:([result y] - inY)];
    
    return result;
}


- (NAI2DVector*) scalarMultOperator:(float)rhsScalar
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];
    
    [result setX:([result x] * rhsScalar)];
    [result setY:([result y] * rhsScalar)];
    
    return result;
}


- (NAI2DVector*) vectorScalarMultOperator:(NAI2DVector*)scalars
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];
    
    [result setX:([result x] * [scalars x])];
    [result setY:([result y] * [scalars y])];
    
    return result;
}



- (NAI2DVector*) vectorScalarDivOperator:(NAI2DVector*)scalars
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];
    
    if ([scalars x] != 0.0) {
        [result setX:([result x] / [scalars x])];
    }
    
    if ([scalars y] != 0.0) {
        [result setY:([result y] / [scalars y])];    
    }
    
    return result;
}


- (NAI2DVector*) scalarDivOperator:(float)rhsScalar
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];    
    
    if (rhsScalar != 0.0) 
    {
        [result setX:([result x] / rhsScalar)];
        [result setY:([result y] / rhsScalar)];        
    }
        
    return result;
}


- (NAI2DVector*) truncateOperator:(float)max
{
    NAI2DVector* result = [NAI2DVector NAI2DVectorWithVector:self];    
    
    if ([result magnitude] > max) 
    {
        [result setCompsFromVector:[result normalizeOperator]];
        [result setCompsFromVector:[result scalarMultOperator:max]];
    }
    
    return result;
}



+ (NAI2DVector*) point:(NAI2DVector*)point toWorldSpaceWithHeading:(NAI2DVector*)agentHeading side:(NAI2DVector*)agentSide position:(NAI2DVector*)agentPosition
{
    NAI2DMatrix* transfromMatrix = [NAI2DMatrix NAI2DIdentityMatrix];
    NAI2DVector* transformPoint = [NAI2DVector NAI2DVectorWithVector:point];
    
    [transfromMatrix rotateFromForwardVector:agentHeading sideVector:agentSide];
    [transfromMatrix translateWithX:[agentPosition x] Y:[agentPosition y]];

    transformPoint = [transfromMatrix transformToVector:transformPoint];
    
    return transformPoint;
}



- (BOOL) isEqualToVector:(NAI2DVector*)rhsVector
{
    BOOL vectorsEqual = YES;
    
    if (x != [rhsVector x]) {
        vectorsEqual = NO;
    }
    
    if (y != [rhsVector y]) {
        vectorsEqual = NO;
    }

    return vectorsEqual;
}


- (float) magnitude
{
    return sqrtf((x * x) + (y * y));
}


- (float) lengthSqrd
{
    return ((x * x) + (y * y));
}


- (void) setCompsFromVector:(NAI2DVector*)rhsVector
{
    x = [rhsVector x];
    y = [rhsVector y];
}


@end
