//
//  CMAlbumCell.m
//  ImagePickerTool
//
//  Created by pro on 16/4/12.
//  Copyright © 2016年 CM. All rights reserved.
//

#define cellHeight self.contentView.bounds.size.height
#import "CMAlbumCell.h"

@implementation CMAlbumCell

#pragma mark - 构造函数
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {

        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        [self.textLabel sizeToFit];
    }
    return self;
}

-(void)setAlbum:(CMAlbum *)album{
    _album = album;
    
    self.imageView.image = [album emptyImageWithSize:CGSizeMake(cellHeight, cellHeight)];
    [album requestThumbnailWithSize:CGSizeMake(cellHeight, cellHeight) completion:^(UIImage * _Nonnull thumbnail) {
        self.imageView.image = thumbnail;
    }];
    self.textLabel.attributedText = album.descAlbumName;
    self.detailTextLabel.text = [NSString stringWithFormat:@"(%@)", [album.descPhotoCount string]] ;

}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, cellHeight, cellHeight);
    
    CGRect imgframe = self.textLabel.frame;
    imgframe.origin.x = CGRectGetMaxX(self.imageView.frame)+7;
    self.textLabel.frame = imgframe;
    
    CGRect frame = self.detailTextLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.textLabel.frame)+12;
    self.detailTextLabel.frame = frame;
}
@end
