//
//  conveyerBelt.h
//  AlliBop
//
//  Created by M on 2014-07-02.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ConveyerBelt : SKSpriteNode
@property NSNumber *colour;
+(ConveyerBelt *) ConveyerWithColour:(int)colour pos:(CGPoint)point;
@end
