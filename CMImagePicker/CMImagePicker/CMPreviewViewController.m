//
//  CMPreviewViewController.m
//  ImagePickerTool
//
//  Created by pro on 16/4/14.
//  Copyright © 2016年 CM. All rights reserved.
//

#import "CMPreviewViewController.h"
#import "CMViewerViewController.h"
#import "CMSelButton.h"
#import "CMImagePickerGlobal.h"

@interface CMPreviewViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
@property(nonatomic, strong) UIButton *selectedButton;
@end

@implementation CMPreviewViewController{
    
    UIPageViewController *_pageController;
    
    /// 相册模型
    CMAlbum *_album;
    /// 选中素材数组
    NSMutableArray <PHAsset *>*_previewAssets;
    /// 选中素材索引记录数组
    NSMutableArray <NSNumber *> *_selectedIndexes;
    /// 最大选择图像数量
    NSInteger _maxPickerCount;
    /// 是否是预览选中照片
    BOOL _isPreviewSelAlbum;
    
    

    /// 完成按钮
    UIBarButtonItem *_doneItem;
    /// 选择计数按钮
    CMSelButton *_counterButton;
}


-(instancetype)initWithAlbum:(CMAlbum *)album selectedAssets:(NSMutableArray<PHAsset *> *)selectedAssets maxPickerCount:(NSInteger)maxPickerCount indexPath:(NSIndexPath *)indexPath{
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        _album = album;
        /**
         *  要进行深拷贝，否则会出错
         */
        _previewAssets = selectedAssets.mutableCopy;
        _maxPickerCount = maxPickerCount;
        _isPreviewSelAlbum = (indexPath == nil);
        
        // 记录选中素材索引
        _selectedIndexes = [NSMutableArray array];
        if (_isPreviewSelAlbum) {
            for (int i = 0; i < _previewAssets.count; i++) {
                [_selectedIndexes addObject:@(YES)];
            }
        }else {
            for (int i = 0; i < _album.photoCount; i++) {
                if ([_previewAssets containsObject:[_album assetWithIndex:i]]) {
                    [_selectedIndexes addObject:@(YES)];
                }else{
                    [_selectedIndexes addObject:@(NO)];
                }
            }
        }
        
        //准备子控制器
        NSInteger index = (indexPath == nil) ? 0 : indexPath.item;
        [self prepareChildViewControllerWithIndex:index];
        
    }
    return self;
}

#pragma mark - 准备子控制器(UIPageViewController)
-(void)prepareChildViewControllerWithIndex:(NSInteger)index{
    
//    NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMax]forKey: UIPageViewControllerOptionInterPageSpacingKey];
    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey: @(30)};
    //初始化UIpageViewController
    _pageController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    
    _pageController.dataSource = self;
    _pageController.delegate = self;
    NSArray *controllers = @[[self viewControllerAtIndex:index]];
    self.selectedButton.selected = _selectedIndexes[index].boolValue;
    [_pageController setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:_pageController];
    [self.view addSubview:[_pageController view]];
    
    [_pageController didMoveToParentViewController:self];
    
    self.view.gestureRecognizers = _pageController.gestureRecognizers;
}


-(CMViewerViewController *)viewControllerAtIndex:(NSInteger)index {
    CMViewerViewController *viewer = [[CMViewerViewController alloc]init];
    viewer.index = index;
    
    viewer.asset = [self assetWithIndex:index];
    return viewer;
    
}

//判断是 预览照片 还是 所有照片相关操作
- (PHAsset *)assetWithIndex:(NSInteger)index {
    if (_isPreviewSelAlbum) {
        return _previewAssets[index];
    } else {
        return [_album assetWithIndex:index];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self prepareUI];
    
}

//当hidesBarsOnTap隐藏时，隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return self.navigationController.navigationBarHidden;
}

-(void)prepareUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationController.hidesBarsOnTap = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    // 工具条
    
    _counterButton = [[CMSelButton alloc] init];
    UIBarButtonItem *counterItem = [[UIBarButtonItem alloc] initWithCustomView:_counterButton];
    
    _counterButton.count = _previewAssets.count;
    
    _doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(clickFinishedButton)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[spaceItem, counterItem, _doneItem];
    
    // 取消按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectedButton];
}


#pragma mark - 监听点击事件

-(void)clickFinishedButton{
    
    NSMutableArray<PHAsset *> *selectAssets = [self.delegate previewViewControllerSelectedAssets];
    if (selectAssets.count == 0) {
        CMViewerViewController *viewer = _pageController.viewControllers.lastObject;
        
        [selectAssets addObject:[self assetWithIndex:viewer.index]];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:CMImagePickerDidSelectedNotification object:self userInfo:nil];
}

//rightBarButtonItem点击事件
-(void)clickToSelected{
    
    CMViewerViewController *viewer = _pageController.viewControllers.lastObject;
    PHAsset *asset = [self assetWithIndex:viewer.index];
    _selectedButton.selected = !_selectedButton.selected;
    //设置动画
    
    __weak CMPreviewViewController *weakSelf = self;
    __weak NSMutableArray *weakSelectedIndexes = _selectedIndexes;
    __weak CMSelButton *weakCounterButton = _counterButton;
    [self setAnimationToButtonAndCompletion:^{
        
        if ([weakSelf.delegate respondsToSelector:@selector(previewViewController:didChangedAsset:selected:)]) {
            
            
            if ([weakSelf.delegate previewViewController:weakSelf didChangedAsset:asset selected:weakSelf.selectedButton.selected]) {
                weakSelectedIndexes[viewer.index] = @(weakSelf.selectedButton.selected);
            }else {
                weakSelf.selectedButton.selected = !weakSelf.selectedButton.selected;
            }
            weakCounterButton.count = [weakSelectedIndexes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == 1"]].count;
        }
    }];
}

/**
 *  给按钮设置动画
 *
 *  @param completion 动画完成回调
 */
-(void)setAnimationToButtonAndCompletion:(void(^)())completion{
    _selectedButton.transform = CGAffineTransformMakeScale(0.2, 0.2);
    [UIView
     animateWithDuration:0.25
     delay:0
     usingSpringWithDamping:0.5
     initialSpringVelocity:0
     options:UIViewAnimationOptionCurveEaseIn
     animations:^{
         _selectedButton.transform = CGAffineTransformIdentity;
     } completion:^(BOOL finished) {
         //回调
         completion();
     }];
    
}

//预览的照片数
-(NSInteger)photosCount{
    if (_isPreviewSelAlbum) {
        return _previewAssets.count;
    } else {
        return _album.photoCount;
    }
}

#pragma mark- UIPageViewControllerDataSource

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    CMViewerViewController *viewer = (CMViewerViewController *)viewController;
    NSInteger index = viewer.index + 1;
    
    if (index >= [self photosCount]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    CMViewerViewController *viewer = (CMViewerViewController *)viewController;
    NSInteger index = viewer.index - 1;
    if (index < 0) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    
    CMViewerViewController *viewer = (CMViewerViewController *)pendingViewControllers.lastObject;
    
    self.selectedButton.selected = _selectedIndexes[viewer.index].boolValue;
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    CMViewerViewController *viewer = _pageController.viewControllers.lastObject;
    
    self.selectedButton.selected = _selectedIndexes[viewer.index].boolValue;
}

//懒加载
- (UIButton *)selectedButton {
    if (_selectedButton == nil) {
        
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSURL *url = [[NSBundle mainBundle]URLForResource:CMImagePickerBundleName withExtension:nil];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        UIImage *normalImage = [UIImage imageNamed:@"check_box_default"
                                          inBundle:imageBundle
                     compatibleWithTraitCollection:nil];
        UIImage *selectedImage = [UIImage imageNamed:@"check_box_right"
                                            inBundle:imageBundle
                       compatibleWithTraitCollection:nil];
        
        [_selectedButton setImage:normalImage forState:UIControlStateNormal];
        [_selectedButton setImage:selectedImage forState:UIControlStateSelected];
        [_selectedButton sizeToFit];
        [_selectedButton addTarget:self action:@selector(clickToSelected) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedButton;
}
@end
