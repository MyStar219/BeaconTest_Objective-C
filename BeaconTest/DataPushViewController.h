//
//  DataPushViewController.h
//  BeaconTest
//
//  Created by Jin Jin on 6/28/17.
//  Copyright © 2017 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface DataPushViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *rssiObversedLbl;
@property (weak, nonatomic) IBOutlet UILabel *timerLeftLbl;
@property (weak, nonatomic) IBOutlet UITextView *commentTView;

@property(nonatomic, retain) CLBeacon*	testbeacon;
@property (nonatomic, strong) NSString *rssiValue;
@property (nonatomic, strong) NSString *distance;

@property (nonatomic ,strong) NSMutableDictionary *beaconCharactArr;
@property (nonatomic ,strong) NSDictionary *measuredRSSIArr;
@property (nonatomic ,strong) NSDictionary *scannerCharactArr;
@property (nonatomic, strong) NSString *actualDistance;
@property (weak, nonatomic) IBOutlet UIButton *pushDataButton;

- (IBAction)pushDataButtonClicked:(id)sender;

@end
