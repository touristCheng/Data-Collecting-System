//
//  ViewController.m
//  数据采集系统
//
//  Created by chengshuo on 15/7/15.
//  Copyright (c) 2015年 chengshuo. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NextViewController.h"
#import <WebKit/WebKit.h>
#import <CFNetwork/CFNetwork.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AMTumblrHud.h"

#define delay 2

static NSString *urlstring = @"http://test.starduster.me/API.php";

@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate,UIAlertViewDelegate> {
    CLLocationManager *locationManager;
    CLLocation *selfLocation;
    NextViewController *nextview;
    BOOL isWorking;
    AMTumblrHud *tumblrHUD;
    UIView *BackView,*Sublayer;
    UILabel *ShowCondition;
    NSUserDefaults *user;
}


@property (weak, nonatomic) IBOutlet UILabel *la;
@property (weak, nonatomic) IBOutlet UILabel *lo;
@property (weak, nonatomic) IBOutlet UILabel *al;
@property (weak, nonatomic) IBOutlet UILabel *speed;

@property (weak, nonatomic) IBOutlet UIButton *StartOrStop;
@property (weak, nonatomic) IBOutlet UIButton *ShowMap;
@property (weak, nonatomic) IBOutlet UIButton *PostData;
@property (weak, nonatomic) IBOutlet UIButton *ClearInfo;


@end

@implementation ViewController

- (void) InitView {
    UIAlertView *alert = [[UIAlertView alloc]init];
    alert.message = @"开启定位服务会消耗较多的电量!";
    alert.delegate = self;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    
    [_StartOrStop setTitle:@"停止定位" forState:UIControlStateNormal];
    isWorking = YES;
    
    _la.layer.borderWidth = 1;
    _la.layer.cornerRadius = 5;
    _la.layer.masksToBounds = YES;
    
    
    _lo.layer.borderWidth = 1;
    _lo.layer.cornerRadius = 5;
    _lo.layer.masksToBounds = YES;
    
    _al.layer.borderWidth = 1;
    _al.layer.cornerRadius = 5;
    _al.layer.masksToBounds = YES;
    
    _speed.layer.borderWidth = 1;
    _speed.layer.cornerRadius = 5;
    _speed.layer.masksToBounds = YES;
    
    _StartOrStop.layer.borderWidth = 1;
    _StartOrStop.layer.cornerRadius = 5;
    _StartOrStop.layer.masksToBounds = YES;
    
    
    _ShowMap.layer.borderWidth = 1;
    _ShowMap.layer.cornerRadius = 5;
    _ShowMap.layer.masksToBounds = YES;
    
    _PostData.layer.borderWidth = 1;
    _PostData.layer.cornerRadius = 5;
    _PostData.layer.masksToBounds = YES;
    
    _ClearInfo.layer.borderWidth = 1;
    _ClearInfo.layer.cornerRadius = 5;
    _ClearInfo.layer.masksToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self InitView];
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 10.0f;
    
    if ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways) {
        if ([UIDevice currentDevice].systemVersion.floatValue>=8) {
            [locationManager requestAlwaysAuthorization];
        }
    }
    else locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    nextview = [[NextViewController alloc] init];
    selfLocation = [[CLLocation alloc]init];
    
    user = [NSUserDefaults standardUserDefaults];
    
    if ([user objectForKey:@"uuid"] == nil) {
        [self GetUUID];
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status==kCLAuthorizationStatusAuthorizedAlways) {
        manager.delegate=self;
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    selfLocation = [locations firstObject];
    NSLog(@"%f %f",selfLocation.coordinate.latitude,selfLocation.coordinate.longitude);
    _la.text = [NSString stringWithFormat:@" 纬度：%f",selfLocation.coordinate.latitude];
    _lo.text = [NSString stringWithFormat:@" 经度：%f",selfLocation.coordinate.longitude];
    _al.text = [NSString stringWithFormat:@" 海拔：%f",selfLocation.altitude];
    _speed.text = [NSString stringWithFormat:@" 速度：%f",selfLocation.speed];
    
}

- (IBAction)startorstop:(id)sender {
    if (isWorking) {
        isWorking = NO;
        [_StartOrStop setTitle:@"开始定位" forState:UIControlStateNormal];
        [locationManager stopUpdatingLocation];
    }
    else {
        isWorking = YES;
        [_StartOrStop setTitle:@"停止定位" forState:UIControlStateNormal];
        [locationManager startUpdatingLocation];
    }
}

- (IBAction)ShowMap:(id)sender {
    [locationManager stopUpdatingLocation];
    isWorking = NO;
    [_StartOrStop setTitle:@"开始定位" forState:UIControlStateNormal];
    [self presentModalViewController:nextview animated:YES];
}

#pragma mark network

- (void) ShowSubLayer {
    if (BackView == nil) {
        BackView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    BackView.backgroundColor = [UIColor blackColor];
    BackView.alpha = 0.65;
    [self.view addSubview:BackView];
    
    if (Sublayer == nil) {
        Sublayer = [[UIView alloc]initWithFrame:CGRectMake(72, 222, 176, 138)];
    }
    Sublayer.backgroundColor = [UIColor whiteColor];
    Sublayer.alpha = 1;
    Sublayer.layer.cornerRadius = 8;
    Sublayer.layer.masksToBounds = YES;
    [self.view addSubview:Sublayer];
    
    if (tumblrHUD == nil) {
        tumblrHUD = [[AMTumblrHud alloc] initWithFrame:CGRectMake((CGFloat) ((self.view.frame.size.width - 55) * 0.5),
                                                                  (CGFloat) ((self.view.frame.size.height - 20) * 0.5+20), 55, 20)];
    }
    tumblrHUD.hudColor = [UIColor colorWithRed:0xf1/255 green:0xf2/255 blue:0xf3/255 alpha:1];
    [self.view addSubview:tumblrHUD];
    [tumblrHUD showAnimated:YES];
    
    
    if (ShowCondition == nil) {
        ShowCondition = [[UILabel alloc]initWithFrame:CGRectMake(11, 22, 155, 33)];
    }
    ShowCondition.textAlignment = YES;
    ShowCondition.text = @"数据上传中...";
    ShowCondition.font = [UIFont systemFontOfSize:20];
    ShowCondition.textColor = [UIColor blackColor];
    [Sublayer addSubview:ShowCondition];
}

- (void) HiddenSubLayer {
    [Sublayer removeFromSuperview];
    [BackView removeFromSuperview];
    [tumblrHUD removeFromSuperview];
}

- (void) PostSuccessful {
    [self HiddenSubLayer];
    UIAlertView *alert = [[UIAlertView alloc]init];
    alert.message = @"数据已成功上传到服务器!";
    alert.delegate = self;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

- (void) PostFailWithError:(NSString *)err {
    [self HiddenSubLayer];
    UIAlertView *alert = [[UIAlertView alloc]init];
    alert.message = [NSString stringWithFormat:@"上传失败:\n%@\n请稍候重试!",err];
    alert.delegate = self;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

- (NSData *)GetPostData:(NSDictionary *)Dic {
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:Dic options:0 error:nil];
    return postdata;
}

- (void)GetUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef guid = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *uuidString = (__bridge NSString *)guid;
    uuidString = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(guid);
    NSLog(@"UUID:%@",uuidString);
    [user setObject:uuidString forKey:@"uuid"];
    [user synchronize];
}

- (void) PostHelper {
    NSURL *sendurl = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:sendurl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    [request setHTTPMethod:@"POST"];
    NSDate *temptim = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tim = [temptim timeIntervalSince1970];
    NSString *PreParameter = @"Operation=UploadData&AdminUsername=Cheng&AdminAuth=Test&Data=";
    NSMutableData *SendData = (NSMutableData *)[PreParameter dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *postdic = @{
                              @"DataType":@"GPS",
                              @"UID":[NSString stringWithFormat:@"%i",[[user objectForKey:@"UID"]intValue]],
                              @"DeviceID":[NSString stringWithFormat:@"%i",[[user objectForKey:@"DeviceID"]intValue]],
                              @"TimeStamp":[NSString stringWithFormat:@"%lld",(long long)tim],
                              @"Latitude":[NSString stringWithFormat:@"%f",selfLocation.coordinate.latitude],
                              @"Longitude":[NSString stringWithFormat:@"%f",selfLocation.coordinate.longitude],
                              @"Altitude":[NSString stringWithFormat:@"%f",selfLocation.altitude],
                              @"Speed":[NSString stringWithFormat:@"%f",selfLocation.speed]
                              };
    [SendData appendData:[self GetPostData:postdic]];
    [request setHTTPBody:SendData];
    
    NSURLResponse *tempResponse;
    NSError *tempError;
    NSData *tempData = [NSURLConnection sendSynchronousRequest:request returningResponse:&tempResponse error:&tempError];
    
    if (tempError) {
        [self performSelectorOnMainThread:@selector(PostFailWithError:) withObject:tempError.localizedDescription waitUntilDone:NO];
    }
    else {
        NSHTTPURLResponse *recResponse = (NSHTTPURLResponse*)tempResponse;
        if (recResponse.statusCode != 200) {
            [self performSelectorOnMainThread:@selector(PostFailWithError:) withObject:[NSString stringWithFormat:@"错误代码:%li",recResponse.statusCode] waitUntilDone:NO];
        }
        else {
            [self performSelectorOnMainThread:@selector(PostSuccessful) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void) DoUserInit {
    NSURL *sendurl = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:sendurl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    [request setHTTPMethod:@"POST"];
    
    NSDate *temptim = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tim = [temptim timeIntervalSince1970];
    
    NSString *PreParameter = @"Operation=UserInit&AdminUsername=Cheng&AdminAuth=Cat123&Data=";
    NSMutableData *SendData = (NSMutableData *)[PreParameter dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *postdic = @{
                              @"DataType":@"UserInit",
                              @"Username":@"Starduster",
                              @"Password":@"Test",
                              @"RegTime":[NSString stringWithFormat:@"%lld",(long long)tim],
                              @"Email":@"aria@starduster.me"
                              };
    [SendData appendData:[self GetPostData:postdic]];
    [request setHTTPBody:SendData];
    NSURLResponse *tempResponse;
    NSError *tempError;
    NSData *tempData = [NSURLConnection sendSynchronousRequest:request returningResponse:&tempResponse error:&tempError];
   // NSLog(@"OP1");
    if (tempData) {
        NSDictionary *recContent = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableContainers error:nil];
        [user setObject:[NSNumber numberWithInt:[[recContent objectForKey:@"UID"]intValue]] forKey:@"UID"];
        [user synchronize];
        NSLog(@"UserInit:\n%@\n",recContent);
    }
    else {
        
    }
}

- (void) DoDeviceInit {
    NSURL *sendurl = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:sendurl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    [request setHTTPMethod:@"POST"];
    NSDate *temptim = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tim = [temptim timeIntervalSince1970];
    
    NSString *PreParameter = @"Operation=DeviceInit&AdminUsername=Cheng&AdminAuth=Cat123&Data=";
    NSMutableData *SendData = (NSMutableData *)[PreParameter dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *postdic = @{
                              @"DataType":@"DeviceInit",
                              @"UID":[user objectForKey:@"UID"],
                              @"TimeStamp":[NSString stringWithFormat:@"%lld",(long long)tim],
                              @"DeviceType":@"iPhone",
                              @"DeviceDetail":[user objectForKey:@"uuid"]
                              };
    [SendData appendData:[self GetPostData:postdic]];
    [request setHTTPBody:SendData];
    NSURLResponse *tempResponse;
    NSError *tempError;
    NSData *tempData = [NSURLConnection sendSynchronousRequest:request returningResponse:&tempResponse error:&tempError];
    if (tempData) {
        NSDictionary *recContent = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableContainers error:nil];
        [user setObject:[NSNumber numberWithInt:[[recContent objectForKey:@"DeviceID"]intValue]]forKey:@"DeviceID"];
        [user synchronize];
        NSLog(@"DeviceInit:\n%@\n",recContent);
    }
}

- (void) PostDelay {
    if ([user objectForKey:@"UID"] == nil || [user objectForKey:@"DeviceID"] == nil) {
        NSBlockOperation *opA = [NSBlockOperation blockOperationWithBlock:^{
            [self DoUserInit];
        }];
        NSBlockOperation *opB = [NSBlockOperation blockOperationWithBlock:^{
            [self DoDeviceInit];
        }];
        [opB addDependency:opA];
        NSBlockOperation *opC = [NSBlockOperation blockOperationWithBlock:^{
            [self PostHelper];
        }];
        NSLog(@"In Sub Thread\n");
        [opB addDependency:opA];
        [opC addDependency:opB];
        NSOperationQueue *tempQ = [NSOperationQueue new];
        [tempQ addOperation:opA];
        [tempQ addOperation:opB];
        [tempQ addOperation:opC];
        
    }
    else {
        NSOperationQueue *tempQ = [NSOperationQueue new];
        [tempQ addOperationWithBlock:^{
            [self PostHelper];
        }];
    }
}

- (IBAction)Post2Server:(id)sender {
    [self ShowSubLayer];
    [self performSelector:@selector(PostDelay) withObject:nil afterDelay:delay];
}

- (IBAction)ClearLoginInfo:(id)sender {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults]removePersistentDomainForName:appDomain];
    [self GetUUID];
    UIAlertView *alert = [[UIAlertView alloc]init];
    alert.message = @"注册信息已成功清除!";
    alert.delegate = self;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}


#pragma mark end

@end