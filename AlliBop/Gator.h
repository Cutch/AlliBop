//
//  Gator.h
//  AlliBop
//
//  Created by M on 2014-06-30.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Gator : SKSpriteNode{
    int lives;
    int striped;
    int colour;
    int colour2;
}
@property NSNumber *row;
@property NSNumber *phase;
+(int) augmentSelector:(int)max;
+(Gator *) GatorWithColour:(int)colour augment:(int)a;
-(int) tapped:(NSArray*)nodesTouched;
@end
