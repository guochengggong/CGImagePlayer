//
//  CGPlayerCollectionViewCell.m
//  CGNetHandle
//
//  Created by 郭成功 on 16/1/5.
//  Copyright © 2016年 郭成功. All rights reserved.
//

#import "CGPlayerCollectionViewCell.h"

@interface CGPlayerCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CGPlayerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createSubViews];
        
    }
    return self;
}

- (void)createSubViews
{
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.contentView addSubview:self.imageView];
    
}

- (void)setImage:(UIImage *)image
{
    
    _image = image;
    _imageView.image = image;
    
}


@end
