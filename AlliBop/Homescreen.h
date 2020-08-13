//
//  Homescreen.h
//  AlliBop
//
//  Created by M on 2014-07-02.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <UIKit/UIKit.h>

@protocol SceneDelegate <NSObject>
    - (void)homescreenReturn:(int)option;
@end

@interface Homescreen : SKScene {
    
}
@property (nonatomic, assign) id <SceneDelegate> delegate;

@end

