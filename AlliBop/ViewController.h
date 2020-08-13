//
//  ViewController.h
//  AlliBop
//

//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "Homescreen.h"

@interface ViewController : UIViewController <SceneDelegate>{
    
}
@property(getter=isPaused, nonatomic) BOOL paused;
@property (strong, nonatomic) NSTimer *timer;
@end
