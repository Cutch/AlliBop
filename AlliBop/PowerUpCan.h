//
//  PowerUpCan.h
//  AlliBop
//
//  Created by M on 2014-09-09.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PowerUpCan : SKSpriteNode {
    SKSpriteNode *colourBox;
}
+(PowerUpCan *) CanWithColour:(int)colour;
-(void) setFillPercentage:(CGFloat) percentage;
@end
