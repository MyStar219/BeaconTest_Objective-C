//
//  DataInputViewController.h
//  BeaconTest
//
//  Created by Jin Jin on 6/28/17.
//  Copyright © 2017 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface DataInputViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate>

@property(nonatomic, retain) CLBeacon*	testbeacon;
@property (weak, nonatomic) IBOutlet UILabel *beaconNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *uuidLbl;
@property (weak, nonatomic) IBOutlet UILabel *majorLbl;
@property (weak, nonatomic) IBOutlet UILabel *minorLBl;
@property (weak, nonatomic) IBOutlet UITextField *distanceTField;
@property (weak, nonatomic) IBOutlet UITextField *powerTField;
@property (weak, nonatomic) IBOutlet UITextField *frequencyTField;
@property (weak, nonatomic) IBOutlet UILabel *rssiObversedLbl;
@property (weak, nonatomic) IBOutlet UITextField *rssiMeasuredTField1M;
@property (weak, nonatomic) IBOutlet UITextField *rssiMeasuredTField0M;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (IBAction)cancelButtonClicked:(id)sender;

- (IBAction)startTestButtonClicked:(id)sender;

@end
