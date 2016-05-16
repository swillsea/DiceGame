//
//  PreGameViewController.m
//  Farkle
//
//  Created by Sam on 3/24/16.
//  Copyright © 2016 Sam Willsea. All rights reserved.
//

#import "PreGameViewController.h"
#import "GameViewController.h"
#import "Player.h"

@interface PreGameViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UITextField *playerOneTextField;
@property (weak, nonatomic) IBOutlet UITextField *playerTwoTextField;
@property (weak, nonatomic) IBOutlet UITextField *playerThreeTextField;
@property (weak, nonatomic) IBOutlet UITextField *playerFourTextField;
@property Player *playerOne;
@property Player *playerTwo;
@property Player *playerThree;
@property Player *playerFour;

@end

@implementation PreGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //sets up entry fields for players
    [self.playerOneTextField becomeFirstResponder];
    self.playerTwoTextField.hidden   = YES;
    self.playerThreeTextField.hidden = YES;
    self.playerFourTextField.hidden  = YES;
    
    //creates player instances
    self.playerOne   = [Player new];
    self.playerTwo   = [Player new];
    self.playerThree = [Player new];
    self.playerFour  = [Player new];
    
    //creates play button appearance
    self.playButton.layer.cornerRadius  = 5;
    self.playButton.layer.masksToBounds = YES;
    self.playButton.hidden              = YES;
    
}

//ensures new player fields appear one by one when needed
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.playerTwoTextField.hidden) {
        self.playerTwoTextField.hidden = NO;
        self.playButton.hidden         = NO;
    } else if (self.playerThreeTextField.hidden) {
        self.playerThreeTextField.hidden = NO;
    } else if (self.playerFourTextField.hidden) {
        self.playerFourTextField.hidden = NO;
    } else {
    }
    
    //sets all the player names correctly
    self.playerOne.playerName   = self.playerOneTextField.text;
    self.playerTwo.playerName   = self.playerTwoTextField.text;
    self.playerThree.playerName = self.playerThreeTextField.text;
    self.playerFour.playerName  = self.playerFourTextField.text;
    
    return NO;
}

//passes the player names to the GameViewController
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GameViewController *gameVC = segue.destinationViewController;
    
    gameVC.playerOne   = self.playerOne;
    gameVC.playerTwo   = self.playerTwo;
    gameVC.playerThree = self.playerThree;
    gameVC.playerFour  = self.playerFour;


}



@end
