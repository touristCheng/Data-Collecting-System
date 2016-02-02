//
//  NextViewController.m
//  loc
//
//  Created by chengshuo on 15/4/5.
//  Copyright (c) 2015年 chengshuo. All rights reserved.
//

#import "NextViewController.h"

@interface NextViewController () <CLLocationManagerDelegate,MKMapViewDelegate> {
}

@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (weak, nonatomic) IBOutlet UIButton *BackButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegControlButton;


@end

@implementation NextViewController


- (void) initViewController {
#pragma mark init UI
    _BackButton.layer.cornerRadius = 5;
    _BackButton.layer.masksToBounds = YES;
    
    _SegControlButton.layer.cornerRadius = 5;
    _SegControlButton.layer.masksToBounds = YES;
    
    _SegControlButton.backgroundColor = [UIColor whiteColor];
    _BackButton.layer.borderWidth = _SegControlButton.layer.borderWidth;
    _BackButton.layer.borderColor = _SegControlButton.layer.borderColor;
#pragma mark end
    
#pragma mark init manager
    
    _MapView.delegate = self;
    _MapView.showsUserLocation = YES;
    [_MapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
#pragma mark end
}


- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    _MapView.centerCoordinate = userLocation.location.coordinate;
}

- (IBAction)PopView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)ChangeMapView:(id)sender {
    UISegmentedControl *segcontrol = (UISegmentedControl*)sender;
    _MapView.mapType = segcontrol.selectedSegmentIndex;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewController];
    
    // Do any additional setup after loading the view from its nib.
}




@end
