//
//  CMImageGridViewController.m
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#define margin 4
#import "CMImageGridViewController.h"
#import "CMImageGridCell.h"
#import "CMSelButton.h"
#import "CMImagePickerGlobal.h"
#import "CMPreviewViewController.h"

@interface CMImageGridViewController ()<CMImageGridCellDelegate,CMPreviewViewControllerDelegate>

@end

@implementation CMImageGridViewController{
    /// 相册模型
    CMAlbum *_album;
    /// 选中素材数组
    NSMutableArray <PHAsset *>*_selectedAssets;
    /// 最大选择图像数量
    NSInteger _maxPickerCount;
    
    /// 预览按钮
    UIBarButtonItem *_previewItem;
    /// 完成按钮
    UIBarButtonItem *_doneItem;
    /// 选择计数按钮
    CMSelButton *_counterButton;
}

static NSString * const reuseIdentifier = @"CMImageGridCellReuseIdentifier";

-(instancetype)initWithAlbum:(CMAlbum *)album selectedAssets:(NSMutableArray<PHAsset *> *)selectedAssets maxPickerCount:(NSInteger)maxPickerCount{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    
    CGFloat wh = ([UIScreen mainScreen].bounds.size.width - 5*margin)/4.0;
    layout.itemSize = CGSizeMake(wh, wh);
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    if (self = [super initWithCollectionViewLayout:layout]) {
        _album = album;
        _selectedAssets = selectedAssets;
        _maxPickerCount = maxPickerCount;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
}

-(void)setupUI{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.title = _album.title;
    // 工具条
    _previewItem = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(clickPreviewButton)];
    _previewItem.enabled = NO;
    
    _counterButton = [[CMSelButton alloc] init];
    UIBarButtonItem *counterItem = [[UIBarButtonItem alloc] initWithCustomView:_counterButton];
    
    _doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(clickFinishedButton)];
    _doneItem.enabled = NO;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[_previewItem, spaceItem, counterItem, _doneItem];
    
    // 取消按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickCloseButton)];
    // Register cell classes
    [self.collectionView registerClass:[CMImageGridCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self updateCounter];
}

#pragma mark - 监听方法
- (void)clickPreviewButton {
    CMPreviewViewController *preView = [[CMPreviewViewController alloc]initWithAlbum:_album selectedAssets:_selectedAssets maxPickerCount:_maxPickerCount indexPath:nil];
    
    preView.delegate = self;
    [self.navigationController pushViewController:preView animated:YES];
}

- (void)clickFinishedButton {
    [[NSNotificationCenter defaultCenter]postNotificationName:CMImagePickerDidSelectedNotification object:self userInfo:nil];
}

- (void)clickCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _album.photoCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMImageGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = [_album emptyImageWithSize:cell.bounds.size];
    [_album requestThumbnailWithAssetIndex:indexPath.item Size:cell.bounds.size completion:^(UIImage * _Nonnull thumbnail) {
        cell.imageView.image = thumbnail;
    }];
    
    // 哪些图片被选中
    cell.selectedButton.selected = [_selectedAssets containsObject:[_album assetWithIndex:indexPath.item]];
    
    cell.delegate = self;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CMPreviewViewController *preView = [[CMPreviewViewController alloc]initWithAlbum:_album selectedAssets:_selectedAssets maxPickerCount:_maxPickerCount indexPath:indexPath];
    preView.delegate = self;
    [self.navigationController pushViewController:preView animated:YES];
}

#pragma mark - CMImageGridCellDelegate
-(void)imageGridCell:(CMImageGridCell *)cell didSelected:(BOOL)selected{
    if (_selectedAssets.count == _maxPickerCount && selected) {
        
        NSString *msg = [NSString stringWithFormat:@"您最多只能选 %zd 中张照片",_maxPickerCount];
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertVC animated:YES completion:nil];
        
        cell.selectedButton.selected = NO;
        return;
    }
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    PHAsset *asset = [_album assetWithIndex:indexPath.item];
    if (selected) {
        [_selectedAssets addObject:asset];
    }else{
        [_selectedAssets removeObject:asset];
    }
    [self updateCounter];
    
}


#pragma mark - CMPreviewViewControllerDelegate
-(BOOL)previewViewController:(CMPreviewViewController *)previewViewController didChangedAsset:(PHAsset *)asset selected:(BOOL)selected{
    if (selected){
        if (_selectedAssets.count == _maxPickerCount) {
            NSString *msg = [NSString stringWithFormat:@"您最多只能选 %zd 中张照片",_maxPickerCount];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertVC animated:YES completion:nil];
            return NO;
        }
        [_selectedAssets addObject:asset];
    }else{
        [_selectedAssets removeObject:asset];
    }
    [self updateCounter];
    
    // 根据 asset 查找索引
    NSInteger index = [_album indexWithAsset:asset];
    if (index == NSNotFound) {
        NSLog(@"没有在当前相册找到素材");
        return YES;
    }
    // 更新 Cell 显示
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    CMImageGridCell *cell = (CMImageGridCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedButton.selected = selected;
    return YES;
}

-(NSMutableArray<PHAsset *> *)previewViewControllerSelectedAssets{
    return _selectedAssets;
}

/// 更新计数显示
- (void)updateCounter {
    _counterButton.count = _selectedAssets.count;
    _doneItem.enabled = _counterButton.count > 0;
    _previewItem.enabled = _counterButton.count > 0;
}
@end
