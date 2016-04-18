//
//  CMViewerViewController.h
//  ImagePickerTool
//
//  Created by pro on 16/4/14.
//  Copyright © 2016年 CM. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;
@interface CMViewerViewController : UIViewController

/// 图像索引
@property (nonatomic) NSUInteger index;
/// 图像资源
@property (nonatomic) PHAsset *asset;
@end
