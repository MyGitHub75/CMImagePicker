//
//  CMAlbumsTableViewController.h
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@interface CMAlbumsTableViewController : UITableViewController

/**
 *  构造函数
 *
 *  @param selectAssets 选中素材数组，可以用于预览之前选中的照片集合
 *
 *  @return 相册列表控制器
 */
-(instancetype)initWithSelectAssets:(NSMutableArray <PHAsset *>*)selectAssets;

/**
 *  最大选中图片数
 */
@property (nonatomic) NSInteger maxPickerCount;
@end
