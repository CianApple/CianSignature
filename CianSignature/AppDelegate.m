//
//  AppDelegate.m
//  CianSignature
//
//  Created by Jai Dhorajia on 27/11/13.
//  Copyright (c) 2013 Softweb. All rights reserved.
//

#import "AppDelegate.h"
#import "CianSignatureView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    UIViewController *vc = [[UIViewController alloc] init];
    self.window.rootViewController = vc;
    vc.view = [[CianSignatureView alloc] initWithFrame:self.window.bounds];
    vc.view.frame = self.window.bounds;
    vc.view.backgroundColor = [UIColor whiteColor];
    
    // Labels added to view for Information
    UILabel *labelHeading = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vc.view.frame.size.width, 20)];
    labelHeading.text = @"Developed by : Cian  (Long press to clear.)";
    [labelHeading setFont:[UIFont systemFontOfSize:16.0f]];
    [labelHeading setTextAlignment:NSTextAlignmentCenter];
    [labelHeading setTextColor:[UIColor redColor]];
    [vc.view addSubview:labelHeading];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
