//
//  GameViewController.m
//  Farkle
//
//  Created by Sam on 3/24/16.
//  Copyright © 2016 Sam Willsea. All rights reserved.
//

#import "GameViewController.h"
#import "Player.h"
#import "DieButton.h"

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *playerOneScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerTwoScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerThreeScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerFourScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerTurnLabel;
@property (weak, nonatomic) IBOutlet UILabel *farkleLable;

@property (weak, nonatomic) IBOutlet DieButton *dieButton1;
@property (weak, nonatomic) IBOutlet DieButton *dieButton2;
@property (weak, nonatomic) IBOutlet DieButton *dieButton3;
@property (weak, nonatomic) IBOutlet DieButton *dieButton4;
@property (weak, nonatomic) IBOutlet DieButton *dieButton5;
@property (weak, nonatomic) IBOutlet DieButton *dieButton6;

@property NSMutableArray *playersArray;
@property NSMutableArray *diceArray;

@property int currentPlayerIndexValue;
@property int numberOfDiceSelected;
@property int temporaryScore;

@end

@implementation GameViewController

#pragma setup game

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerOne.playerScore = 0;
    self.playerTwo.playerScore = 0;
    self.playerThree.playerScore = 0;
    self.playerFour.playerScore = 0;
    self.numberOfDiceSelected = 0;
    self.temporaryScore = 0;

    [self setupPlayers];
    [self updateScoreLabels];
    
    
    //creates dice array and rolls the first random generated dice set
    self.diceArray = [[NSMutableArray alloc] initWithObjects:self.dieButton1, self.dieButton2, self.dieButton3, self.dieButton4, self.dieButton5, self.dieButton6, nil];
    [self rollDice];
    
    self.playerTurnLabel.text = [NSString stringWithFormat:@"%@'s Turn", self.playerOne.playerName];
}

- (void)setupPlayers {
    //Player One should always be enabled
    self.playerOne.isPlaying = YES;
    self.playersArray = [[NSMutableArray alloc] initWithObjects:self.playerOne, nil];
    self.currentPlayerIndexValue = 0;
    
    if (self.playerTwo.playerName.length > 0) {
        self.playerTwo.isPlaying = YES;
        [self.playersArray addObject:self.playerTwo];
    } else {
        self.playerTwo.isPlaying = NO;
    }
    if (self.playerThree.playerName.length > 0) {
        self.playerThree.isPlaying = YES;
        [self.playersArray addObject:self.playerThree];
    } else {
        self.playerThree.isPlaying = NO;
    }
    if (self.playerFour.playerName.length > 0) {
        self.playerFour.isPlaying = YES;
        [self.playersArray addObject:self.playerFour];
    } else {
        self.playerFour.isPlaying = NO;
    }
}


#pragma roll, reset, and select dice

- (IBAction)onRollButtonPressed:(UIButton *)sender {
    [self rollDice];
}


-(void)rollDice {
    self.farkleLable.hidden = YES;
    NSCountedSet *unselectedDiceSet = [NSCountedSet new];
    
    //ensures the dice reset if you select all six
    if (self.numberOfDiceSelected == 6) {
        [self calculateScores];
        [self resetDiceSelection];
    }

    //only change image and value for non-selected dice
    for (DieButton *die in self.diceArray) {
        if (die.isSelected != YES){
            int randomNumber = (arc4random_uniform (6) +1);
            [die setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i", randomNumber]] forState:UIControlStateNormal];
            die.currentDieFace = randomNumber;
            
            //here we need to put these values into an NSCountedSet to check for Farkles
            NSNumber* unselectedDieValue= [NSNumber numberWithInt:randomNumber];
            [unselectedDiceSet addObject:unselectedDieValue];
        }
    }
    
    //checks for Farkles
    if(([unselectedDiceSet countForObject:[NSNumber numberWithInt:1]] == 0) &&
       ([unselectedDiceSet countForObject:[NSNumber numberWithInt:5]] == 0) &&
       ([unselectedDiceSet countForObject:[NSNumber numberWithInt:2]] < 3)  &&
       ([unselectedDiceSet countForObject:[NSNumber numberWithInt:3]] < 3)  &&
       ([unselectedDiceSet countForObject:[NSNumber numberWithInt:4]] < 3)  &&
       ([unselectedDiceSet countForObject:[NSNumber numberWithInt:6]] < 3)  ){
        [self didFarkle];
    }
    
}

- (IBAction)onDieSelected:(DieButton *)sender {
    
    //makes sure that you can toggle back and forth - it's !=YES because dice selection will be nil the first round
    if (sender.isSelected !=YES) {
        sender.isSelected = YES;
        [sender setImage:[UIImage imageNamed:[NSString stringWithFormat:@"selected%li", ((long)sender.currentDieFace)]] forState:UIControlStateNormal];
        self.numberOfDiceSelected +=1;
    } else {
        [sender setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%li", ((long)sender.currentDieFace)]] forState:UIControlStateNormal];
        sender.isSelected = NO;
        self.numberOfDiceSelected -=1;
    }
}

-(void)resetDiceSelection {
    for (DieButton *die in self.diceArray) {
        die.isSelected = NO;
    }
    self.numberOfDiceSelected = 0;
}


#pragma didFarkle, finishRound and nextPlayer

-(void)didFarkle {
    [self resetDiceSelection];
    [self rollDice];
    
     Player *player = [self.playersArray objectAtIndex:self.currentPlayerIndexValue];
    self.farkleLable.hidden = NO;
    self.farkleLable.text = [NSString stringWithFormat:@"%@ Farkled!", player.playerName];
    
    [self goToNextPlayer];

}


- (IBAction)onFinishRoundButtonPressed:(UIButton *)sender {
    
    [self updateScoreLabels];
    [self goToNextPlayer];
    [self resetDiceSelection];
    [self rollDice];

}

-(void)goToNextPlayer {
    //ensures turns cycle through
    if (self.currentPlayerIndexValue < (self.playersArray.count-1)) {
        self.currentPlayerIndexValue ++;
    } else {
        self.currentPlayerIndexValue = 0;
    }
    self.temporaryScore = 0;
    
    //switches the turn label
    Player *player = [self.playersArray objectAtIndex:self.currentPlayerIndexValue];
    self.playerTurnLabel.text = [NSString stringWithFormat:@"%@'s Turn", player.playerName];
}

#pragma calculate scores and update score labels

-(void)calculateScores {
    NSCountedSet *selectedDiceSet = [NSCountedSet new];
    
    for (DieButton *die in self.diceArray) {
        if (die.isSelected) {
            
            NSNumber* selectedDieValue= [NSNumber numberWithInt:die.currentDieFace];
            [selectedDiceSet addObject:selectedDieValue];
            
            if (die.currentDieFace == 1) {
                self.temporaryScore += 100;
            } else if (die.currentDieFace == 5) {
                self.temporaryScore += 50;
            }
        }
    }
    
    if([selectedDiceSet countForObject:[NSNumber numberWithInt:1]] >= 3) {
        self.temporaryScore += 700; //note we already added 300, so this gets us to 1000
    }
    if([selectedDiceSet countForObject:[NSNumber numberWithInt:2]] >= 3) {
        self.temporaryScore += 200;
    }
    if([selectedDiceSet countForObject:[NSNumber numberWithInt:3]] >= 3) {
        self.temporaryScore += 300;
    }
    if([selectedDiceSet countForObject:[NSNumber numberWithInt:4]] >= 3) {
        self.temporaryScore += 400;
    }
    if([selectedDiceSet countForObject:[NSNumber numberWithInt:5]] >= 3) {
        self.temporaryScore += 500;
    }
    if([selectedDiceSet countForObject:[NSNumber numberWithInt:6]] >= 3) {
        self.temporaryScore += 600;
    }
}


-(void)updateScoreLabels {
    
    Player *player = [self.playersArray objectAtIndex:self.currentPlayerIndexValue];
    [self calculateScores];
    player.playerScore += self.temporaryScore;
    
    //updates appropriate labels
    if (self.playerOne.isPlaying){
        self.playerOneScoreLabel.text = [NSString stringWithFormat:@"%@ Score: %i", self.playerOne.playerName, self.playerOne.playerScore];
    }
    if (self.playerTwo.isPlaying) {
        self.playerTwoScoreLabel.text = [NSString stringWithFormat:@"%@ Score: %i", self.playerTwo.playerName, self.playerTwo.playerScore];
    }
    if (self.playerThree.isPlaying) {
        self.playerThreeScoreLabel.text = [NSString stringWithFormat:@"%@ Score: %i", self.playerThree.playerName, self.playerThree.playerScore];
    }
    if (self.playerFour.isPlaying) {
        self.playerFourScoreLabel.text = [NSString stringWithFormat:@"%@ Score: %i", self.playerFour.playerName, self.playerFour.playerScore];
    }
    
}













@end
