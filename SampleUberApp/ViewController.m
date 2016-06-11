//
//  ViewController.m
//  SampleUberApp
//
//  Created by Tejvansh Singh Chhabra on 6/11/16.
//  Copyright © 2016 Tejvansh Singh Chhabra. All rights reserved.
//

#import "ViewController.h"

#define SERVER_TOKEN @"cOyVKSafFUQGxE8-4F_ezeDS9iI3bn3j56zek00j"

@implementation ViewController

@synthesize myUberKit;
@synthesize locationManager;
@synthesize currLocation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpAuthentication];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    currLocation = newLocation;
}

- (void)setUpAuthentication
{
    myUberKit = [[UberKit alloc] initWithServerToken:SERVER_TOKEN];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
}

- (IBAction)requestDetail:(id)sender
{
    if(currLocation) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:txtAddress.text
                     completionHandler:^(NSArray* placemarks, NSError* error) {
                         if (!error && placemarks.count > 0) {
                             CLPlacemark *aPlacemark = [placemarks objectAtIndex:0];
                             [myUberKit getPriceForTripWithStartLocation:currLocation endLocation:aPlacemark.location  withCompletionHandler:^(NSArray *prices, NSURLResponse *response, NSError *error)
                              {
                                  if(!error)
                                  {
                                      uberPrices = prices;
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [tableview reloadData];
                                      });
                                  }
                                  else
                                  {
                                      NSLog(@"Error %@", error);
                                  }
                              }];
                         }
                         else {
                             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sample Uber App" message:@"Sorry, Address could not be found. Please type again." preferredStyle:UIAlertControllerStyleAlert];
                             
                             UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                             [alertController addAction:ok];
                             
                             [self presentViewController:alertController animated:YES completion:nil];
                         }
        }];
    }
}


- (IBAction)login:(id)sender
{
//    [[UberKit sharedInstance] setClientID:@"QvGQxkBZJ_lQmEc-_okszp5z-l1LUapI"];
//    [[UberKit sharedInstance] setClientSecret:@"5Y6EYGy5b11jTm0XevA_nOWxodfyFtICr4Zs2o7E"];
//    [[UberKit sharedInstance] setRedirectURL:@""];
//    [[UberKit sharedInstance] setApplicationName:@"SampleRide"];
//    UberKit *uberKit = [UberKit sharedInstance];
//    uberKit.delegate = self;
//    [uberKit startLogin];
}

- (void) uberKit:(UberKit *)uberKit didReceiveAccessToken:(NSString *)accessToken
{
    NSLog(@"Received access token %@", accessToken);
    if(accessToken)
    {
        [uberKit getUserActivityWithCompletionHandler:^(NSArray *activities, NSURLResponse *response, NSError *error)
         {
             if(!error)
             {
                 NSLog(@"User activity %@", activities);
                 UberActivity *activity = [activities objectAtIndex:0];
                 NSLog(@"Last trip distance %f", activity.distance);
             }
             else
             {
                 NSLog(@"Error %@", error);
             }
         }];
        
        [uberKit getUserProfileWithCompletionHandler:^(UberProfile *profile, NSURLResponse *response, NSError *error)
         {
             if(!error)
             {
                 NSLog(@"User's full name %@ %@", profile.first_name, profile.last_name);
             }
             else
             {
                 NSLog(@"Error %@", error);
             }
         }];
    }
    else
    {
        NSLog(@"No auth token, try again");
    }
}

- (void) uberKit:(UberKit *)uberKit loginFailedWithError:(NSError *)error
{
    NSLog(@"Error in login %@", error);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [uberPrices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyUberIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    UberPrice *price = [uberPrices objectAtIndex:indexPath.row];
    
    UILabel *lblName     = [cell viewWithTag:101];
    UILabel *lblLowEst   = [cell viewWithTag:102];
    UILabel *lblDistance = [cell viewWithTag:103];
    UILabel *lblDuration = [cell viewWithTag:104];
    UILabel *lblHighEstmt= [cell viewWithTag:105];

    lblName.text = price.displayName;
    lblLowEst.text    = [NSString stringWithFormat:@"%d $", price.lowEstimate];
    lblHighEstmt.text = [NSString stringWithFormat:@"%d $", price.highEstimate];
    lblDuration.text  = [NSString stringWithFormat:@"%d mins %d", price.duration/60, price.duration%60];
    lblDistance.text  = [NSString stringWithFormat:@"%f miles", price.distance];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
