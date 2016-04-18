//
//  CMAlbumsTableViewController.m
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#import "CMAlbumsTableViewController.h"
#import "CMImageGridViewController.h"
#import "CMAlbum.h"
#import "CMAlbumCell.h"

static NSString *const CMAlumCellReuseIdentifier = @"CMAlumCellReuseIdentifier";

@interface CMAlbumsTableViewController (){
    /**
     *  相册资源集合
     */
    NSArray<CMAlbum *> *_assetCollection;
    /**
     *  选中素材数组
     */
    NSMutableArray <PHAsset *> *_selectedAssets;
}

@end

@implementation CMAlbumsTableViewController


-(instancetype)initWithSelectAssets:(NSMutableArray<PHAsset *> *)selectAssets{
    if (self = [super init]) {
        _selectedAssets = selectAssets;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 导航栏
    self.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickCloseButton)];
    
    //获取权限并回调Album数
    [self fetchAssetCollectionWithCompletion:^(NSArray<CMAlbum *> *assetCollection, BOOL isPermited) {
        if (!isPermited) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"照片" message:@"没有权限访问相册，请先在设置程序中授权访问" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertVC animated:YES completion:nil];
            return ;
        }
        _assetCollection = assetCollection;
        [self.tableView reloadData];
        
                 //默认显示第一个相册
        if (_assetCollection.count > 0) {
            CMImageGridViewController *grid = [[CMImageGridViewController alloc]
                                               initWithAlbum:_assetCollection[0]
                                               selectedAssets:_selectedAssets
                                               maxPickerCount:_maxPickerCount];
            
            [self.navigationController pushViewController:grid animated:NO];
        }
    }];
    
    
    [self.tableView registerClass:[CMAlbumCell class] forCellReuseIdentifier:CMAlumCellReuseIdentifier];
    self.tableView.rowHeight = 60;
}

/**
 *  获取权限操作
 *
 *  @param complete 返回相册集合数
 */
-(void)fetchAssetCollectionWithCompletion:(void(^)(NSArray <CMAlbum *>*, BOOL))complete{

    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    switch (author) {
        case PHAuthorizationStatusNotDetermined:{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [self fetchResultWithCompletion:complete];
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized:
            [self fetchResultWithCompletion:complete];
            break;
        default:
            NSLog(@"拒绝访问照片");
            complete(nil,NO);
            break;
    }
}

/**
 *  获得Album的数量
 *
 *  @param complete CMAlbum模型
 */
-(void)fetchResultWithCompletion:(void(^)(NSArray <CMAlbum *>*, BOOL))complete{
    /**
     *  获取相册
     */
    PHFetchResult *allAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    // 同步相册
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:NO]];
    
    PHFetchResult *syncedAlbum = [PHAssetCollection
                                  fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                  subtype:PHAssetCollectionSubtypeAlbumRegular
                                  options:options];
    NSMutableArray *result = [NSMutableArray array];
    [allAlbums enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CMAlbum *album = [CMAlbum albumWithAssetCollection:obj];
        //如果相册里的照片数为0就不添加
        if (album.photoCount) {
            [result addObject:album];
        }
    }];

    [syncedAlbum enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CMAlbum *album = [CMAlbum albumWithAssetCollection:obj];
        //如果相册里的照片数为0就不添加
        if (album.photoCount) {
            [result addObject:album];
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{ complete(result.copy, YES); });
}

- (void)clickCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _assetCollection.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:CMAlumCellReuseIdentifier forIndexPath:indexPath];
    
    CMAlbum *album = _assetCollection[indexPath.row];
    cell.album = album;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CMAlbum *album = _assetCollection[indexPath.row];
    CMImageGridViewController *grid = [[CMImageGridViewController alloc]initWithAlbum:album selectedAssets:_selectedAssets maxPickerCount:_maxPickerCount];
    
    [self.navigationController pushViewController:grid animated:YES];
}


#pragma mark - 分割线全屏
-(void)viewDidLayoutSubviews
{
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPat{
    
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
}
@end
