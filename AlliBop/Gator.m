//
//  Gator.m
//  AlliBop
//
//  Created by M on 2014-06-30.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import "Gator.h"
#import "GatorAnime.h"
#import "Canp.h"
#import "Crown.h"

@implementation Gator

static NSString *gatorImage[4] = {@"OGatar", @"RGatar", @"PGatar", @"BGatar"};
static bool imagesLoaded = false;
static SKTexture *gatorTextures[4];
static SKAction *gatorAnim[4];
static SKTexture *gatorTextures_half[4];
static SKAction *gatorAnim_half[4];
static SKTexture *topsTextures[2];
static SKAction *topsAnim[2];

static NSArray *ogator_anim, *pgator_anim, *bgator_anim, *rgator_anim;
static NSMutableArray *ogator_anim_half, *pgator_anim_half, *bgator_anim_half, *rgator_anim_half;
+(void) loadImages{
    ogator_anim = OGATOR_ANIM;
    bgator_anim = BGATOR_ANIM;
    rgator_anim = RGATOR_ANIM;
    pgator_anim = PGATOR_ANIM;
    ogator_anim_half = [NSMutableArray arrayWithCapacity:49];
    bgator_anim_half = [NSMutableArray arrayWithCapacity:49];
    rgator_anim_half = [NSMutableArray arrayWithCapacity:49];
    pgator_anim_half = [NSMutableArray arrayWithCapacity:49];
    CGRect r = CGRectMake(0,0,0.5,1);
    for (int i=0; i<49; i++) {
        [ogator_anim_half addObject:[SKTexture textureWithRect:r inTexture:ogator_anim[i]]];
        [bgator_anim_half addObject:[SKTexture textureWithRect:r inTexture:bgator_anim[i]]];
        [rgator_anim_half addObject:[SKTexture textureWithRect:r inTexture:rgator_anim[i]]];
        [pgator_anim_half addObject:[SKTexture textureWithRect:r inTexture:pgator_anim[i]]];
    }
    
    
    imagesLoaded = true;
    gatorAnim[0] = [SKAction animateWithTextures:ogator_anim timePerFrame:0.042];
    gatorAnim[1] = [SKAction animateWithTextures:rgator_anim timePerFrame:0.042];
    gatorAnim[2] = [SKAction animateWithTextures:pgator_anim timePerFrame:0.042];
    gatorAnim[3] = [SKAction animateWithTextures:bgator_anim timePerFrame:0.042];
    gatorTextures[0] = OGATOR_TEX0001;
    gatorTextures[1] = RGATOR_TEX0001;
    gatorTextures[2] = PGATOR_TEX0001;
    gatorTextures[3] = BGATOR_TEX0001;
    gatorAnim_half[0] = [SKAction animateWithTextures:ogator_anim_half timePerFrame:0.042];
    gatorAnim_half[1] = [SKAction animateWithTextures:rgator_anim_half timePerFrame:0.042];
    gatorAnim_half[2] = [SKAction animateWithTextures:pgator_anim_half timePerFrame:0.042];
    gatorAnim_half[3] = [SKAction animateWithTextures:bgator_anim_half timePerFrame:0.042];
    gatorTextures_half[0] = ogator_anim_half[0];
    gatorTextures_half[1] = rgator_anim_half[0];
    gatorTextures_half[2] = pgator_anim_half[0];
    gatorTextures_half[3] = bgator_anim_half[0];
    topsAnim[0] = [SKAction animateWithTextures:CANP_ANIM timePerFrame:0.042];
    topsAnim[1] = [SKAction animateWithTextures:CROWN_ANIM timePerFrame:0.042];
    topsTextures[0] = CANP_TEX0001;
    topsTextures[1] = CROWN_TEX0001;
    // BALLOON topsTextures[2] = CANP_TEX0001;
    
}

+(int) augmentSelector:(int) max{
    if(max == 0) return 0;
    if(arc4random_uniform(10) < 5){
        return 0;
    }
    return arc4random_uniform(max+1);
}
+(Gator *) GatorWithColour:(int)colour augment:(int)a{
    if(!imagesLoaded)
        [self loadImages];
    int colour2;
    if(a == 2){ // Stripe
        colour2 = colour & 0xFF;
        colour = colour >> 8;
    }
    //Gator * g=[Gator spriteNodeWithTexture:gatorTextures[colour]];
    Gator * g=[Gator spriteNodeWithTexture:gatorTextures[colour]];
    g.name = @"gator";
    g.zPosition=5;
    [g setScale:0.5f];
    g->colour = colour;
    [g setValue:[NSNumber numberWithInt:0] forKey:@"phase"];
    g->striped = 0;
    int child = -1;
    SKSpriteNode * top;
    switch(a)
    {
        case 1: // Bucket
            child = 0;
            g->lives = 2;
            break;
        case 2:
            g->colour2 = colour2;
            top = [SKSpriteNode spriteNodeWithTexture:gatorTextures_half[colour2]];
            [top setPosition:CGPointMake(-45, 0)];
            top.zPosition = 6;
            top.name = @"tail";
            [g addChild:top];
            g->striped = 2;
            g->lives = 1;
            [top runAction:[SKAction repeatActionForever:gatorAnim_half[colour2]]];
            break;
        case 3: // Crown
            child = 1;
            g->lives = 3;
            break;
        default:
            g->lives = 1;
            break;
    }
    if(child != -1){
        top = [SKSpriteNode spriteNodeWithTexture:topsTextures[child]];
        top.zPosition=6;
        [top setScale:2.0f];
        [g addChild:top];
        [top runAction:[SKAction repeatActionForever:topsAnim[child]] withKey:@"anime"];
    }
    [g runAction:[SKAction repeatActionForever:gatorAnim[colour]] withKey:@"anime"];
    return g;
}
-(int) tapped:(NSArray*)nodesTouched{
    if(self->striped != 0){
        bool isTail = false;
        for(int i = (int)nodesTouched.count-1; i >= 0; i--){
            if([[nodesTouched[i] name] isEqualToString:@"tail"]){
                isTail = true;
            }
        }
        self->striped--;
        if(self->striped > 0){ // Lose heeads or tail
            [self removeAllChildren];
            if(isTail){
                return self->colour2;
            }else{
                int oc = self->colour;
                self->colour = self->colour2;
                [self removeActionForKey:@"anime"];
                [self setTexture:gatorTextures[self->colour]];
                [self runAction:[SKAction repeatActionForever:gatorAnim[self->colour]]];
                return oc;
            }
        }else{ // Die
            self->lives--;
        }
    }else
        self->lives--;
    
    if(self->lives <= 0){
        [self removeAllActions];
        [self removeAllChildren];
        [self removeFromParent];
        return self->colour;
    }else {
        if(self->lives==1)
            [self removeAllChildren];
        else if(self->lives == 2){
            SKSpriteNode* top = [self children][0];
            [top setZRotation:M_PI/5];
            //[top setTransform3D:CATransform3DMakeRotation(M_PI/4, 1.0, 0, 0)];
        }
        return -1;
    }
}

@end
