//
//  NAISteeringBehavior.m
//  Object Motion Sandbox
//
//  Created by Paul De Leon on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MGGameLogic.h"
#import "GameLayer.h"

#import "MGVehicle.h"
#import "NAI2DVector.h"
#import "NAISteeringBehavior.h"
#import "NAIPathWaypoint.h"

@implementation NAISteeringBehavior

@synthesize vehicle;
@synthesize steeringForce;

@synthesize path;
@synthesize pathType;

@synthesize sqWayPointGoalDist;

@synthesize targetAgent1;
@synthesize targetAgent2;
@synthesize targetAgent3;
@synthesize offsetPosition;

@synthesize refSprite;  // used for debugging the offset pursuit behavior

@synthesize behaviorActive;
@synthesize arriveBehaviorComplete;
@synthesize seekBehaviorComplete;


- (void) dealloc
{
    vehicle = nil;      // This is a weak reference to the owner
    
    [refSprite release];
    refSprite = nil;
    
    [path release];
    path = nil;
    
    [steeringForce release];
    steeringForce = nil;    
    
    [targetAgent1 release];
    targetAgent1 = nil;
    
    [targetAgent2 release];
    targetAgent2 = nil;
    
    [targetAgent3 release];
    targetAgent3 = nil;
    
    [offsetPosition release];
    offsetPosition = nil;
    
    [super dealloc];
}



-(id) init
{
    self = [super init];
    
	if (self) 
    {
        vehicle = nil;     // This is a weak reference to the owner
        steeringForce = [[NAI2DVector alloc] init];   
        path = [[NSMutableArray alloc] init];
        pathType = kNAIPathTypeOpen;     // open by default
        
        sqWayPointGoalDist = 0.0;
        naiBehaviorTypeFlags = NAIBehaviorTypeNone;
        
        targetAgent1 = nil;
        targetAgent2 = nil;
        targetAgent3 = nil;        
        offsetPosition = nil;
        
        refSprite = nil;
        behaviorActive = NO;
        arriveBehaviorComplete = NO;
        seekBehaviorComplete = NO;
    }
    
    return self;
}



- (NAI2DVector*) calculate
{
    [steeringForce zero];
 
    if (behaviorActive == YES)
    {
		// Right now its not setup to combine behaviors
		if ([self behaviorOn:NAIBehaviorTypeSeek]) {
			[steeringForce setCompsFromVector:[self seek:[vehicle targetPosition]]];        
		}
		
		if ([self behaviorOn:NAIBehaviorTypeArrive]) {
			[steeringForce setCompsFromVector:[self arrive:[vehicle targetPosition] deceleration:NAISBNormalDecel]]; 
		}
		
		if ([self behaviorOn:NAIBehaviorTypeFollowPath]) {
			[steeringForce setCompsFromVector:[self followPath]];        
		}
		
		if ([self behaviorOn:NAIBehaviorTypeOffsetPursuit]) {
			[steeringForce setCompsFromVector:[self offsetPursuit:targetAgent1 offsetVector:offsetPosition]];
		}

        if ([self behaviorOn:NAIBehaviorTypePursuit]) {
            [steeringForce setCompsFromVector:[self pursuit:targetAgent1]];
        }
        
        if ([self behaviorOn:NAIBehaviorTypeFace]) {
            [self face:targetAgent2];
            
            // PD 8/1/2012 - Having it set the steering force cancels out all the other behaviors
            // even if they're still enabled since it just returns a dummy vector
            // [steeringForce setCompsFromVector:[self face:targetAgent2]];
        }
		
		// Accumulation - 
		// Incorporates vehicle's max force - not working well so far
		// [steeringForce normalize];
		// [steeringForce scalarMult:[vehicle maxThrustForce]];
		
		// This seems to work better than trying to normalize/scalerMult
		[steeringForce scalarMult:[vehicle maxThrustForce]];    
    }
		
    return steeringForce;
}


#define SB_AMOUNT_OFF_SCREEN        -30.0

- (NAI2DVector*) sendVectorOffScreen:(NAI2DVector*)posVector
{
    float offsetX = [vehicle position].x - [posVector x];
    float offsetY = [vehicle position].y - [posVector y];
    
    if (offsetX == 0) 
    {
        CCLOG(@"No offset X found.");
        return naivec([posVector x], [posVector y]);
    }
    
    float ratio = offsetY / offsetX;    
    float adjX = SB_AMOUNT_OFF_SCREEN;  
    float adjY = (adjX * ratio) + [posVector y];
    
    return naivec(adjX, adjY);
}


// PD 9/2/2012 - Too many autoreleased vectors created in the original base steering method
/*
- (NAI2DVector*) seek:(NAI2DVector*)targetPos
{
    NAI2DVector* vehiclePosition = naivec([vehicle position].x, [vehicle position].y);
    NAI2DVector* desiredVelocity = [targetPos subtractVectorOperator:vehiclePosition];
    NAI2DVector* toTarget = [targetPos subtractVectorOperator:naivec([vehicle position].x, [vehicle position].y)];
    float distance = [toTarget magnitude];
    
    if (distance < 10) {
        seekBehaviorComplete = YES;
    }
    
    [desiredVelocity normalize];
    [desiredVelocity scalarMult:[vehicle maxSpeed]];
    
    return [desiredVelocity subtractVectorOperator:[vehicle velocity]];
}
*/



- (NAI2DVector*) seek:(NAI2DVector*)targetPos
{
    NAI2DVector* desiredVelocity = [targetPos subtractVectorOperatorX:[vehicle position].x Y:[vehicle position].y];
    float distance = [desiredVelocity magnitude];
    
    if (distance < 10) {
        seekBehaviorComplete = YES;
    }
    
    [desiredVelocity normalize];
    [desiredVelocity scalarMult:[vehicle maxSpeed]];
    
    return [desiredVelocity subtractVectorOperator:[vehicle velocity]];
}



- (NAI2DVector*) flee:(NAI2DVector*)targetPos
{
    NAI2DVector* vehiclePosition = naivec([vehicle position].x, [vehicle position].y);
    NAI2DVector* desiredVelocity = [vehiclePosition subtractVectorOperator:targetPos];
    
    return [desiredVelocity subtractVectorOperator:[vehicle velocity]];
}


// PD 9/2/2012 - Too many autoreleased vectors created in the original base steering method
/*
- (NAI2DVector*) arrive:(NAI2DVector*)targetPos deceleration:(NAISBDeceleration)deceleration
{
    NAI2DVector* toTarget = [targetPos subtractVectorOperator:naivec([vehicle position].x, [vehicle position].y)];
    float distance = [toTarget magnitude];
    
//    if (distance > 1)
    if (distance > 10)      // distance increased cause the sub weapon was having trouble keeping up with the avatar
    {
        const float decelTweaker = 0.3;
        float speed = distance / ((float) deceleration * decelTweaker);

        if (speed > [vehicle maxSpeed]) {
            speed = [vehicle maxSpeed];
        }
        
        NAI2DVector* desiredVelocity = [[toTarget scalarMultOperator:speed] scalarDivOperator:distance];
        
        return [desiredVelocity subtractVectorOperator:[vehicle velocity]];
    }
    else 
    {
        arriveBehaviorComplete = YES;
    }
    
    return naivec(0.0, 0.0);
}
*/
- (NAI2DVector*) arrive:(NAI2DVector*)targetPos deceleration:(NAISBDeceleration)deceleration
{
    NAI2DVector* toTarget = [targetPos subtractVectorOperatorX:[vehicle position].x Y:[vehicle position].y];
    float distance = [toTarget magnitude];
    
    //    if (distance > 1)
    if (distance > 10)      // distance increased cause the sub weapon was having trouble keeping up with the avatar
    {
        const float decelTweaker = 0.3;
        float speed = distance / ((float) deceleration * decelTweaker);
        
        if (speed > [vehicle maxSpeed]) {
            speed = [vehicle maxSpeed];
        }
        
        NAI2DVector* desiredVelocity = [[toTarget scalarMultOperator:speed] scalarDivOperator:distance];
        
        return [desiredVelocity subtractVectorOperator:[vehicle velocity]];
    }
    else
    {
        arriveBehaviorComplete = YES;
    }
    
    return naivec(0.0, 0.0);
}




- (NAI2DVector*) followPath
{    
    if ([path count] == 0) {
        return naivec(0.0, 0.0);    // all done or no path
    }

    NAI2DVector* currentWayPoint = [(NAIPathWaypoint*) [path objectAtIndex:0] position];
    NAIPathWaypoint* updatedWayPoint = nil;
    float distanceRemainingSq = [currentWayPoint lengthSqrd] - [naivec([vehicle position].x, [vehicle position].y) lengthSqrd];
    
    // Move to next waypoint
    if (fabs(distanceRemainingSq) < sqWayPointGoalDist)  
    {
        if (pathType == kNAIPathTypeOpen) 
        {
            [path removeObjectAtIndex:0];
        
            if ([path count] == 0) {
                return naivec(0.0, 0.0);    // all done or no path
            }
        }
        else
        {
            NAIPathWaypoint* pathToMoveToEnd = [[[path objectAtIndex:0] retain] autorelease];
            
            [path removeObjectAtIndex:0];
            
            if ([path count] == 0) {
                return naivec(0.0, 0.0);    // all done or no path
            }
            
            [path insertObject:pathToMoveToEnd atIndex:[path count]];
        }
    }
    
    updatedWayPoint = (NAIPathWaypoint*) [path objectAtIndex:0];    
    
    if ([updatedWayPoint waypointBehavior] == kWayPointBehaviorSeek) {
        return [self seek:[updatedWayPoint position]];        
    }
    else {
        return [self arrive:[updatedWayPoint position] deceleration:NAISBFastDecel];
//        return [self seek:[updatedWayPoint position]];
    }
}



- (NAI2DVector*) offsetPursuit:(MGVehicle*)targetVehicle offsetVector:(NAI2DVector*)offsetVector
{
    NAI2DVector* worldOffsetPos = [NAI2DVector point:offsetVector 
                             toWorldSpaceWithHeading:[targetVehicle heading] 
                                                side:[targetVehicle side] 
                                            position:naivec([targetVehicle position].x, [targetVehicle position].y)];
    
    
    /* This is the book's method */     
    // CCLOG(@"Leader Pos - (%f, %f)", [targetVehicle position].x, [targetVehicle position].y);
    // CCLOG(@"WorldOffset Pos - (%f, %f)", [worldOffsetPos x], [worldOffsetPos y]);
          
    NAI2DVector* toOffset = [worldOffsetPos subtractVectorOperator:naivec([vehicle position].x, [vehicle position].y)];
    float lookAheadTime = [toOffset magnitude] / ([vehicle maxSpeed] + [[targetVehicle velocity] magnitude]);

    NAI2DVector* totalOffset = [worldOffsetPos addVectorOperator:[[targetVehicle velocity] scalarMultOperator:lookAheadTime]];
//    [refSprite setPosition:ccp([totalOffset x], [totalOffset y])];     
    
    return [self arrive:totalOffset deceleration:NAISBFastDecel];
    
    /*
    NAI2DVector* totalOffset = naivec([targetVehicle position].x + [worldOffsetPos x], [targetVehicle position].y + [worldOffsetPos y]);
    NAI2DVector* vehiclePosition = naivec([targetVehicle position].x, [targetVehicle position].y);
    
    [refSprite setPosition:ccp([totalOffset x], [totalOffset y])];
    return [self arrive:totalOffset deceleration:NAISBFastDecel];
    */
}


- (NAI2DVector*) pursuit:(MGVehicle*)targetVehicle
{
    // NSAssert(targetVehicle != nil, @"No target vehicle found to pursue.");
    // I think there are cases where the target vehicle can be nil. If it gets eliminated before the original chaser can get to it.
    NSAssert(seekBehaviorComplete == NO, @"Seek behavior not properly reset from last use.");
    if (targetVehicle == nil) 
    {
        seekBehaviorComplete = YES;
        return naivec(0.0, 0.0);
    }
    
    NAI2DVector* evaderPos = naivec([targetVehicle position].x, [targetVehicle position].y);
    NAI2DVector* pursuerPos = naivec([vehicle position].x, [vehicle position].y);
    
    NAI2DVector* toEvader = [evaderPos subtractVectorOperator:pursuerPos];
    float relativeHeading = ([[vehicle heading] x] * [[targetVehicle heading] x]) + ([[vehicle heading] y] * [[targetVehicle heading] y]);
    float toEvaderDotProduct = ([toEvader x] * [[vehicle heading] x]) + ([toEvader y] * [[vehicle heading] y]);             // Book didn't give a good description of what this variable really is
    
    if ((toEvaderDotProduct > 0) && (relativeHeading < -0.95))      // acos(0.95) = 18 degs 
    {
        return [self seek:naivec([targetVehicle position].x, [targetVehicle position].y)];
    }

    // Not considered ahead so we predict where the evader will be.
    // Look ahead time is proportional to the distance between the evader and pursuer. And inversly proportional to the sum of the agents' velocities.

    
    float lookAheadTime = [toEvader magnitude] / ([vehicle maxSpeed] + [[targetVehicle velocity] magnitude]);
//    NAI2DVector* lookAheadPos = [[evaderPos addVectorOperator:[targetVehicle velocity]] scalarMultOperator:lookAheadTime];
    NAI2DVector* lookAheadPos = [evaderPos addVectorOperator:[[targetVehicle velocity] scalarMultOperator:lookAheadTime]];
    NAI2DVector* finalTargetPos = [self seek:lookAheadPos];
        
    return finalTargetPos;
}


- (NAI2DVector*) face:(MGVehicle*)targetVehicle
{
    // No liner motion for this
    NAI2DVector* dummyVector = naivec(0.0, 0.0);
    
    CGPoint gameLayerPos = [[SHARED_LOGIC_MODULE gameLayer] position];
    CGPoint avatarAdjPos = ccpSub([targetVehicle position], gameLayerPos);
    float angleToAvatar = atan2f([vehicle position].y - avatarAdjPos.y, avatarAdjPos.x - [vehicle position].x);
    angleToAvatar = nai_radians_to_deg(angleToAvatar);
    angleToAvatar = 180 - (angleToAvatar * -1);
        
    [vehicle setRotation:angleToAvatar];
    
    return dummyVector;
}


- (void) turnOffAllBehaviors
{
    naiBehaviorTypeFlags = NAIBehaviorTypeNone;
 
    // PD 7/6/2012 - Memory leak fix - Not exactly sure how to reproduce leak completely, but something like this is needed when turning off all behaviors
    if (targetAgent1 != nil) {
        [self setTargetAgent1:nil];
    }
    
    if (targetAgent2 != nil) {
        [self setTargetAgent2:nil];
    }
    
    if (targetAgent3 != nil) {
        [self setTargetAgent3:nil];
    }
}



- (void) setSeekOn
{
    seekBehaviorComplete = NO;
    naiBehaviorTypeFlags |= NAIBehaviorTypeSeek;
}


- (void) setSeekOff
{
    if ([self behaviorOn:NAIBehaviorTypeSeek]) {
        naiBehaviorTypeFlags ^= NAIBehaviorTypeSeek;
    }
}



- (void) setArriveOn
{
    arriveBehaviorComplete = NO;
    naiBehaviorTypeFlags |= NAIBehaviorTypeArrive;    
}


- (void) setArriveOff
{
    if ([self behaviorOn:NAIBehaviorTypeArrive]) {
        naiBehaviorTypeFlags ^= NAIBehaviorTypeArrive;
    }
}



- (void) setFollowPathOn
{
   naiBehaviorTypeFlags |= NAIBehaviorTypeFollowPath;        
}


- (void) setFollowPathOff
{
    if ([self behaviorOn:NAIBehaviorTypeFollowPath]) {
        naiBehaviorTypeFlags ^= NAIBehaviorTypeFollowPath;
    }    
}



// - (void) setOffsetPursuitOnWithTarget:(MGVehicle*)targetVehicle offset:(NAI2DVector*)offsetVector
- (void) setOffsetPursuitOnWithTarget:(MGVehicle*)targetVehicle offset:(NAI2DVector*)offsetVector refSprite:(CCSprite*)followSprite
{
    naiBehaviorTypeFlags |= NAIBehaviorTypeOffsetPursuit;
    [self setTargetAgent1:targetVehicle];
    [self setOffsetPosition:offsetVector];
    [self setRefSprite:followSprite];
}


- (void) setOffsetPursuitOff
{
    if ([self behaviorOn:NAIBehaviorTypeOffsetPursuit]) 
    {
        naiBehaviorTypeFlags ^= NAIBehaviorTypeOffsetPursuit;
        // PD 7/6/2012 - Memory leak fix
        [self setTargetAgent1:nil];
    }        
}


- (void) setPursuitOnWithTarget:(MGVehicle*)targetVehicle
{
    if (targetVehicle == nil)
    {
        seekBehaviorComplete = YES;
        return;
    }
    
    naiBehaviorTypeFlags |= NAIBehaviorTypePursuit;
    NSAssert([targetVehicle markedForHoming] == YES, @"Target Agent not properly marked for pursuit.");
    
    [self setTargetAgent1:targetVehicle];
    seekBehaviorComplete = NO;
}


- (void) setPursuitOff
{
    if ([self behaviorOn:NAIBehaviorTypePursuit]) 
    {
        naiBehaviorTypeFlags ^= NAIBehaviorTypePursuit;
        NSAssert(targetAgent1 == nil || [targetAgent1 markedForHoming] == NO, @"Target Agent for Pursuit not released properly.");
        
        [self setTargetAgent1:nil];
    }
}



- (void) setFaceOnWithTarget:(MGVehicle*)targetVehicle
{
    // For now, can't use this with pursuit/offSet pursuit unless they have identical target vehicles
    naiBehaviorTypeFlags |= NAIBehaviorTypeFace;
    [self setTargetAgent2:targetVehicle];
}



- (void) setFaceOff
{
    naiBehaviorTypeFlags ^= NAIBehaviorTypeFace;
    [self setTargetAgent2:nil];
    
//    [vehicle setFlipY:NO];
    // [vehicle setRotation:0.0];
}



- (BOOL) behaviorOn:(int)behaviorType
{
    return (behaviorType == (naiBehaviorTypeFlags & behaviorType));
}


@end
