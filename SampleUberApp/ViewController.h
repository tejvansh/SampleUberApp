//
//  ViewController.h
//  SampleUberApp
//
//  Created by Tejvansh Singh Chhabra on 6/11/16.
//  Copyright © 2016 Tejvansh Singh Chhabra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UberKit.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate, UberKitDelegate>
{
    NSArray *uberPrices;
    IBOutlet UITableView *tableview;
    IBOutlet UITextField *txtAddress;
}

@property (nonatomic, strong) UberKit *myUberKit;
@property (nonatomic, strong) CLLocation *currLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

