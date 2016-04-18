//
//  CMAlbum.h
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;

@interface CMAlbum : NSObject
/**
*  构造函数
*
*  @param assetCollection 资源集合(某一个相册)
*
*  @return 相册模型
*/
+ (_Nonnull instancetype)albumWithAssetCollection:(PHAssetCollection * _Nonnull)assetCollection;

/**
 *  当前相册内的资源查询结果
 */
@property (nonatomic, readonly, nullable) PHFetchResult *fetchResult;

/**
 *  相册标题
 */
@property (nonatomic, readonly, nullable) NSString *title;

/**
 *  相册描述信息(相册名)
 */
@property (nonatomic, readonly, nullable) NSAttributedString *descAlbumName;

/**
 *  相册描述信息(照片数量)
 */
@property (nonatomic, readonly, nullable) NSAttributedString *descPhotoCount;

/**
 *  相片数量
 */
@property (nonatomic, readonly) NSInteger photoCount;

/**
 *  生成空白图片
 *
 *  @param size 图尺寸
 *
 *  @return 图片
 */
- (nullable UIImage *)emptyImageWithSize:(CGSize)size;

/**
 *  返回索引对应的资源素材
 *
 *  @param index 资源索引
 *
 *  @return 资源素材
 */
- (PHAsset * _Nullable)assetWithIndex:(NSInteger)index;

/**
 * 返回资源素材在相册中的索引
 *
 * @param asset 资源素材
 *
 * @return 索引
 */
- (NSUInteger)indexWithAsset:(PHAsset * _Nonnull)asset;

/**
 *  请求缩略图
 *
 *  @param size       缩略图尺寸
 *  @param completion 完成回调
 */
- (void)requestThumbnailWithSize:(CGSize)size completion:( void (^ _Nonnull)(UIImage * _Nonnull thumbnail))completion;

/**
 *  请求指定资源索引的缩略图
 *
 *  @param index      资源索引
 *  @param size       缩略图尺寸
 *  @param completion 完成回调
 */
- (void)requestThumbnailWithAssetIndex:(NSInteger)index Size:(CGSize)size completion:( void (^ _Nonnull)(UIImage * _Nonnull thumbnail))completion;
@end
