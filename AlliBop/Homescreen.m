//
//  Homescreen.m
//  AlliBop
//
//  Created by M on 2014-07-02.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import "Homescreen.h"
@implementation Homescreen
@synthesize delegate;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKLabelNode* startLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        startLabel.fontSize = 22;
        startLabel.position = CGPointMake(240, 160);
        startLabel.text = @"Start Game";
        [self addChild:startLabel];
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    //for (UITouch *touch in touches) {
        //CGPoint location = [touch locationInNode:self];
        //SKNode *node = [self nodeAtPoint:location];
    //}
    [self.view presentScene:nil];
    [self.delegate homescreenReturn:0];
}
@end
