//
//  ViewController.m
//  CMImagePicker
//
//  Created by pro on 16/4/15.
//  Copyright © 2016年 CM. All rights reserved.
//

#import "ViewController.h"
#import "CMImagePicker.h"

@interface ViewController ()<CMImagePickerControllerDelegate>


@end

@implementation ViewController{
    NSArray *_iamgesArr;
    NSMutableArray<PHAsset *> *_selectedAssets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"照片" style:UIBarButtonItemStylePlain target:self action:@selector(clickBtn)];
}

- (void)clickBtn {
    CMImagePickerController *picker = [[CMImagePickerController alloc]initWithSelectAssets:_selectedAssets];
    picker.pickerDelegate = self;
    picker.maxPickerCount = 9;
    [self presentViewController:picker animated:YES completion:nil];
}


-(void)imagePickerController:(CMImagePickerController *)picker didFinishPickingWithSelectedImages:(NSArray<UIImage *> *)images selectedAssets:(NSMutableArray<PHAsset *> *)selectedAssets{
    _iamgesArr = images;
    _selectedAssets = selectedAssets;
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _iamgesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"123"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"123"];
    }
    cell.imageView.image = _iamgesArr[indexPath.row];
    return cell;
}
@end
