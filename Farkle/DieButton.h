//
//  DieButton.h
//  Farkle
//
//  Created by Sam on 3/26/16.
//  Copyright © 2016 Sam Willsea. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol DieDelegate <NSObject>
//
//-(void)rollDie;
//
//@end

@interface DieButton : UIButton
@property BOOL isSelected;
@property int currentDieFace;
//@property (nonatomic, assign) id <DieDelegate> delegate;
@end