//
//  NAI2DVector.h
//  Object Motion Sandbox
//
//  Created by Paul De Leon on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NAI2DVector : NSObject
{
    float x;
    float y;
}

@property (readwrite) float x;
@property (readwrite) float y;

+ (id) NAI2DVectorWithXComp:(float)inX YComp:(float)inY;
+ (id) NAI2DVectorWithVector:(NAI2DVector*)inVector;
+ (id) NAI2DVectorWithAngle:(float)radianAngle;

- (id) initWithXComp:(float)inX YComp:(float)inY;
- (id) initWithVector:(NAI2DVector*)inVector;

// Methods to directly change the vector
- (void) zero;
- (BOOL) isEqualToVector:(NAI2DVector*)rhsVector;
- (float) magnitude;
- (float) lengthSqrd;
- (void) setCompsFromVector:(NAI2DVector*)rhsVector;

- (void) normalize;
- (void) perpindicular;
- (void) addVector:(NAI2DVector*)rhsVector;
- (void) subtractVector:(NAI2DVector*)rhsVector;
- (void) scalarMult:(float)rhsScalar;
- (void) vectorScalarMult:(NAI2DVector*)scalars;
- (void) vectorScalarDiv:(NAI2DVector*)scalars;
- (void) scalarDiv:(float)rhsScalar;
- (void) truncate:(float)max;
- (void) truncateX:(float)maxX Y:(float)maxY;


// Operators to give an autoreleased result
- (NAI2DVector*) normalizeOperator;
- (NAI2DVector*) perpindicularOperator;
- (NAI2DVector*) addVectorOperator:(NAI2DVector*)rhsVector;
- (NAI2DVector*) subtractVectorOperator:(NAI2DVector*)rhsVector;
- (NAI2DVector*) scalarMultOperator:(float)rhsScalar;
- (NAI2DVector*) vectorScalarMultOperator:(NAI2DVector*)scalars;
- (NAI2DVector*) vectorScalarDivOperator:(NAI2DVector*)scalars;
- (NAI2DVector*) scalarDivOperator:(float)rhsScalar;
- (NAI2DVector*) truncateOperator:(float)max;

// Operators to give an autoreleased result that don't require a vector input
- (NAI2DVector*) addVectorOperatorX:(float)inX Y:(float)inY;
- (NAI2DVector*) subtractVectorOperatorX:(float)inX Y:(float)inY;

+ (NAI2DVector*) point:(NAI2DVector*)point toWorldSpaceWithHeading:(NAI2DVector*)agentHeading side:(NAI2DVector*)agentSide position:(NAI2DVector*)agentPosition;



#define naivec(__X__,__Y__) [NAI2DVector NAI2DVectorWithXComp:__X__ YComp:__Y__]
#define nai_deg_to_radians(__DEG__) __DEG__ * (3.1415 / 180)
#define nai_radians_to_deg(__RAD__) __RAD__ * (180/ 3.1415)


@end
