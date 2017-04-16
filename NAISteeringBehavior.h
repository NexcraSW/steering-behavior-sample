//
//  NAISteeringBehavior.h
//  Object Motion Sandbox
//
//  Created by Paul De Leon on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommonProtocols.h"
#import "cocos2d.h"

@class NAI2DVector;
@class MGVehicle;



@interface NAISteeringBehavior : NSObject
{
    // The owner of the SteeringBehavior and the output of resulting forces to apply to owner
    MGVehicle* vehicle;
    NAI2DVector* steeringForce;
    
    // Path Following members
    NSMutableArray* path;           
    NAIPathType pathType;
    float sqWayPointGoalDist;
    
    
    // For Offset Pursuits/Pursuits
    MGVehicle* targetAgent1;
    MGVehicle* targetAgent2;
    MGVehicle* targetAgent3;
    
    NAI2DVector* offsetPosition;
    
    // The behaviors
    int naiBehaviorTypeFlags; 
        
    CCSprite* refSprite;
    BOOL behaviorActive;
    BOOL arriveBehaviorComplete;
    BOOL seekBehaviorComplete;
    
}

@property (nonatomic, retain) CCSprite* refSprite;

@property (nonatomic, retain) NSMutableArray* path;
@property (readwrite) NAIPathType pathType;
@property (nonatomic, assign) MGVehicle* vehicle;
@property (nonatomic, retain) NAI2DVector* steeringForce;

@property (nonatomic, retain) MGVehicle* targetAgent1;
@property (nonatomic, retain) MGVehicle* targetAgent2;
@property (nonatomic, retain) MGVehicle* targetAgent3;
@property (nonatomic, retain) NAI2DVector* offsetPosition;

@property (readwrite) float sqWayPointGoalDist;
@property (readwrite) BOOL behaviorActive;
@property (readwrite) BOOL arriveBehaviorComplete;
@property (readwrite) BOOL seekBehaviorComplete;

- (NAI2DVector*) calculate;
- (NAI2DVector*) sendVectorOffScreen:(NAI2DVector*)posVector;

- (NAI2DVector*) seek:(NAI2DVector*)targetPos;
- (NAI2DVector*) flee:(NAI2DVector*)targetPos;
- (NAI2DVector*) arrive:(NAI2DVector*)targetPos deceleration:(NAISBDeceleration)deceleration;
- (NAI2DVector*) followPath;
- (NAI2DVector*) offsetPursuit:(MGVehicle*)targetVehicle offsetVector:(NAI2DVector*)offsetVector;
- (NAI2DVector*) pursuit:(MGVehicle*)targetVehicle;
- (NAI2DVector*) face:(MGVehicle*)targetVehicle;

- (void) turnOffAllBehaviors;

- (void) setSeekOn;
- (void) setSeekOff;

- (void) setArriveOn;
- (void) setArriveOff;

- (void) setFollowPathOn;
- (void) setFollowPathOff;

- (void) setOffsetPursuitOnWithTarget:(MGVehicle*)targetVehicle offset:(NAI2DVector*)offsetVector refSprite:(CCSprite*)refSprite;
- (void) setOffsetPursuitOff;

- (void) setPursuitOnWithTarget:(MGVehicle*)targetVehicle;
- (void) setPursuitOff;

- (void) setFaceOnWithTarget:(MGVehicle*)targetVehicle;
- (void) setFaceOff;

- (BOOL) behaviorOn:(int)behaviorType;


@end
