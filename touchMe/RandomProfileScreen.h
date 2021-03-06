//
//  RandomizeProfileScreen.h
//  touchMe
//
//  Created by Ali Eskandari on 1/14/13.
//  Copyright (c) 2013 Marin Todorov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "UIAlertView+error.h"

@interface RandomProfileScreen : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *proPic;
@property (strong, nonatomic) IBOutlet UIButton *touchMeBtn;
@property (strong, nonatomic) IBOutlet UIButton *dontBtn;

- (IBAction)btnTouchDontTouchTapped:(id)sender;
- (void) showRandomProfile;

@end
