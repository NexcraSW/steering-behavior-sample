//
//  MGVehicle.h
//  Object Motion Sandbox
//
//  Created by Paul De Leon on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MGMovingGameObject.h"

@class MGVehicleGroup;
@class NAISteeringBehavior;
@class NAI2DVector;

@interface MGVehicle : MGMovingGameObject
{
    // id gameWorld;      // this is supposed to be a pointer to the game world's obsticles/paths
    NAI2DVector* targetPosition;    // going to use this for now instead of the game world
    
    NAISteeringBehavior* steeringBehavior;
    
    // NAISmoother;     // used to smooth the vehicles heading to eliminate jerky movement
    NAI2DVector* smoothedHeading;
    BOOL smoothingOn;

    BOOL rotatingBody;
    
    float timeElapsed;
    
    // NSMutableArray* vehicleShapes;   // not sure what this is for, not using for now till they ask for it
    MGVehicle* pursuer; // pointer to a pursuing vehicle
    
    MGVehicleGroup* vehicleGroup;       // ref to VehicleGroup that this particular vehicle belongs to
    BOOL groupBehaviorEnabled;
    BOOL markedForHoming;
}

@property (nonatomic, retain) MGVehicle* pursuer;       // PD 7/5/2012 - It looks like this property is never used
@property (nonatomic, retain) NAI2DVector* targetPosition;
@property (nonatomic, retain) NAISteeringBehavior* steeringBehavior;
@property (nonatomic, retain) NAI2DVector* smoothedHeading;
@property (nonatomic, assign) MGVehicleGroup* vehicleGroup;

@property (readwrite) BOOL smoothingOn;
@property (readwrite) BOOL rotatingBody;
@property (readwrite) float timeElapsed;
@property (readwrite) BOOL groupBehaviorEnabled;
@property (readwrite) BOOL markedForHoming;

+ (id) vehicleWithData:(NSDictionary*)inData;
- (void) initAttributesFromFile:(NSString*)attribFileName;

@end
