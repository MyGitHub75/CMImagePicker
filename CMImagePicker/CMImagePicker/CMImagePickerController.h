//
//  CMImagePickerController.h
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMImagePickerControllerDelegate;
@class CMImagePickerController;
@import Photos;

@protocol CMImagePickerControllerDelegate <NSObject>

/**
 *  图像选择完成代理方法
 *
 *  @param picker         图像选择控制器
 *  @param images         用户选中图像数组
 *  @param selectedAssets 选中素材数组，方便重新定位图像
 */
- (void)imagePickerController:(CMImagePickerController *)picker didFinishPickingWithSelectedImages:(NSArray <UIImage *> *)images selectedAssets:(NSMutableArray<PHAsset *>*)selectedAssets;

@end

@interface CMImagePickerController : UINavigationController

/**
 *  构造函数
 *
 *  @param selectAssets 选中素材数组，可以用于预览之前选中的照片集合
 *
 *  @return 图像选择控制器
 */
-(instancetype)initWithSelectAssets:(NSMutableArray <PHAsset *>*)selectAssets;

/**
 *  加载图像尺寸(以像素为单位，默认大小 600 * 600)
 */
@property (nonatomic) CGSize targetSize;

/**
 *  最大选中图片数
 */
@property (nonatomic) NSInteger maxPickerCount;

@property(nonatomic, weak) id <CMImagePickerControllerDelegate> pickerDelegate;
@end
