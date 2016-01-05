//
//  CGImagePlayer.m
//  CGNetHandle
//
//  Created by 郭成功 on 16/1/5.
//  Copyright © 2016年 郭成功. All rights reserved.
//

#import "CGImagePlayer.h"
#import "UIImageView+WebCache.h"

@interface CGImagePlayer () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imageMutableArray;
@property (nonatomic, strong) NSMutableArray *imageVArray;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirction;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation CGImagePlayer

- (instancetype)initWithFrame:(CGRect)frame URLOfImages:(NSArray *)imageURLArray timeInterval:(NSTimeInterval)timeInterval scrollDirection:(UICollectionViewScrollDirection)scrollDirection placeholder:(UIImage *)placeholder
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViewsWithImages:nil URLOfImages:imageURLArray timeInterval:timeInterval scrollDirection:scrollDirection placeholder:placeholder];
    }
    return self;
}

- (void)createSubViewsWithImages:(NSArray *)imageArray URLOfImages:(NSArray *)imageURLArray timeInterval:(NSTimeInterval)timeInterval scrollDirection:(UICollectionViewScrollDirection)scrollDirection placeholder:(UIImage *)placeholder
{
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.page = 1;
    
    // imageMutableArray
    if (nil != imageArray) {
        
        self.imageMutableArray = [NSMutableArray arrayWithArray:imageArray];
        
        [self.imageMutableArray insertObject:[imageArray objectAtIndex:(imageArray.count - 1)] atIndex:0];
        
        [self.imageMutableArray addObject:[imageArray objectAtIndex:0]];
        
    } else {
        
        self.imageMutableArray = [NSMutableArray array];
        
        if (nil == placeholder) {
            
            for (NSInteger i = 0; i < imageURLArray.count + 2; i++) {
                
                [self.imageMutableArray addObject:[UIImage imageNamed:@"WhiteImage.png"]];
                
            }
            
        } else {
            
            for (NSInteger i = 0; i < imageURLArray.count + 2; i++) {
                
                [self.imageMutableArray addObject:placeholder];
                
            }
            
        }
        
        [self loadImageWithURL:imageURLArray];
        
    }
    
    // collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.scrollDirection = scrollDirection;
    
    self.scrollDirction = scrollDirection;
    
    flowLayout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    
    flowLayout.minimumInteritemSpacing = 0;
    
    flowLayout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:flowLayout];
    
    self.collectionView.delegate = self;
    
    self.collectionView.dataSource = self;
    
    self.collectionView.pagingEnabled = YES;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[CGPlayerCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self addSubview:self.collectionView];
    
    // timer
    
    self.timeInterval = timeInterval;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    
    // pageControl
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, 15.0 * self.imageMutableArray.count - 2, 30)];
    
    self.pageControl.numberOfPages = self.imageMutableArray.count - 2;
    
    CGPoint center = CGPointMake(self.frame.size.width / 2.0, self.pageControl.center.y);
    
    self.pageControl.center = center;
    
    self.pageControl.userInteractionEnabled = NO;
    
    [self addSubview:self.pageControl];
    
}

#pragma 网络请求
- (void)loadImageWithURL:(NSArray *)URLArray
{
    
    self.imageVArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < URLArray.count; i++) {
        
        NSString *imageURLStr = [URLArray objectAtIndex:i];
        
//        NSString *imageURLStrUTF8 = [imageURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *imageURLStrUTF8 = [imageURLStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
        
        NSURL *imageURLTemp = [NSURL URLWithString:imageURLStrUTF8];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        
        [self.imageVArray addObject:imageView];
        
        [imageView sd_setImageWithURL:imageURLTemp completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            for (NSInteger j = 0; j < URLArray.count; j++) {
                
                if ([imageURL isEqual: [NSURL URLWithString:[URLArray objectAtIndex:j]]]) {
                    
                    [self.imageMutableArray replaceObjectAtIndex:(j + 1) withObject:image];
                    
                    if (0 == j) {
                        
                        [self.imageMutableArray replaceObjectAtIndex:(self.imageMutableArray.count - 1) withObject:image];
                        
                    } else if (j == (URLArray.count - 1)) {
                        
                        [self.imageMutableArray replaceObjectAtIndex:0 withObject:image];
                        
                    }
                    
                    [self.collectionView reloadData];
                    
                }
                
            }
            
        }];
        
    }
    
}

- (void)setFirstPage:(NSInteger)firstPage
{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        _firstPage = firstPage + 1;
        
        self.page = firstPage + 1;
        
        self.pageControl.currentPage = firstPage + 1 - 1;
        
        self.collectionView.contentOffset = CGPointMake(self.collectionView.frame.size.width * (firstPage + 1), 0);
        
    });
    
}

#pragma collectionView代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.imageMutableArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGPlayerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.image = [self.imageMutableArray objectAtIndex:indexPath.item];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.CGDelegate collectionViewOfCGImagePlayer:collectionView didSelectItemAtIndexPath:indexPath];
    
}

#pragma 轮播操作
- (void)timerAction
{
    
    [self correctPage];
    
    self.page += 1;
    
    if (UICollectionViewScrollDirectionHorizontal == self.scrollDirction) {
        
        if (self.page < self.imageMutableArray.count) {
            
            NSIndexPath *inadxPath = [NSIndexPath indexPathForItem:self.page inSection:0];
            
            [self.collectionView scrollToItemAtIndexPath:inadxPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            
        }
        
    } else {
        
        if (self.page < self.imageMutableArray.count) {
            
            NSIndexPath *inadxPath = [NSIndexPath indexPathForItem:self.page inSection:0];
            
            [self.collectionView scrollToItemAtIndexPath:inadxPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
            
        }
        
    }
    
    self.pageControl.currentPage = (self.page - 1) == (self.imageMutableArray.count - 2) ? 0 : (self.page - 1);
    
}

#pragma 修正偏移坐标
- (void)correctPage
{
    
    if (self.page == self.imageMutableArray.count - 1) {
        
        self.page = 1;
        
        [self correctContentOffset];
        
    } else if (0 == self.page) {
        
        self.page = self.imageMutableArray.count - 2;
        
        [self correctContentOffset];
        
    }
    
    self.pageControl.currentPage = self.page - 1;
    
}

- (void)correctContentOffset
{
    
    if (UICollectionViewScrollDirectionHorizontal == self.scrollDirction) {
        
        CGPoint point = self.collectionView.contentOffset;
        
        point.x = self.page * self.collectionView.frame.size.width;
        
        self.collectionView.contentOffset = point;
        
    } else {
        
        CGPoint point = self.collectionView.contentOffset;
        
        point.y = self.page * self.collectionView.frame.size.height;
        
        self.collectionView.contentOffset = point;
        
    }
    
}

#pragma scrollView代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    [self correctPage];
    
    [self.timer invalidate];
    
    self.timer = nil;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (UICollectionViewScrollDirectionHorizontal == self.scrollDirction) {
        
        self.page = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
        
    } else {
        
        self.page = self.collectionView.contentOffset.y / self.collectionView.frame.size.height;
        
    }
    
    [self correctPage];
    
}

@end
