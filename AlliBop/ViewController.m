//
//  ViewController.m
//  AlliBop
//
//  Created by M on 4/22/2014.
//  Copyright (c) 2014 Cutchbawx. All rights reserved.
//

#import "ViewController.h"
#import "AlliScene.h"

@implementation ViewController
Homescreen * homescreen;
SKScene * game;
SKView * skAView;

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skAView = skView;
        //scene.size = skView.bounds.size;
        skView.showsFPS = YES;
        skView.showsNodeCount = NO;
        
        homescreen = [Homescreen sceneWithSize:skView.bounds.size];
        homescreen.scaleMode = SKSceneScaleModeAspectFill;
        homescreen.delegate = self;
        [skView presentScene:homescreen];
    }
}
-(void)homescreenReturn:(int)option
{
    if(option == 0) { // Start Game
        game = [AlliScene sceneWithSize:self.view.bounds.size];
        game.scaleMode = SKSceneScaleModeAspectFill;
        // Present the scene.
        [skAView presentScene:game];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:game selector:@selector(timerFired:) userInfo:nil repeats:YES];
    }
}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
//}
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:game selector:@selector(timerFired:) userInfo:nil repeats:YES];
}
@end
