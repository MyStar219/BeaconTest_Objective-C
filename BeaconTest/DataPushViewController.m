//
//  DataPushViewController.m
//  BeaconTest
//
//  Created by Jin Jin on 6/28/17.
//  Copyright © 2017 Jin Jin. All rights reserved.
//

#import "DataPushViewController.h"
#import "AIBBeaconRegionAny.h"
#import "AIBUtils.h"
#import "AFNetworking.h"
#import "BeaconScannerViewController.h"
@interface DataPushViewController () <CLLocationManagerDelegate>{
    NSTimer *timeStamptimer;
    NSTimer *timer;
}

@property (nonatomic ,strong) NSMutableArray *rssiValueArr;
@property (nonatomic ,strong) NSMutableDictionary *dataSetArr;
@property (nonatomic ,strong) NSMutableDictionary *pushDataArr;

@property(nonatomic, strong) CLLocationManager* locationManager;
-(void)updateCounter:(NSTimer *)theTimer;
-(void)countdownTimer;
@end

@implementation DataPushViewController

int seconds;
int timeStamp;
int maxTimeStamp;
int secondsLeft;
int i =0;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.commentTView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    AIBBeaconRegionAny *beaconRegionAny = [[AIBBeaconRegionAny alloc] initWithIdentifier:@"Any"];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startRangingBeaconsInRegion:beaconRegionAny];
    
    secondsLeft = 30;
    maxTimeStamp = 0;
    [self countdownTimer];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void)updateCounter:(NSTimer *)theTimer {
    if(secondsLeft > 0 ) {
        self.pushDataButton.enabled = NO;
        self.pushDataButton.backgroundColor = [UIColor grayColor];
        secondsLeft -- ;
        seconds = (secondsLeft %3600) % 60;
        self.timerLeftLbl.text = [NSString stringWithFormat:@"%02d seconds left", seconds];
    } else {
        self.pushDataButton.enabled = YES;
        self.pushDataButton.backgroundColor = [self colorWithHexString:@"1F7FFF"];
        _dataSetArr = [NSMutableDictionary new];
        _pushDataArr = [NSMutableDictionary new];
        
        _dataSetArr = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.rssiValueArr, @"rssi-values", nil];
        [_dataSetArr setObject:@"fixed" forKey:@"type"];
        [_dataSetArr setObject:self.actualDistance forKey:@"actual-distance"];
        _pushDataArr = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.dataSetArr, @"data-set", nil];
        [_pushDataArr setObject:@"1" forKey:@"version"];
        [_pushDataArr setObject:self.commentTView.text forKey:@"comments"];
        [_pushDataArr setObject:self.beaconCharactArr forKey:@"beacon-characteristic"];
        [_pushDataArr setObject:self.scannerCharactArr forKey:@"scanner-characteristic"];
    }
}
- (void)timeStamp:(NSTimer *)theTimer {
    if(maxTimeStamp < 300 ) {
        maxTimeStamp ++ ;
        timeStamp = maxTimeStamp;
        [_rssiValueArr addObject:@{@"rssi" : self.rssiValue , @"distance" : self.distance ,@"timestamp" : @(timeStamp)}];
    }
}
-(void)countdownTimer {
    secondsLeft = seconds = 30;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}
-(void)timeStampTimer {
    _rssiValueArr = [NSMutableArray new];
    maxTimeStamp = timeStamp = 0;
    timeStamptimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timeStamp:) userInfo:nil repeats:YES];
}
//Move View Up when Keyboard appears
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y -200, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y +200, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}
// when you touch screen, keyboard is hidden.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.commentTView resignFirstResponder];
    }
}
-(BOOL) textViewShouldReturn:(UITextField *)textView {
    
    [self.commentTView resignFirstResponder];
    return YES;
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.commentTView.text = @"";
    self.commentTView.textColor = [UIColor blackColor];
    return YES;
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
            self.rssiValue = [NSString stringWithFormat:@"%ld", beacon.rssi];
            self.distance = [NSString stringWithFormat:@"%f", beacon.accuracy];
            if (i==0) {
                [self timeStampTimer];
                i++;
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

- (IBAction)pushDataButtonClicked:(id)sender {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"Api-Key a4a2b4bc609d053c0eeef3a04b625ee5bd9f160a522f24838fb006c9a8e97db7" forHTTPHeaderField:@"X-API-Key"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    [manager PUT:@"https://api.kuvi.io/internal/data_collection/rssi" parameters:self.pushDataArr success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:@"You have sent the data successfully."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BeaconScannerViewController *vc=(BeaconScannerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BeaconScannerViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please try again later."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}
@end
