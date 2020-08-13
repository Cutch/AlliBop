//
//  SpeechBubble.m
//  AlliBop
//
//  Created by M on 2014-07-06.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import "SpeechBubble.h"

@implementation SpeechBubble

const int fontSize = 5; // Font Size
const int corners = 10;
+(SpeechBubble *) SpeechBubbleWithText:(NSString*)text pos:(CGPoint)point{
    int width = 200; // MaxWidth
    int height;
    
    //Text Image
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paraStyle.lineSpacing = 0.5;
    UIFont*font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    NSDictionary*attri = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width/2, 800) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attri context:nil];
    rect.origin.x +=4;
    rect.size.width+=5;
    rect.size.height+=2;
    
    // Draw Text
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    //[text drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping];
    [text drawInRect:rect withAttributes:attri];
    UIImage* textImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    SKSpriteNode *textNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImage:textImage]];
    textNode.zPosition=21;
    height = rect.size.height*2+3;
    width = rect.size.width*2+5;
    
    //Speech Bubble
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, corners, 0);
    CGPathAddLineToPoint(path, nil, width-corners, 0);
    CGPathAddLineToPoint(path, nil, width+10, -10);
    CGPathAddLineToPoint(path, nil, width, 7);
    CGPathAddArcToPoint(path, nil, width, height, width/2, height, corners);
    CGPathAddArcToPoint(path, nil, 0, height, 0, height/2, corners);
    CGPathAddArcToPoint(path, nil, 0, 0, width/2, 0, corners);
    
    SKShapeNode* shape = [SKShapeNode node];
    [shape setPath:path];
    shape.strokeColor = [UIColor blackColor];
    shape.lineWidth=1;
    shape.fillColor = [UIColor whiteColor];
    shape.zPosition=20;
    shape.position=CGPointMake(-width, -height);
    textNode.position=CGPointMake(-width/2-2.5, -height/2-2.5);
     
    SpeechBubble *bubble = [[SpeechBubble alloc] init];
    [bubble addChild:shape];
    [bubble addChild:textNode];
    bubble.zPosition=101;
    [bubble setAnchorPoint:CGPointMake(1, 0)];
    bubble.position = point;
    return bubble;
}
@end
