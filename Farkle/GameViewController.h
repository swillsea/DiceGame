//
//  GameViewController.h
//  Farkle
//
//  Created by Sam on 3/24/16.
//  Copyright © 2016 Sam Willsea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "player.h"

@interface GameViewController : UIViewController

@property Player *playerOne;
@property Player *playerTwo;
@property Player *playerThree;
@property Player *playerFour;

@end
