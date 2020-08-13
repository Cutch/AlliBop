//
//  PowerUpCan.m
//  AlliBop
//
//  Created by M on 2014-09-09.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import "PowerUpCan.h"

@implementation PowerUpCan

static NSString *canImage[7] = {@"OCan", @"RCan", @"PCan", @"BCan", @"YCan", @"PICan", @"WCan" };
static NSString *canMaskImage[7] = {@"OPaint Colour Mask", @"RPaint Colour Mask", @"PPaint Colour Mask", @"BPaint Colour Mask", @"YPaint Colour Mask", @"PIPaint Colour Mask", @"WPaint Colour Mask"};
static bool imagesLoaded = false;
static SKTexture *mask;
static SKColor *paintColours[7];
SKAction *nextAction = NULL;
bool actionRunning = false;

+(void) loadImages{
    imagesLoaded = true;
    mask = [SKTexture textureWithImageNamed:@"Paint Bucket Mask"];
    // Make some colours
    paintColours[0] = [SKColor colorWithRed:1 green:.5 blue:0 alpha:1];        // Orange
    paintColours[1] = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];         // Red
    paintColours[2] = [SKColor colorWithRed:0.6 green:0 blue:0.784 alpha:1];   // Purple
    paintColours[3] = [SKColor colorWithRed:0 green:0 blue:1 alpha:1];         // Blue
    paintColours[4] = [SKColor colorWithRed:1 green:1 blue:0 alpha:1];         // Yellow
    paintColours[5] = [SKColor colorWithRed:1 green:0.412 blue:0.706 alpha:1]; // Pink
    paintColours[6] = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];         // White
}
-(void) nextActions{
    
    if(nextAction){
        [colourBox removeAllActions];
        [colourBox runAction:nextAction completion:^{
            [self nextActions];
        }];
        nextAction = NULL;
        actionRunning=true;
    }
    else actionRunning = false;
}
-(void) setFillPercentage:(CGFloat) percentage{
    //if(percentage == 0)
    //    [colourBox setYScale:percentage];
    //else
    if(actionRunning)
        nextAction = [SKAction scaleYTo:percentage duration:0.3];
    else{
        [colourBox runAction:[SKAction scaleYTo:percentage duration:0.3] completion:^{
            [self nextActions];
        }];
        actionRunning=true;
    }
}
+(PowerUpCan *) CanWithColour:(int)colour{
    if(!imagesLoaded)
        [self loadImages];
    SKSpriteNode* colourBox;
    SKSpriteNode* can = [SKSpriteNode spriteNodeWithImageNamed:canImage[colour]];
    colourBox = [SKSpriteNode spriteNodeWithImageNamed:canMaskImage[colour]];
    //colourBox = [SKSpriteNode spriteNodeWithColor:paintColours[colour] size:CGSizeMake(40, 40)];
    [colourBox setAnchorPoint:CGPointMake(0.5, 0)];
    colourBox.position = CGPointMake(0, -15.75);
    [colourBox setYScale:0.0];
    colourBox.zPosition=1;
    //[colourBox runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleYTo:0 duration:1],[SKAction scaleYTo:1 duration:1]]]]];
    can.zPosition=2;
    
    PowerUpCan * g=[PowerUpCan spriteNodeWithTexture:mask];
    g->colourBox = colourBox;
    [g addChild:can];
    [g addChild:colourBox];
    g.name = @"powerCan";
    g.zPosition=0;
    return g;
}
@end
