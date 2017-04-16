//
//  MGVehicle.m
//  Object Motion Sandbox
//
//  Created by Paul De Leon on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NAISteeringBehavior.h"
#import "NAI2DVector.h"

#import "MGEnemyDirector.h"
#import "MGGameLogic.h"
#import "MGVehicle.h"

#import "MGGameManager.h"

@implementation MGVehicle

@synthesize targetPosition;

@synthesize steeringBehavior;
@synthesize smoothedHeading;
@synthesize smoothingOn;

@synthesize rotatingBody;

@synthesize timeElapsed;
@synthesize pursuer;

@synthesize vehicleGroup;
@synthesize groupBehaviorEnabled;
@synthesize markedForHoming;

- (void) dealloc
{
    [targetPosition release];
    targetPosition = nil;
    
    [steeringBehavior release];
    steeringBehavior = nil;
    
    [smoothedHeading release];
    smoothedHeading = nil;
    
    vehicleGroup = nil;    
    
    [super dealloc];
}



-(id) init
{
    self = [super init];
    
	if (self) 
    {
        targetPosition = [[NAI2DVector alloc] initWithVector:naivec(0.0, 0.0)];
        
        steeringBehavior = [[NAISteeringBehavior alloc] init];
        [steeringBehavior setVehicle:self];
        
        smoothedHeading = [[NAI2DVector alloc] init];
        
        smoothingOn = NO;
        rotatingBody = YES;
        
        timeElapsed = 0.0;
        pursuer = nil;
        vehicleGroup = nil;
        
        groupBehaviorEnabled = NO;
        markedForHoming = NO;        
    }
    return self;
}



+ (id) vehicleWithData:(NSDictionary*)inData
{
    id newVehicle = nil;
    MGGameObjectType objectType = [(NSNumber*) [inData objectForKey:@"VehicleBaseType"] intValue];
    
    switch (objectType) 
    {
        case kObjectTypeEnemy:
            newVehicle = [SHARED_ENEMY_DIRECTOR spawnEnemyWithData:inData];
            break;
            
        case kObjectTypePowerUp:
            newVehicle = [SHARED_LOGIC_MODULE spawnPowerUpWithType:[(NSNumber*) [inData objectForKey:@"VehicleType"] intValue] data:inData];
            break;
            
        default:
            NSAssert(1 == 2, @"Invalid object type read in.");
            break;
    }
    
    return newVehicle;
}


- (void) initAttributesFromFile:(NSString*)attribFileName
{
//    NSString *naiAttribsPath = [[NSBundle mainBundle] pathForResource:attribFileName ofType:@"plist"];
    NSString* naiAttribsPath = [SHARED_GAME_MANAGER loadMGPlistFile:attribFileName];
    
    NSMutableDictionary* naiAttribs = [[[NSMutableDictionary alloc] initWithContentsOfFile:naiAttribsPath] autorelease];
    
    NSAssert(naiAttribs != nil, @"Cannot find AI Attribs plist file:%@", attribFileName);
    
    [self setMass:[(NSNumber*) [naiAttribs objectForKey:@"mass"] floatValue]];
    [self setMaxSpeed:[(NSNumber*) [naiAttribs objectForKey:@"maxSpeed"] floatValue]];
    [self setMaxThrustForce:[(NSNumber*) [naiAttribs objectForKey:@"maxThrustForce"] floatValue]];
    [self setMaxTurnRate:[(NSNumber*) [naiAttribs objectForKey:@"maxTurnRate"] floatValue]];    
    [[self steeringBehavior] setSqWayPointGoalDist:[[naiAttribs objectForKey:@"SqDistance"] floatValue]];
    
    NSAssert([naiAttribs objectForKey:@"SqDistance"] != nil, @"SqDistance not found in attribute file:%@", attribFileName);
}


- (void) updateObject:(ccTime)deltaTime
{
    [super updateObject:deltaTime];
    
    // Acceleration = Force / Mass
    NAI2DVector* steeringForce = [steeringBehavior calculate];
    NAI2DVector* acceleration = [steeringForce scalarDivOperator:mass];
    
    // Update Velocity
    NSAssert(velocity != nil, @"Velocity vector not properly initialized.");
    [velocity addVector:[acceleration scalarMultOperator:deltaTime]];
//    [velocity truncate:maxSpeed];
    [velocity truncateX:maxSpeed Y:maxSpeed];
        
    // Update Position
    NAI2DVector* displacement = [velocity scalarMultOperator:deltaTime];
    [self setPosition:ccp([self position].x + [displacement x], [self position].y + [displacement y])];
    
    [self setRunningHorizDist:[self runningHorizDist] + fabsf([displacement x])];
    
    // Update the heading if vehicle has velocity greater than a very small value (avoids divide by zero)
    if ([velocity lengthSqrd] > 0.00000001)  
    {
        [heading setCompsFromVector:velocity];
        [heading normalize];
                
        [side setCompsFromVector:heading];
        [side perpindicular];

        if (rotatingBody == YES) {
            [self setRotation:nai_radians_to_deg(atan2f([heading y], -1 * [heading x]))];
        }
        
        /*
        if ([heading x] >= 0.0) {
            [self setFlipY:YES];
        }
        else {
            [self setFlipY:NO];            
        }
        */
    }
}





@end
