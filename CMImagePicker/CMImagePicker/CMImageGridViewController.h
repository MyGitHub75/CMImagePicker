//
//  CMImageGridViewController.h
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAlbum.h"
@import Photos;

@interface CMImageGridViewController : UICollectionViewController
/**
 *  构造函数
 *
 *  @param album          相册模型
 *  @param selectedAssets 选中资源数组
 *  @param maxPickerCount 最大选择数量
 *
 *  @return 多图选择控制器
 */
- (instancetype)initWithAlbum:(CMAlbum *)album
               selectedAssets:(NSMutableArray <PHAsset *> *)selectedAssets
               maxPickerCount:(NSInteger)maxPickerCount;
@end
