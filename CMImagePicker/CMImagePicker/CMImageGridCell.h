//
//  CMImageGridCell.h
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#import <UIKit/UIKit.h>
 

@class CMImageGridCell;

@protocol CMImageGridCellDelegate <NSObject>

/**
 *  图像 Cell 选中事件
 *
 *  @param cell     图像 cell
 *  @param selected 是否选中
 */
- (void)imageGridCell:(CMImageGridCell *)cell didSelected:(BOOL)selected;

@end

@interface CMImageGridCell : UICollectionViewCell

@property(nonatomic, assign)id <CMImageGridCellDelegate> delegate;

/**
 *  子控件图片
 */
@property(nonatomic) UIImageView *imageView;

/**
 *  子控件选中按钮
 */
@property(nonatomic) UIButton *selectedButton;


@end
