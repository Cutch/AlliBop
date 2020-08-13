//
//  conveyerBelt.m
//  AlliBop
//
//  Created by M on 2014-07-02.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import "conveyerBelt.h"

@implementation ConveyerBelt

static CGColorRef colours[7];
static SKTexture *conveyerTexture[7];
static bool dataLoaded = false;
+(void) loadData{
    colours[0] = [[UIColor colorWithRed:1 green:0.5 blue:0 alpha:0.75] CGColor];       // Orange
    colours[1] = [[UIColor colorWithRed:1 green:0 blue:0 alpha:.75] CGColor];         // Red
    colours[2] = [[UIColor colorWithRed:0.6 green:0 blue:0.784 alpha:.75] CGColor];   // Purple
    colours[3] = [[UIColor colorWithRed:0 green:0 blue:1 alpha:.75] CGColor];         // Blue
    colours[4] = [[UIColor colorWithRed:1 green:1 blue:0 alpha:.75] CGColor];         // Yellow
    colours[5] = [[UIColor colorWithRed:1 green:0.412 blue:0.706 alpha:.75] CGColor]; // Pink
    colours[6] = [[UIColor colorWithRed:1 green:1 blue:1 alpha:.75] CGColor];         // White
    UIImage *image = [UIImage imageNamed:@"conveytexture2"];
    for(int i = 0; i < 7; i++){
        CGSize size;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        {
            size = CGSizeMake(50, 30);
            UIGraphicsBeginImageContextWithOptions( size, NO, 0 );
        } else {
            size = CGSizeMake(100, 60);
            UIGraphicsBeginImageContext( size );
        }
        CGRect rect = CGRectMake(0,0,size.width,size.height);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [image drawInRect:rect];
        CGContextSetBlendMode(context, kCGBlendModeHardLight); //kCGBlendModeScreen better? kCGBlendModeLighten, kCGBlendModeHardLight
        CGContextSetFillColorWithColor(context, colours[i]);
        CGContextFillRect(context, rect);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        conveyerTexture[i] = [SKTexture textureWithImage:newImage];
    }
    dataLoaded = true;
}
+(ConveyerBelt *) ConveyerWithColour:(int)colour pos:(CGPoint)point{
    if(!dataLoaded)
        [self loadData];
    ConveyerBelt *conveyer = [ConveyerBelt spriteNodeWithTexture:conveyerTexture[colour]];
    //SKSpriteNode *colouradd = [SKSpriteNode spriteNodeWithColor:colours[colour] size:CGSizeMake(100, 60)];
    //colouradd.blendMode = SKBlendModeScreen;
    //colouradd.zPosition=1;
    //[conveyer addChild:colouradd];
    conveyer.name = @"belt";
    conveyer.zPosition=0;
    conveyer.position = point;
    [conveyer setValue:[NSNumber numberWithInt:colour] forKey:@"colour"];
    return conveyer;
}
@end
