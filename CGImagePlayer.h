//
//  CGImagePlayer.h
//  CGNetHandle
//
//  Created by 郭成功 on 16/1/5.
//  Copyright © 2016年 郭成功. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CGPlayerCollectionViewCell.h"

@protocol CGImagePlayerDelegate <NSObject>

// 点击后触发的方法
- (void)collectionViewOfCGImagePlayer:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CGImagePlayer : UIView

@property (nonatomic, weak) id <CGImagePlayerDelegate> CGDelegate;

// 首页
@property (nonatomic, assign) NSInteger firstPage;

// 初始化: 1, frame; 2, 图片链接(NSString *)数组; 3, 轮播停留时长; 4, 滑动方向; 5, 占位图;
- (instancetype)initWithFrame:(CGRect)frame URLOfImages:(NSArray *)imageURLArray timeInterval:(NSTimeInterval)timeInterval scrollDirection:(UICollectionViewScrollDirection)scrollDirection placeholder:(UIImage *)placeholder;

@end
