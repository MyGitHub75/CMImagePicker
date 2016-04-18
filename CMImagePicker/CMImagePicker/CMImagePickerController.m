//
//  CMImagePickerController.m
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#import "CMImagePickerController.h"
#import "CMAlbumsTableViewController.h"
#import "CMImageGridViewController.h"
#import "CMPreviewViewController.h"

/// 默认选择图像大小
#define CMImagePickerDefaultSize    CGSizeMake(600, 600)
NSString *const CMImagePickerBundleName = @"CMImagePicker.bundle";
NSString *const CMImagePickerDidSelectedNotification = @"CMImagePickerDidSelectedNotification";

@interface CMImagePickerController (){
    /**
     *  相册列表控制器
     */
    CMAlbumsTableViewController *_rootViewController;
    
    /**
     *  选中素材数组
     */
    NSMutableArray<PHAsset *>*_selectedAssets;
}

@end

@implementation CMImagePickerController

-(instancetype)initWithSelectAssets:(NSMutableArray <PHAsset *>*)selectAssets{
    self = [super init];
    if (self) {

        if (selectAssets == nil) {
            _selectedAssets = [NSMutableArray array];
        }else{
            _selectedAssets = [NSMutableArray arrayWithArray:selectAssets];
        }
        
        /**
         *  设置默认值
         */
        self.maxPickerCount = 9;
        
        _rootViewController = [[CMAlbumsTableViewController alloc]initWithSelectAssets:_selectedAssets];
        [self pushViewController:_rootViewController animated:YES];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishedSelectAssets:) name:CMImagePickerDidSelectedNotification object:nil];
        
        //设置导航栏属性
        [self setupNavAttr];
    }
    return self;
}


#pragma mark - 监听方法
- (void)didFinishedSelectAssets:(NSNotification *)notification {
    if ([self.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingWithSelectedImages:selectedAssets:)] && _selectedAssets!= nil) {
        
        [self requestImages:_selectedAssets completed:^(NSArray<UIImage *> *images) {
            [self.pickerDelegate imagePickerController:self didFinishPickingWithSelectedImages:images selectedAssets:_selectedAssets.copy];
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CMImagePickerDidSelectedNotification object:nil];
}

#pragma mark - getter & setter 方法
- (CGSize)targetSize {
    if (CGSizeEqualToSize(_targetSize, CGSizeZero)) {
        _targetSize = CMImagePickerDefaultSize;
    }
    return _targetSize;
}

/**
 *  重写set设置最大选中图片数
 *
 *  @param maxPickerCount maxPickerCount
 */
-(void)setMaxPickerCount:(NSInteger)maxPickerCount{
    _rootViewController.maxPickerCount = maxPickerCount;
}

#pragma mark - UINavigationController 父类方法
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{

    self.toolbarHidden = [viewController isKindOfClass:[CMAlbumsTableViewController class]];
    self.hidesBarsOnTap = [viewController isKindOfClass:[CMPreviewViewController class]];
    
    [super pushViewController:viewController animated:animated];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    
    self.toolbarHidden = (self.viewControllers.count == 1);
    self.hidesBarsOnTap = NO;
    
    return viewController;
}

#pragma mark - 请求图像方法

/// 根据 PHAsset 数组，统一查询用户选中图像
///
/// @param selectedAssets 用户选中 PHAsset 数组
/// @param completed      完成回调，缩放后的图像数组在回调参数中
- (void)requestImages:(NSArray <PHAsset *> *)selectedAssets completed:(void (^)(NSArray <UIImage *> *images))completed {
    
    /// 图像请求选项
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 设置 resizeMode 可以按照指定大小缩放图像
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 设置 deliveryMode 为 HighQualityFormat 可以只回调一次缩放之后的图像，否则会调用多次
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // 设置加载图像尺寸(以像素为单位)
    CGSize targetSize = self.targetSize;
    
    NSMutableArray <UIImage *> *images = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    
    for (PHAsset *asset in selectedAssets) {
        
        dispatch_group_enter(group);
        
        [[PHImageManager defaultManager]
         requestImageForAsset:asset
         targetSize:targetSize
         contentMode:PHImageContentModeAspectFill
         options:options
         resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
             
             [images addObject:result];
             dispatch_group_leave(group);
         }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completed(images.copy);
    });
}

#pragma mark - 设置导航栏属性

-(void)setupNavAttr{
    //        [self.toolbar setBarTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.1]];
    self.navigationBar.barTintColor =[UIColor colorWithRed:242/255.0 green:68/255.0 blue:90/255.0 alpha:1];
    self.navigationBar.tintColor=[UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
