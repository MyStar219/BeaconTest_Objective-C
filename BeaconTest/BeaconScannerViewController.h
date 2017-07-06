//
//  BeaconScannerViewController.h
//  BeaconTest
//
//  Created by Jin Jin on 6/28/17.
//  Copyright © 2017 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconScannerTableViewCell.h"
#import "DataInputViewController.h"

#define MyBEACON_UUID           @"E2C56DB5-DFFB-48D2-B060-D0F5A710AF20"
#define MyBEACON2_UUID          @"FDA50693-A4E2-4FB1-AFCF-C6EB07647827"
#define Client_BEACON_ID        @"DEAD0106-CF6D-4A0F-ADF2-F4911BA9FFA6"

@import CoreLocation;

@interface BeaconScannerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *BeaconScannerTableView;
@property (weak, nonatomic) NSString *beaconName;
@property (retain, nonatomic) NSString *major;
@property (retain, nonatomic) NSString *minor;

@end
