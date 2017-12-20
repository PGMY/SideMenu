//
//  SideMenuViewController.h
//  SideMenu
//
//  Created by PGMY on 2017/11/07.
//  Copyright © 2017年 PGMY. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const OpenSideMenuNotification;                  // メニューopen

@interface SideMenuItem : NSObject
+ (instancetype)createSideMenuItemWithTitle:(NSString*)title imageName:(NSString*)imageName viewController:(Class)class;
+ (instancetype)createSideMenuItemWithTitle:(NSString*)title iconImage:(UIImage*)image viewController:(Class)class;
@end

/**
 スライドで表示されるメニュー
 */
@interface SideMenuViewController : UIViewController

@property (nonatomic, assign) BOOL panEnabled;                  // Pan gesture有効化設定 default is YES
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) NSMutableArray<SideMenuItem*> *sideMenuItems;

- (instancetype)initWithMenuItems:(NSMutableArray*)menuItems;

@end

/**
 ナビゲーションにサイドメニューを開くボタンをつけるextension
 */
@interface UIViewController (SideMenu)
- (void)setupNavigationSideMenuButton;
- (void)setupNavigationSideMenuWithButton:(UIButton*)button;
@end
