//
//  BeaconScannerViewController.m
//  BeaconTest
//
//  Created by Jin Jin on 6/28/17.
//  Copyright © 2017 Jin Jin. All rights reserved.
//

#import "BeaconScannerViewController.h"
#import "AIBBeaconRegionAny.h"
#import "AIBUtils.h"

@interface BeaconScannerViewController ()
@property(nonatomic, strong) NSDictionary*		beaconsDict;
@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, strong) NSArray*			listUUID;
@property(nonatomic)		 BOOL				sortByMajorMinor;
@property(nonatomic, retain) CLBeacon*			selectedBeacon;

@end

@implementation BeaconScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.listUUID=[[NSArray alloc] init];
    self.beaconsDict=[[NSMutableDictionary alloc] init];
    self.sortByMajorMinor=NO;
    
    AIBBeaconRegionAny *beaconRegionAny = [[AIBBeaconRegionAny alloc] initWithIdentifier:@"Any"];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startRangingBeaconsInRegion:beaconRegionAny];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
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
    
    NSMutableArray* listUuid=[[NSMutableArray alloc] init];
    NSMutableDictionary* beaconsDict=[[NSMutableDictionary alloc] init];
    for (CLBeacon* beacon in beacons) {
        if ([[beacon.proximityUUID UUIDString] isEqualToString:MyBEACON_UUID] || [[beacon.proximityUUID UUIDString] isEqualToString:Client_BEACON_ID] || [[beacon.proximityUUID UUIDString] isEqualToString:MyBEACON2_UUID]) {
            NSString* uuid=[beacon.proximityUUID UUIDString];
            NSMutableArray* list=[beaconsDict objectForKey:uuid];
            if (list==nil){
                list=[[NSMutableArray alloc] init];
                [listUuid addObject:uuid];
                [beaconsDict setObject:list forKey:uuid];
            }
            [list addObject:beacon];
        }
    }
    [listUuid sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* string1=obj1;
        NSString* string2=obj2;
        return [string1 compare:string2];
    }];
    if (_sortByMajorMinor){
        for (NSString* uuid in listUuid){
            NSMutableArray* list=[beaconsDict objectForKey:uuid];
            [list sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                CLBeacon* b1=obj1;
                CLBeacon* b2=obj2;
                NSComparisonResult r=[b1.major compare:b2.major];
                if (r==NSOrderedSame){
                    r=[b1.minor compare:b2.minor];
                }
                return r;
            }];
        }
    }
    _listUUID=listUuid;
    _beaconsDict=beaconsDict;
    self.BeaconScannerTableView.delegate = self;
    self.BeaconScannerTableView.dataSource = self;
    [self.BeaconScannerTableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"locationManager:%@ rangingBeaconsDidFailForRegion:%@ withError:%@", manager, region, error);
    
    [UIAlertController alertControllerWithTitle:@"Ranging Beacons fail"
                                        message:[[NSString alloc] initWithFormat:@"Ranging beacons fail with error: %@", error]
                                 preferredStyle:UIAlertControllerStyleAlert];
}

#pragma mark - UITableViewDelegate, UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_listUUID count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString* key=[_listUUID objectAtIndex:section];
    return MAX([[_beaconsDict objectForKey:key] count], 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BeaconScannerTableViewCell *cell=(BeaconScannerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"beaconScannerCell" forIndexPath:indexPath];
    if (_beaconsDict.count == 0)
    {
        // No beacons yet - add a message indicating so
        cell.beaconName.text=[[NSString alloc] initWithFormat:@"No beacons have been found."];
        cell.beaconName.textColor = [UIColor blackColor];
        cell.beaconName.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else
    {
        NSString* key=[_listUUID objectAtIndex:[indexPath indexAtPosition:0]];
        CLBeacon* beacon=[[_beaconsDict objectForKey:key] objectAtIndex:[indexPath indexAtPosition:1]];
        self.major = [[NSString alloc] initWithFormat:@"%@", beacon.major];
        self.minor = [[NSString alloc] initWithFormat:@"%@", beacon.minor];
        NSString *beaconNameString = [[NSString alloc] initWithFormat:@"%@", beacon.proximityUUID];
        beaconNameString = [beaconNameString stringByAppendingString:@" Major :"];
        beaconNameString = [beaconNameString stringByAppendingString:self.major];
        beaconNameString = [beaconNameString stringByAppendingString:@"    Minor :"];
        beaconNameString = [beaconNameString stringByAppendingString:self.minor];
        cell.beaconName.text=beaconNameString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* key=[_listUUID objectAtIndex:[indexPath indexAtPosition:0]];
    _selectedBeacon=[[_beaconsDict objectForKey:key] objectAtIndex:[indexPath indexAtPosition:1]];
    
    DataInputViewController* detail=[self.storyboard instantiateViewControllerWithIdentifier:@"DataInputViewController"];
    detail.testbeacon=_selectedBeacon;
    [self.navigationController pushViewController:detail animated:YES];
}
@end
