//
//  MyScene.m
//  AlliBop
//
//  Created by M on 4/22/2014.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//
#import "AlliScene.h"
#import "Bopper.h"
#import "Gator.h"
#import "PowerUpCan.h"
#import "ConveyerBelt.h"
#import "SpeechBubble.h"

@implementation AlliScene
const int scoreIncrease = 20;
const int moveGatorX = 530;
int score = 0;
int level = 1;
double count = 0; // Should really be called clock, 1 every tenth of a second
double spawnTime = 16; // Gator Spawn Interval
double duration = 10; // Gator Speed
double spawnGatorClock = 10; // Initial Time
double spawnTimes[4];
int numColours = 3;
int numCols = 4;
int pointBoxesColour[4][10];
int powerups[7]={0,0,0,0,0,0,0};
int powerupsLvl[7]={1,1,1,1,1,1,1};
int gatorPath[2] = {380,150};
//SKSpriteNode *oldPointBoxesNode[4][4];
NSMutableArray *rowSorter;
NSMutableArray *colourSorter;
SKColor *paintColours[7];
SKSpriteNode *pointBoxesNode[4][10];
PowerUpCan *powerUpCan[7];
SKSpriteNode *pauseButton;
SKSpriteNode *boppers[4];
SKLabelNode *lab;
SKLabelNode *scoreLabel;
SKLabelNode *slowLabel;
SKLabelNode *sortLabel;
SKLabelNode *dblLabel;
SKLabelNode *autoLabel;
SKLabelNode *pwrLabel;
SKLabelNode *levelLabel;
NSString *powerUpNames[4] = {@"x2 Points", @"Auto Bop", @"Sort", @"Slow"};
// Shuffle Map
bool sortColours = false;
const int sortColourCounter = 600; //1500;
int sortColourCounterC = 600; //1500;
// Spawn Gators
int startSpawnClock = -1;
bool spawnGators = true;
// Regular Power Ups
bool slowGator = false;
int slowGatorClock = 0;
bool doublePoints = false;
int doublePointsClock = 0;
bool autoBop = false;
int autoBopClock = 0;
bool sortSpawn = false;
int sortSpawnClock = 0;
int sortColour = 0;
int powerUpLabelClock = -1;
int gatorUps = 0; // Which gators are allowed
SKAction *tagSequence;
SKAction *gatorInitialMoveSequence;
SKAction *gatorSlowInitialMoveSequence;
SKAction *bop;
SKAction *bopOpen;
SKAction *bopClose;
SKAction *bopDestroy;
SKAction *bopOpenDestroy;
SKAction *gatorSelector;

/*
 * Create a movement sequence for a gator that calls a function (checkGatorNode) every time it passes an auto bopper
 */
-(SKAction *)createGatorMovementSequence:(float) duration withxPos:(float)xPos{
    NSMutableArray * mutseq = [[NSMutableArray alloc] init];
    SKAction *link, *grouped;
    int x = 10;
    float moveX;
    for(int i = 0; i < 2; i++){
        // Check if the gator has already passed this segment
        if(xPos <= x+gatorPath[i]){
            moveX = gatorPath[i];
            // Check if the Gator has moved partially through this sement, if so correct
            if(xPos > x){
                moveX = moveX - (xPos - x);
            }
            // Movement Segment
            link = [SKAction moveByX:moveX y:0 duration:moveX/moveGatorX*duration];
            
            if(i==0) // First segment is just movement
                grouped = link;
            else // Group segment with a function call, run when movement starts
                grouped = [SKAction group:@[link,gatorSelector]];
            // Add to sequence array
            [mutseq addObject:grouped];
        }
        x = x + gatorPath[i];
    }
    // After movement (off screen) remove the gator
    [mutseq addObject:[SKAction removeFromParent]];
    // Create and return sequence
    return [SKAction sequence:mutseq];
}
/*
 * Custom action function, time means nothing
 * When passing a bop point check if the gator should be bopped
 */
- (void) checkGatorNode:(SKNode*)gator time:(CGFloat) time {
    int phase, row;
    @synchronized(gator){
        @try {
            phase = [[gator valueForKey:@"phase"] intValue];
            if(autoBop){
                row = [[gator valueForKey:@"row"] intValue];
            }
            [gator setValue:[NSNumber numberWithInt:(phase+1)] forKey:@"phase"];
        }
        @catch (NSException *exception) {
            return;
        }
    }
    if(autoBop){ //Auto Bop Check
        //Check if its ontop of its colour
        if(phase >= 2 &&
           gator.position.x - gator.frame.size.width < self.size.width){
            [boppers[row] runAction:bop];
            //Run a destroy action with a delay .3 seconds
            [gator runAction:bopDestroy completion:^{
                [self addTag:[NSString stringWithFormat:@"+%d", 0] point:CGPointMake(465, 60+70*row)];
            }];
        }
    }
}
/*
 * Change the ALL the Gators' movement speeds based on a multiplier,
 * Multiplier affects duration, ie.0 will move in an instant, 2 will be double the duration for movement
 */
- (void) replaceGatorActions:(double) multiplier{
    NSArray *children = [self children];
    NSIndexSet *indexes = [children indexesOfObjectsPassingTest:^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [[obj name] isEqualToString:@"gator"];
    }];
    NSUInteger index = [indexes firstIndex];
    while ( index != NSNotFound ) {
        SKSpriteNode *gator = children[index];
        [gator removeActionForKey:@"movement"];
        SKAction *gatorMove;
        if(multiplier == 0)
            gatorMove = [SKAction moveByX:0 y:0.0 duration:1];
        else
            gatorMove = [self createGatorMovementSequence:duration*multiplier withxPos:gator.position.x];
        [gator runAction:gatorMove withKey:@"movement"];
        index = [indexes indexGreaterThanIndex: index];
    }
}
/*
 * Add a tag which disappears after a few seconds
 * Used to display points recieved, default black
 */
- (void) addTag:(NSString *) tag point:(CGPoint) Point
{
    SKLabelNode *tagLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    tagLabel.fontSize = 18;
    tagLabel.fontColor = [UIColor blackColor];
    tagLabel.position = Point;
    tagLabel.zPosition = 100;
    tagLabel.text = tag;
    [self addChild:tagLabel];
    [tagLabel runAction:tagSequence];
}
/*
 * Called when paint is put in correct bucket
 * Check to see if a power up should be activated
 */
- (void) checkPowerUp:(int) colour
{
    if(powerups[colour] >= powerupsLvl[colour]*3+5){ // Power Up every 5
        switch(colour){
            case 0: // Orange
                doublePointsClock = count + powerupsLvl[colour]*20+30;
                doublePoints = true;
                break;
            case 2: // Purple
                sortSpawnClock = count + powerupsLvl[colour]*20+30;
                sortSpawn = true;
                sortColour = arc4random_uniform(numColours);
                break;
            case 3: // Blue
                slowGatorClock = count + powerupsLvl[colour]*20+30;
                slowGator = true;
                [self replaceGatorActions:2];
                break;
            case 1: // Red
                autoBopClock = count + powerupsLvl[colour]*20+30;
                autoBop = true;
                // Basically the touch code, except the point is at each bopper
                NSArray *children = [self children];
                NSIndexSet *indexes = [children indexesOfObjectsPassingTest:^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
                    return [[obj name] isEqualToString:@"gator"];
                }];
                NSUInteger index = [indexes firstIndex];
                while ( index != NSNotFound ) {
                    SKSpriteNode *gator = children[index];
                    int row = [[gator valueForKey:@"row"] intValue];
                    int phase = [[gator valueForKey:@"phase"] intValue];
                    if(phase >= 2 &&
                       gator.position.x - gator.frame.size.width < self.size.width){
                        [boppers[row] runAction:bop];
                        //Run a destroy action with a delay .3 seconds
                        [gator runAction:bopDestroy completion:^{
                            [self addTag:[NSString stringWithFormat:@"+%d", 0] point:CGPointMake(465, 60+70*row)];
                        }];
                    }
                }
                break;
        }
        pwrLabel.fontColor = paintColours[colour];
        pwrLabel.text = powerUpNames[colour];
        powerUpLabelClock = count + 30 + (powerupsLvl[colour]>1?10:0);
        //Get score for a power up
        int s = powerupsLvl[colour] * 10 * (doublePoints?2:1);
        score = score + s;
        [self addTag:[NSString stringWithFormat:@"+%d", s] point:CGPointMake(250+60*colour, 278)];
        scoreLabel.text = [NSString stringWithFormat:@"Score: %0d", score];
        // Fill up the power up can
        [powerUpCan[colour] setFillPercentage:1];
        powerupsLvl[colour]++;
        powerups[colour] = 0;
    }
    // Fill up the power up can
    [powerUpCan[colour] setFillPercentage:((float)powerups[colour] / (float)(powerupsLvl[colour]*5.0))];
}
/*
 * Function to randomly sort an array
 * used to sort colours randomly
 */
- (void)shuffle:(NSMutableArray *)collection
{
    int count = [collection count];
    for (int i = 0; i < count; ++i) {
        int remainingCount = count - i;
        int exchangeIndex = i + arc4random_uniform(remainingCount);
        [collection exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}
/* 
 * Called every tenth of a second
 * Check power up timers, spawn gators, cehck when to shuffle map
 */
- (void)timerFired:(NSTimer *)timer {
    int row, colour, i;
    if(![self isPaused]){
        count++;
        if(count == startSpawnClock){
            sortColours = false;
            spawnGators = true;
            [self replaceGatorActions:1];
        }
        // ---------  Spawn Gators  -------------
        if(spawnGators){
            if(count >= spawnGatorClock){
                spawnGatorClock = count + spawnTime*(slowGator?2:1);
                [self shuffle:rowSorter];
                for(i = 0; i < 4; i++)
                {
                    row = [rowSorter[i] intValue];
                    if(count >= spawnTimes[row]+(slowGator?850 / (moveGatorX / (double)duration):0)) break; // Double the time if slowed
                }
                if(i < 4){
                    int augment = [Gator augmentSelector:gatorUps];
                    //powerups[3]++;
                    //[self checkPowerUp:3];
                    if(sortSpawn)
                        colour = sortColour;
                    else
                        colour = pointBoxesColour[row][arc4random_uniform(numColours)];
                    
                    // How long it will take the row to clear for another gator
                    spawnTimes[row] = count + 850 / (moveGatorX / (double)duration);
                    //Spawn Gator
                    if(augment == 2){
                        if(sortSpawn)augment--;
                        else{
                            int colour2;
                            do{
                                colour2 = pointBoxesColour[row][arc4random_uniform(numColours)];
                            }while(colour2 == colour);
                            colour |= colour2<<8;
                        }
                    }
                    Gator *alli = [Gator GatorWithColour:colour augment:augment];
                    [alli setValue:[NSNumber numberWithInt:row] forKey:@"row"];
                    alli.position = CGPointMake(10,34+row*70);
                    alli.zPosition = 3;
                    [self addChild:alli];
                    if(slowGator)
                        [alli runAction:gatorSlowInitialMoveSequence withKey:@"movement"];
                    else
                        [alli runAction:gatorInitialMoveSequence withKey:@"movement"];
                }
            }
            
        }
        //Power Ups
        if(autoBop){
            if(count == autoBopClock){
                for(int i = 0; i < 4; i++)
                    [boppers[i] runAction:bopClose];
                autoBop = false;
                autoLabel.text = @"0.0";
            } else
                autoLabel.text = [NSString stringWithFormat:@"%0.1f", (autoBopClock-count)/10.0];
        }
        if(sortSpawn){
            if(count == sortSpawnClock){
                sortSpawn = false;
                sortLabel.text = @"0.0";
            } else
                sortLabel.text = [NSString stringWithFormat:@"%0.1f", (sortSpawnClock-count)/10.0];
        }
        if(slowGator){
            if(count == slowGatorClock){
                for(int s = 0; s < 4; s++){ // Account for the fact that the gators were moving at half speed
                    if(count < spawnTimes[s]){
                        int t = (850 / (moveGatorX / (double)duration)) - (spawnTimes[s] - count);
                        spawnTimes[s] = t*2 + ((850 / (moveGatorX / (double)duration)) - t) + count;
                    }
                }
                slowGator = false;
                slowLabel.text = @"0.0";
                [self replaceGatorActions:1];
            } else
                slowLabel.text = [NSString stringWithFormat:@"%0.1f", (slowGatorClock-count)/10.0];
        }
        if(doublePoints){
            if(count == doublePointsClock){
                doublePoints = false;
                dblLabel.text = @"0.0";
            } else
                dblLabel.text = [NSString stringWithFormat:@"%0.1f", (doublePointsClock-count)/10.0];
        }
        if(count == powerUpLabelClock){
            pwrLabel.text = @"";
        }
        //Shuffle Map
        if(count == sortColourCounterC){
            [self nextLevel];
            int y, x, c;
            SKAction *moveDown = [SKAction moveByX:-400 y:0.0 duration:4];
            SKAction *seq = [SKAction sequence:@[moveDown, [SKAction removeFromParent]]];
            sortColourCounterC=sortColourCounter+count;
            spawnGators = false;
            sortColours = true;
            spawnGatorClock = spawnGatorClock + 40;
            startSpawnClock = count + 40;
            for (y = 0; y < 4; y++){
                [self shuffle:colourSorter];
                for (x = 0; x < numCols; x++){
                    if(x >= numColours)
                        c = [colourSorter[arc4random_uniform(numColours)] intValue];
                    else
                        c = [colourSorter[x] intValue];
                    [self replaceGatorActions:0];
                    ConveyerBelt *conveyer = [ConveyerBelt ConveyerWithColour:c pos:CGPointMake(500+x*100,34+y*70)];
                    [self addChild:conveyer];
                    [pointBoxesNode[y][x] runAction:seq];
                    [conveyer runAction:moveDown];
                    pointBoxesNode[y][x] = conveyer;
                    pointBoxesColour[y][x] = c;
                }
            }
        }
    }
}
-(void) addColour{
    //Add Power Up Can
    PowerUpCan *can = [PowerUpCan CanWithColour:numColours];
    can.position = CGPointMake(430-numColours*35,298);
    [self addChild:can];
    powerUpCan[numColours] = can;
    //Add colour
    numColours++;
    colourSorter = [[NSMutableArray alloc] init];
    for(int i = 0; i < numColours; i++)
        [colourSorter addObject:[NSNumber numberWithInt:i]];
}
-(void) nextLevel{
    level++;
    levelLabel.text = [NSString stringWithFormat:@"%d", level];
    switch(level){
        case 2:
            [self addColour];
            break;
        case 3:
            gatorUps++;
            break;
        case 4:
            gatorUps++;
            break;
        case 5:
            [self addColour];
            break;
        case 6:
            break;
        case 7:
            numCols = 5;
            break;
        case 8:
            [self addColour];
            break;
        case 9:
            break;
        case 10:
            break;
        case 11:
            [self addColour];
            break;
        case 12:
            numCols = 6;
            break;
        case 13:
            break;
    }
}
/*
 * Main function, called once
 */
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        // Initialize some actions so we dont have to recreate them
        tagSequence = [SKAction sequence:@[[SKAction group:@[[SKAction moveByX:0 y:13.0 duration:2], [SKAction fadeAlphaTo:0.0 duration:2]]], [SKAction removeFromParent]]];
        bopOpen = [SKAction animateWithTextures:BOPPER_ANIM_OPEN timePerFrame:0.030]; // 0.200s
        bopClose = [SKAction animateWithTextures:BOPPER_ANIM_CLOSE timePerFrame:0.030]; // 0.200s
        bop = [SKAction animateWithTextures:BOPPER_ANIM_BOPPER timePerFrame:0.020]; // 0.300s for half
        bopDestroy = [SKAction sequence:@[[SKAction waitForDuration:0.3], [SKAction removeFromParent]]];
        bopOpenDestroy = [SKAction sequence:@[[SKAction waitForDuration:0.6], [SKAction removeFromParent]]];
        gatorSelector = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            [self checkGatorNode:node time:elapsedTime];
        }];
        gatorInitialMoveSequence = [self createGatorMovementSequence:duration withxPos:10];
        gatorSlowInitialMoveSequence = [self createGatorMovementSequence:duration*2 withxPos:10];
        
        // Make some colours
        paintColours[0] = [SKColor colorWithRed:1 green:.5 blue:0 alpha:1];        // Orange
        paintColours[1] = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];         // Red
        paintColours[2] = [SKColor colorWithRed:0.6 green:0 blue:0.784 alpha:1];   // Purple
        paintColours[3] = [SKColor colorWithRed:0 green:0 blue:1 alpha:1];         // Blue
        paintColours[4] = [SKColor colorWithRed:1 green:1 blue:0 alpha:1];         // Yellow
        paintColours[5] = [SKColor colorWithRed:1 green:0.412 blue:0.706 alpha:1]; // Pink
        paintColours[6] = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];         // White
        
        // Create an array from 0-3 which can be shuffled
        rowSorter = [[NSMutableArray alloc] init];
        for(int i = 0; i < 4; i++)
            [rowSorter addObject:[NSNumber numberWithInt:i]];
        colourSorter = [[NSMutableArray alloc] init];
        for(int i = 0; i < numColours; i++)
            [colourSorter addObject:[NSNumber numberWithInt:i]];
        
        // Create the floor
        SKSpriteNode *map = [SKSpriteNode spriteNodeWithImageNamed:@"Floor2"];
        [map setAnchorPoint:CGPointZero];
        [self addChild:map];
        
        // Create Pause Button
        pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pause"];
        pauseButton.position = CGPointMake(15,295);
        [self addChild:pauseButton];
        
        // SPEECH BUBBLE
        //SpeechBubble* sb = [SpeechBubble SpeechBubbleWithText:@"This is a test" pos:CGPointMake(400, 260)];
        //[self addChild:sb];
        
        // Create Boppers
        for(int i = 0; i < 4; i++){
            SKSpriteNode *bopper = [SKSpriteNode spriteNodeWithTexture:BOPPER_TEX_BOPPER0030];
            bopper.position = CGPointMake(467,48.5+i*70);
            bopper.zPosition=11;
            [bopper setScale:0.63];
            [self addChild:bopper];
            boppers[i] = bopper;
        }
        
        for(int i = 0; i < numColours; i++){ // Power Up Boxes
            PowerUpCan *can = [PowerUpCan CanWithColour:i];
            can.position = CGPointMake(430-i*35,298);
            [self addChild:can];
            powerUpCan[i] = can;
        }
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        // Conveyer Belt Boxes
        int c, x, y;
        for (y = 0; y < 4; y++){
            [self shuffle:colourSorter];
            for (x = 0; x < 4; x++){
                if(x == 3)
                    c = [colourSorter[arc4random()%3] intValue];
                else c = [colourSorter[x] intValue];
                ConveyerBelt *conveyer = [ConveyerBelt ConveyerWithColour:c pos:CGPointMake(100+x*100,34+y*70)];
                [self addChild:conveyer];
                pointBoxesNode[y][x] = conveyer;
                pointBoxesColour[y][x] = c;
            }
        }
        // Create conveyers that dont move at the end of the screen
        for (y = 0; y < 4; y++){
            SKSpriteNode *tile = [SKSpriteNode spriteNodeWithImageNamed:@"conveytexture2"];
            tile.zPosition=2;
            tile.position = CGPointMake(500,34+y*70);
            [self addChild:tile];
        }
        // Head Bar
        SKSpriteNode *bar = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:1.0]
                                                          size:CGSizeMake(50, 280)];
        bar.position = CGPointMake(25,140);
        bar.zPosition=10;
        [self addChild:bar];
        
        SKSpriteNode *labelBar = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]
                                                         size:CGSizeMake(240, 14)];
        labelBar.position = CGPointMake(240,139);
        labelBar.zPosition=98;
        [self addChild:labelBar];
        SKSpriteNode *labelBarOutline = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:1.0]
                                                              size:CGSizeMake(242, 16)];
        labelBarOutline.position = CGPointMake(240,139);
        labelBarOutline.zPosition=97;
        [self addChild:labelBarOutline];
        // Double Label
        dblLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        dblLabel.fontSize = 18;
        dblLabel.fontColor = paintColours[0];
        dblLabel.position = CGPointMake(140, 132);
        dblLabel.zPosition = 99;
        dblLabel.text = @"0.0";
        [self addChild:dblLabel];
        // Slow Label
        slowLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        slowLabel.fontSize = 18;
        slowLabel.fontColor = paintColours[2];
        slowLabel.position = CGPointMake(180, 132);
        slowLabel.zPosition = 99;
        slowLabel.text = @"0.0";
        [self addChild:slowLabel];
        // Pwr Label
        pwrLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        pwrLabel.fontSize = 18;
        pwrLabel.fontColor = paintColours[0];
        pwrLabel.position = CGPointMake(240, 132);
        pwrLabel.zPosition = 99;
        pwrLabel.text = @"";
        [self addChild:pwrLabel];
        // Auto Label
        autoLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        autoLabel.fontSize = 18;
        autoLabel.fontColor = paintColours[1];
        autoLabel.position = CGPointMake(300, 132);
        autoLabel.zPosition = 99;
        autoLabel.text = @"0.0";
        [self addChild:autoLabel];
        // Sort Label
        sortLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        sortLabel.fontSize = 18;
        sortLabel.fontColor = paintColours[3];
        sortLabel.position = CGPointMake(340, 132);
        sortLabel.zPosition = 99;
        sortLabel.text = @"0.0";
        [self addChild:sortLabel];
        // Score Label
        scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreLabel.fontSize = 20;
        scoreLabel.position = CGPointMake(95, 285);
        scoreLabel.zPosition = 99;
        scoreLabel.text = @"Score: 0";
        [self addChild:scoreLabel];
        levelLabel= [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        levelLabel.fontSize = 20;
        levelLabel.position = CGPointMake(10, 10);
        levelLabel.zPosition = 99;
        levelLabel.text = [NSString stringWithFormat:@"%d", level];
        [self addChild:levelLabel];
    }
    return self;
}
/*
 * Touch function
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        NSArray * nodesTouched = [self nodesAtPoint:location];
        // Check if the top node is the pause button
        if ([nodesTouched[nodesTouched.count-1] isEqual:pauseButton]){
            if([self isPaused]){
                [pauseButton setTexture:[SKTexture textureWithImageNamed:@"pause"]];
                [self setPaused:FALSE];
            }
            else{
                [pauseButton setTexture:[SKTexture textureWithImageNamed:@"play"]];
                [self setPaused:TRUE];
            }
        }else if(![self isPaused]){
            NSInteger colour = -1, s;
            SKNode* belt= nil;
            Gator* gator= nil;
            // Start from the top node and look for a gator node and bekt node
            for(int i = (int)nodesTouched.count-1; i >= 0; i--){
                if([[nodesTouched[i] name] isEqualToString:@"gator"]){
                    gator = nodesTouched[i];
                    if(belt)
                        break;
                }
                else if([[nodesTouched[i] name] isEqualToString:@"belt"]){
                    belt = nodesTouched[i];
                    // Stop when descended to the belt node
                    if(gator)
                        break;
                }
            }
            // If a gator was clicked, belt assumed to be
            if(belt && gator){
                int ret;
                @synchronized(gator){
                    ret = [gator tapped:nodesTouched];
                }
                if(ret>-1){
                    // Remove the gator & do score counting
                    // If colours are the same award max points
                    colour = [[belt valueForKey:@"colour"] integerValue];
                    if(colour == ret) {
                        s = scoreIncrease * (doublePoints?2:1);
                        score = score + (int)s;
                        powerups[colour]++;
                    }
                    else{ // Award minimal points
                        s = (doublePoints?2:1);
                        score = score + (int)s;
                    }
                    [self addTag:[NSString stringWithFormat:@"+%d", (int)s] point:location];
                    scoreLabel.text = [NSString stringWithFormat:@"Score: %0d", score];
                    if(s >= scoreIncrease) // If colours were the same check power ups
                        [self checkPowerUp:(int)colour];
                }
            }else if(gator){
                if(location.x >= 450){
                    // Remove the gator & do score counting
                    int ret;
                    @synchronized(gator){
                        ret = [gator tapped:nodesTouched];
                    }
                    if(ret>-1)
                        [self addTag:@"+0" point:location];
                }
            }
        }
    }
}
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
