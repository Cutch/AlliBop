//
//  SpeechBubble.h
//  AlliBop
//
//  Created by M on 2014-07-06.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SpeechBubble : SKSpriteNode

+(SpeechBubble *) SpeechBubbleWithText:(NSString*)text pos:(CGPoint)point;

@end
