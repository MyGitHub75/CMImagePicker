//
//  CMImageGridCell.m
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#import "CMImageGridCell.h"
#import "CMImagePickerGlobal.h"

@implementation CMImageGridCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.selectedButton];
    }
    return self;
}

/**
 *  按钮点击事件
 */
-(void)clickToSelected{
    _selectedButton.selected = !_selectedButton.selected;
    //设置动画
    __weak CMImageGridCell *weakSelf = self;
    [self setAnimationToButtonAndCompletion:^{
        
        if ([weakSelf.delegate respondsToSelector:@selector(imageGridCell:didSelected:)]) {
            [weakSelf.delegate imageGridCell:weakSelf didSelected:weakSelf.selectedButton.selected];
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



-(void)layoutSubviews{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    
    CGFloat offsetX = self.bounds.size.width - _selectedButton.bounds.size.width;
    _selectedButton.frame = CGRectOffset(_selectedButton.bounds, offsetX, 0);
    
}

#pragma 懒加载子控件
-(UIImageView *)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

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
