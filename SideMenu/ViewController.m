//
//  ViewController.m
//  SideMenu
//
//  Created by PGMY on 2017/12/20.
//  Copyright © 2017年 PGMY. All rights reserved.
//

#import "ViewController.h"
#import "SideMenuViewController.h"

@interface ViewController ()
@property (nonatomic, strong) SideMenuViewController *sideMenuViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray<SideMenuItem*> *itemArray = [NSMutableArray array];
    SideMenuItem *item = [SideMenuItem createSideMenuItemWithTitle:@"AAAA" iconImage:nil viewController:UIViewController.self];
    [itemArray addObject:item];
    
    self.sideMenuViewController = [[SideMenuViewController alloc] initWithMenuItems:itemArray];
    [self addChildViewController:self.sideMenuViewController];
    [self.view addSubview:self.sideMenuViewController.view];
    [self.sideMenuViewController didMoveToParentViewController:self];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
