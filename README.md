# CMImagePicker
简单快捷的图选择框架
# 系统支持

* iOS8+

* Xcode7

## 安装 

### CocoaPods

* 在 Podfile 中输入以下内容：
```
pod 'CMImagePicker'
```
### 其他方法
* 下载文件包，将包（CMImagePicker）拖入程序:
```
#import "CMImagePicker.h"
```

## 使用
### Objective-C

* 导入框架

```objc
@import CMImagePicker;
```

* 在私有扩展中定义属性

```objc
@interface ViewController () <CMImagePickerControllerDelegate>
/// 选中照片数组
@property (nonatomic) NSArray *images;
/// 选中资源素材数组，用于定位已经选择的照片
@property (nonatomic) NSArray *selectedAssets;
@end
```

* 在点击事件中实现以下代码：

```objc
- (void)clickButton {
    CMImagePickerController *picker = [[CMImagePickerController alloc] initWithSelectedAssets:self.selectedAssets];

    // 设置图像选择代理
    picker.pickerDelegate = self;
    // 设置目标图片尺寸
    picker.targetSize = CGSizeMake(1000, 1000);
    // 设置最大选择照片数量
    picker.maxPickerCount = 9;

    [self presentViewController:picker animated:YES completion:nil];
}
```

* 遵守协议

```objc
@interface ViewController () <CMImagePickerControllerDelegate>
```

* 实现协议方法

```objc
#pragma mark - CMImagePickerControllerDelegate
- (void)imagePickerController:(CMImagePickerController *)picker
      didFinishSelectedImages:(NSArray<UIImage *> *)images
               selectedAssets:(NSArray<PHAsset *> *)selectedAssets {

    // 记录图像，方便在 tableView 显示
    self.images = images;
    // 记录选中资源集合，方便再次选择照片定位
    self.selectedAssets = selectedAssets;

    [self.tableView reloadData];

    [self dismissViewControllerAnimated:YES completion:nil];
}
```
