//
//  DataInputViewController.m
//  BeaconTest
//
//  Created by Jin Jin on 6/28/17.
//  Copyright © 2017 Jin Jin. All rights reserved.
//

#import "DataInputViewController.h"
#import "DataPushViewController.h"
#import "AIBBeaconRegionAny.h"
#import "AIBUtils.h"

@interface DataInputViewController () <CLLocationManagerDelegate>
@property (nonatomic ,strong) NSMutableDictionary *beaconCharactArr;
@property (nonatomic ,strong) NSDictionary *measuredRSSIArr;
@property (nonatomic ,strong) NSDictionary *scannerCharactArr;
@property (nonatomic, strong) NSString *actualDistance;
@property(nonatomic, strong) CLLocationManager* locationManager;
@end
@implementation DataInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.distanceTField.delegate=self;
    self.powerTField.delegate=self;
    self.frequencyTField.delegate=self;
    self.rssiMeasuredTField1M.delegate = self;
    self.rssiMeasuredTField0M.delegate = self;
    self.uuidLbl.text = [_testbeacon.proximityUUID UUIDString];
    self.majorLbl.text = [_testbeacon.major stringValue];
    self.minorLBl.text = [_testbeacon.minor stringValue];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    AIBBeaconRegionAny *beaconRegionAny = [[AIBBeaconRegionAny alloc] initWithIdentifier:@"Any"];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startRangingBeaconsInRegion:beaconRegionAny];
    _measuredRSSIArr = [NSDictionary new];
    _beaconCharactArr = [NSMutableDictionary new];
    _scannerCharactArr = [NSDictionary new];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"locationManagerDidChangeAuthorizationStatus: %d", status);
    
    [UIAlertController alertControllerWithTitle:@"Authoritzation Status changed"
                                        message:[[NSString alloc] initWithFormat:@"Location Manager did change authorization status to: %d", status]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"locationManager:%@ didRangeBeacons:%@ inRegion:%@",manager, beacons, region);
    
    for (CLBeacon* beacon in beacons) {
        if ([[beacon.proximityUUID UUIDString] isEqualToString: [_testbeacon.proximityUUID UUIDString]]) {
            self.rssiObversedLbl.text = [NSString stringWithFormat:@"%ld", beacon.rssi];
            if ([self.frequencyTField.text length] !=0 && [self.distanceTField.text length] !=0 && [self.rssiMeasuredTField1M.text length] !=0) {
                self.startButton.enabled = YES;
                self.startButton.backgroundColor = [self colorWithHexString:@"1F7FFF"];
            } else {
                self.startButton.enabled = NO;
                self.startButton.backgroundColor = [UIColor grayColor];
            }
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"locationManager:%@ rangingBeaconsDidFailForRegion:%@ withError:%@", manager, region, error);
    
    [UIAlertController alertControllerWithTitle:@"Ranging Beacons fail"
                                        message:[[NSString alloc] initWithFormat:@"Ranging beacons fail with error: %@", error]
                                 preferredStyle:UIAlertControllerStyleAlert];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y -100, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y +100, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}
// when you touch screen, keyboard is hidden.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.distanceTField resignFirstResponder];
        [self.powerTField resignFirstResponder];
        [self.frequencyTField resignFirstResponder];
        [self.rssiMeasuredTField1M resignFirstResponder];
        [self.rssiMeasuredTField0M resignFirstResponder];
    }
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startTestButtonClicked:(id)sender {
    if ([self.powerTField.text intValue] < 0 && [self.rssiMeasuredTField0M.text intValue]< 0 && [self.rssiMeasuredTField1M.text intValue]< 0) {
        _measuredRSSIArr = [NSDictionary dictionaryWithObjectsAndKeys:self.rssiMeasuredTField1M.text, @"rssi", @"1", @"distance", nil];
        _beaconCharactArr = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.measuredRSSIArr, @"measured-rssi", nil];
        [_beaconCharactArr setObject:@"iBeacon" forKey:@"type"];
        NSString *beaconID = [self.uuidLbl.text stringByAppendingString:@"|"];
        beaconID = [beaconID stringByAppendingString:self.majorLbl.text];
        beaconID = [beaconID stringByAppendingString:@"|"];
        beaconID = [beaconID stringByAppendingString:self.minorLBl.text];
        [_beaconCharactArr setObject:beaconID forKey:@"beaconID"];
        [_beaconCharactArr setObject:self.powerTField.text forKey:@"tx-power"];
        [_beaconCharactArr setObject:self.frequencyTField.text forKey:@"beacon-frequency"];
        _scannerCharactArr = [NSDictionary dictionaryWithObjectsAndKeys:@"iPhone", @"type", nil];
        _actualDistance = self.distanceTField.text;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DataPushViewController *vc = (DataPushViewController *) [storyboard instantiateViewControllerWithIdentifier:@"DataPushViewController"];
        vc.testbeacon=self.testbeacon;
        vc.beaconCharactArr = self.beaconCharactArr;
        vc.scannerCharactArr = self.scannerCharactArr;
        vc.actualDistance = self.actualDistance;
        [self.navigationController pushViewController:vc animated:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter only the negative numbers in PX Power and RSSI Measured."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}
-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
@end
