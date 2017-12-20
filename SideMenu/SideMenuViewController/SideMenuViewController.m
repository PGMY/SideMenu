//
//  SideMenuViewController.m
//  SideMenu
//
//  Created by PGMY on 2017/11/07.
//  Copyright © 2017年 PGMY. All rights reserved.
//

#import "SideMenuViewController.h"
#import "SideMenuTableViewCell.h"

#pragma mark - SideMenuItem

NSString *const OpenSideMenuNotification        = @"OpenSideMenuNotification";

/**
 サイドメニューに表示させるアイテムモデルオブジェクト
 */
@interface SideMenuItem ()
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, assign) Class aClass;             // UIViewControllerをベースとした、メニュー選択時に生成されるクラス
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) NSString *title;          // 表示名
@end

@implementation SideMenuItem
+ (instancetype)createSideMenuItemWithTitle:(NSString*)title imageName:(NSString*)imageName viewController:(Class)class {
    return [SideMenuItem createSideMenuItemWithTitle:title iconImage:[UIImage imageNamed:imageName] viewController:class];
}

+ (instancetype)createSideMenuItemWithTitle:(NSString*)title iconImage:(UIImage*)image viewController:(Class)class {
    SideMenuItem *item = [SideMenuItem new];
    if ( item ) {
        item.title = title;
        item.iconImage = image;
        item.aClass = class;
    }
    return item;
}
@end


#pragma mark - SideMenuViewController Private Category
@interface SideMenuViewController () <UITableViewDataSource, UITableViewDelegate>
// - Properties ------------------------------------------------------------------
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) CGFloat menuWidth;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGFloat gestureStartX;
@property (nonatomic, assign) BOOL enablePanOfLocationX;

// - UI --------------------------------------------------------------------------
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *vcContainerView;
@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UIButton *closeButton;

@end

#pragma mark - SideMenuViewController
@implementation SideMenuViewController

#pragma mark - Initialize
- (instancetype)initWithMenuItems:(NSMutableArray*)menuItems {
    self = [super initWithNibName:nil bundle:nil];
    if ( self ) {
        self.sideMenuItems = menuItems;
    }
    return self;
}


#pragma mark - Properties
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    if ( self.contentView ) {
        self.contentView.backgroundColor = _backgroundColor;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // プロパティ設定
    self.isOpen = NO;
    self.panEnabled = YES;
    self.menuWidth = self.view.frame.size.width * 0.872;
    
    if ( !self.backgroundColor ) self.backgroundColor = [UIColor whiteColor];
    
    // 全体のコンテンツ
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(-self.menuWidth, self.view.frame.origin.y, self.view.frame.size.width+self.menuWidth, self.view.frame.size.height)];
    self.contentView.backgroundColor = self.backgroundColor;
    [self.view addSubview:self.contentView];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentPanHandler:)];
    [self.contentView addGestureRecognizer:self.panGestureRecognizer];
    
    // サイドメニュー
    CGRect menuFrame = CGRectMake(0, 0, self.menuWidth, self.view.frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:menuFrame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.menuItemTableView registerClass:UITableViewHeaderFooterView.self forHeaderFooterViewReuseIdentifier:@"UITableViewHeaderFooterView"];
    [self.tableView registerClass:SideMenuTableViewCell.self forCellReuseIdentifier:@"SideMenuTableViewCell"];
    [self.contentView addSubview:self.tableView];
    
    // メインとなるコンテンツ
    self.vcContainerView = [[UIView alloc] initWithFrame:CGRectMake(self.menuWidth, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.vcContainerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.vcContainerView];
    
    // メニュー画面外の閉じるボタン
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.menuWidth, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.closeButton.backgroundColor = [UIColor blackColor];
    self.closeButton.alpha = 0;
    [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.closeButton];
    [self.closeButton setHidden:YES];
    
    // 初期メニュー
    if ( [self.sideMenuItems count] > 0 ) [self setContainerItemWithIndex:0];
    
    // 通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(openMenuNotification:) name:OpenSideMenuNotification object:nil];
    [center addObserver:self selector:@selector(orientationChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)openMenuNotification:(NSNotification*)notification {
    if ([notification.name isEqualToString:OpenSideMenuNotification]) {
        [self open];
    }
}
- (void)orientationChangeNotification:(NSNotification*)notification {
    if ([notification.name isEqualToString:UIDeviceOrientationDidChangeNotification]) {
        self.contentView.frame = CGRectMake(-self.menuWidth, self.view.frame.origin.y, self.view.frame.size.width+self.menuWidth, self.view.frame.size.height);
        self.vcContainerView.frame = CGRectMake(self.menuWidth, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        self.closeButton.frame = CGRectMake(self.menuWidth, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }
}



#pragma mark - View Controller Container
- (void)setContainerItemWithIndex:(NSInteger)index {
    self.contentViewController = nil;
    self.contentViewController = [self.sideMenuItems[index].aClass new];
    
    // remove old view controller
    if ( [self.childViewControllers count] > 0 ) {
        UIViewController *beforeVC = self.childViewControllers[0];
        [beforeVC willMoveToParentViewController:nil];
        [beforeVC.view removeFromSuperview];
        [beforeVC removeFromParentViewController];
    }
    
    if ( self.contentViewController ){
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.contentViewController];
        [self addChildViewController:nav];
        [self.vcContainerView addSubview:nav.view];
        [nav didMoveToParentViewController:self];
    }
    [self close];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sideMenuItems count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuTableViewCell"forIndexPath:indexPath];
    cell.textLabel.text = self.sideMenuItems[indexPath.row].title;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.imageView.image = self.sideMenuItems[indexPath.row].iconImage;
    [cell layoutIfNeeded];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setContainerItemWithIndex:indexPath.row];
}


#pragma mark - Menu open/close Gesture
- (void)closeButtonTapped:(UIButton*)sender {
    [self close];
}

- (void)contentPanHandler:(UIPanGestureRecognizer*)sender {
    if ( !self.panEnabled ) return;
    if ( [self.contentViewController.navigationController.viewControllers lastObject] != self.contentViewController ) return;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            CGFloat locationX = [sender locationInView:self.view].x;
            if ( self.isOpen || locationX < 50 ) {
                self.enablePanOfLocationX = YES;
            } else {
                self.enablePanOfLocationX = NO;
                break;
            }
            self.gestureStartX = self.contentView.frame.origin.x;
            [self.closeButton setHidden:NO];
            [self.closeButton setEnabled:NO];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if ( !self.enablePanOfLocationX ) break;
            CGFloat const delay = 5.0;
            CGFloat distanceX = [sender translationInView:self.view].x;
            if ( fabs(distanceX) < delay ) break;
            distanceX = distanceX<0 ? distanceX+delay : distanceX-delay;
            CGFloat sx = self.gestureStartX+distanceX;
            if ( sx > 0 ) sx = 0;
            else if ( sx < -self.menuWidth ) sx = -self.menuWidth;
            self.contentView.frame = CGRectMake(sx,self.view.frame.origin.y, self.view.frame.size.width+self.menuWidth, self.view.frame.size.height);
            self.closeButton.alpha = ( 1.0 - (fabs(sx) / self.menuWidth ) ) * 0.4;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if ( !self.enablePanOfLocationX ) break;
            [self.closeButton setEnabled:YES];
            if ( self.isOpen ) {
                if ( self.contentView.frame.origin.x < -self.menuWidth/5.0 ) [self close];
                else [self open];
            } else {
                if ( self.contentView.frame.origin.x < -self.menuWidth+self.menuWidth/5.0 ) [self close];
                else [self open];
            }
            break;
        default:
            break;
    }
}

- (void)open {
    self.panGestureRecognizer.enabled = NO;
    [self.closeButton setHidden:NO];
    [UIView animateWithDuration:0.17 animations:^(){
        self.contentView.frame = CGRectMake(0,self.view.frame.origin.y, self.view.frame.size.width+self.menuWidth, self.view.frame.size.height);
        self.closeButton.alpha = 0.4;
    } completion:^(BOOL finished){
        self.isOpen = YES;
        self.panGestureRecognizer.enabled = YES;
    }];
}

- (void)close {
    self.panGestureRecognizer.enabled = NO;
    [UIView animateWithDuration:0.17 animations:^(){
        self.contentView.frame = CGRectMake(-self.menuWidth,self.view.frame.origin.y, self.view.frame.size.width+self.menuWidth, self.view.frame.size.height);
        self.closeButton.alpha = 0;
    } completion:^(BOOL finished) {
        self.isOpen = NO;
        self.panGestureRecognizer.enabled = YES;
        [self.closeButton setHidden:YES];
    }];
}

@end

#pragma mark - UIViewController SideMenu Category
@implementation UIViewController (SideMenu)

- (void)setupNavigationSideMenuButton {
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [menuButton setImage:[UIImage imageNamed:@"NavMenu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(tapMenuButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    [self.navigationItem setLeftBarButtonItem:menuButtonItem];
}

- (void)setupNavigationSideMenuWithButton:(UIButton*)button {
    [button addTarget:self action:@selector(tapMenuButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:menuButtonItem];
}

- (void)tapMenuButton:(UIButton*)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:OpenSideMenuNotification object:self userInfo:nil];
}
@end
