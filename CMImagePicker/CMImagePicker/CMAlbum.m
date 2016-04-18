//
//  CMAlbum.m
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#import "CMAlbum.h"

@implementation CMAlbum{
    /**
     *  当前相册资源集合
     */
    PHAssetCollection *_assetCollection;
}
@synthesize descPhotoCount = _descPhotoCount;
@synthesize descAlbumName = _descAlbumName;

+(instancetype)albumWithAssetCollection:(PHAssetCollection *)assetCollection{
 
    return [[self alloc]initWithAssetCollection:assetCollection];
}

- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection
{
    self = [super init];
    if (self) {
        //设置查询选项
        PHFetchOptions *options = [[PHFetchOptions alloc]init];
        //只搜索照片
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
        _assetCollection = assetCollection;
        _fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];   
    }
    return self;
}

-(NSString *)title{
    return _assetCollection.localizedTitle;
}

-(NSAttributedString *)descAlbumName{
    if (_descAlbumName == nil) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        
        [attributedString appendAttributedString:
         [[NSAttributedString alloc] initWithString:_assetCollection.localizedTitle]
         ];

        _descAlbumName = attributedString.copy;
    }
    return _descAlbumName;
}

-(NSAttributedString *)descPhotoCount{
    if (_descPhotoCount == nil) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        
        [attributedString appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:[NSString stringWithFormat:@"%zd", _fetchResult.count]
          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}]
         ];
        
        _descPhotoCount = attributedString.copy;
    }
    return _descPhotoCount;
}

-(NSInteger)photoCount{
    return _fetchResult.count;
}

- (UIImage *)emptyImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    
    [[UIColor whiteColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

- (CGSize)sizeWithScale:(CGSize)size {
    CGFloat scale = [UIScreen mainScreen].scale;
    return CGSizeMake(size.width * scale, size.height * scale);
}


- (PHAsset *)assetWithIndex:(NSInteger)index {
    if (index < 0 || index >= _fetchResult.count) {
        return nil;
    }
    return _fetchResult[index];
}

- (NSUInteger)indexWithAsset:(PHAsset *)asset {
    return [_fetchResult indexOfObject:asset];
}

-(void)requestThumbnailWithSize:(CGSize)size completion:(void (^)(UIImage * _Nonnull))completion{
    
    PHAsset *asset = [_fetchResult firstObject];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    // 设置 resizeMode 可以按照指定大小缩放图像
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 只回调一次缩放之后的照片，否则会调用多次
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [[PHImageManager defaultManager]requestImageForAsset:asset targetSize:[self sizeWithScale:size] contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        completion(result);
    }];
}


- (void)requestThumbnailWithAssetIndex:(NSInteger)index Size:(CGSize)size completion:(void (^)(UIImage * _Nonnull))completion {
    
    PHAsset *asset = _fetchResult[index];
    
    [[PHImageManager defaultManager]
     requestImageForAsset:asset
     targetSize:[self sizeWithScale:size]
     contentMode:PHImageContentModeAspectFill
     options:[self imageRequestOptions]
     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
         completion(result);
     }];
}

/// 图像请求选项
- (PHImageRequestOptions *)imageRequestOptions {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 设置 resizeMode 可以按照指定大小缩放图像
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 只回调一次缩放之后的照片，否则会调用多次
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    return options;
}
@end
