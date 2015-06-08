//
//  GKActionSheet.m
//  GKActionSheet
//
//  Created by Jiang Chuncheng on 6/7/15.
//  Copyright (c) 2015 SenseForce. All rights reserved.
//

#import "GKActionSheet.h"

@class GKActionSheetItemCell;

@interface GKActionSheetItem ()

- (void)initItem;

@end

@implementation GKActionSheetItem

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title handler:(GKActionSheetItemHandler)handler {
    self = [super init];
    if (self) {
        self.image = image;
        self.title = title;
        self.handler = handler;
        
        [self initItem];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initItem];
    }
    return self;
}

- (void)initItem {
    self.titleColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
    self.titleFont = [UIFont systemFontOfSize:14];
}

@end

#pragma mark -

@interface GKActionSheetItemCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GKActionSheetItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame) - 40) / 2 , 5, 40, 40)];
        self.iconImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.iconImageView.frame) + 5, CGRectGetWidth(frame) - 10, 20)];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end

#pragma mark -

@interface GKActionSheet () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, assign, getter=isShowing) BOOL showing;

- (void)initSubViews;

- (void)prepareForShow;

@end

@implementation GKActionSheet

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items cancelButtonTitle:(NSString *)cancelButtonTitle {
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    if (self) {
        [self initSubViews];
        
        self.title = title;
        if (title) {
            self.titleLabel.text = title;
        }
        if (items) {
            [self.items addObjectsFromArray:items];
        }
        self.cancelButtonTitle = cancelButtonTitle;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.items = [NSMutableArray array];
    
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 265, CGRectGetWidth(self.bounds), 265)];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    [self addSubview:self.contentView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.contentView.bounds) - 10, 30)];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    
    UICollectionViewFlowLayout *viewLayout = [[UICollectionViewFlowLayout alloc] init];
    viewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds) - CGRectGetMaxY(self.titleLabel.frame) - 57)
                                             collectionViewLayout:viewLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[GKActionSheetItemCell class] forCellWithReuseIdentifier:@"GKActionSheetItemCell"];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.contentView addSubview:self.collectionView];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.contentView.bounds) - 46, CGRectGetWidth(self.contentView.bounds) - 40, 36)];
    self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.1f alpha:1.0f] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.3f alpha:1.0f] forState:UIControlStateHighlighted];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelButton];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.cancelButton.frame) - 11, CGRectGetWidth(self.contentView.bounds), 1.0f / [UIScreen mainScreen].scale)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    line.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:line];
}

- (void)addItem:(GKActionSheetItem *)item {
    if ([item isKindOfClass:[GKActionSheetItem class]]) {
        [self.items addObject:item];
    }
}

- (void)show {
    [self showFromView:nil];
}

- (void)showFromView:(UIView *)view {
    if (self.isShowing) {
        return;
        
    }
    
    UIView *superView = view;
    if ( ! view) {
        UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (controller.presentedViewController != nil) {
            controller = controller.presentedViewController;
        }
        superView = controller.view;
    }
    
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    [superView addSubview:self];
    
    self.alpha = 0;
    
    [self prepareForShow];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
        self.showing = YES;
    }];
}

- (void)prepareForShow {
    CGRect frame = self.frame;
    frame.size = self.superview.bounds.size;
    self.frame = frame;
    
    frame = self.contentView.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(self.contentView.bounds);
    self.contentView.frame = frame;
}

- (void)dismiss {
    if ( ! self.isShowing) {
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.showing = NO;
        [self removeFromSuperview];
    }];
}

- (void)cancelButtonClicked:(id)sender {
    [self dismiss];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GKActionSheetItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GKActionSheetItemCell" forIndexPath:indexPath];
    
    GKActionSheetItem *item = self.items[indexPath.row];
    
    cell.iconImageView.image = item.image;
    cell.titleLabel.text = item.title;
    cell.titleLabel.textColor = item.titleColor;
    cell.titleLabel.font = item.titleFont;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    GKActionSheetItem *item = self.items[indexPath.row];
    
    [self dismiss];
    
    GKActionSheetItemHandler handler = item.handler;
    if (handler) {
        handler(item);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 80);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 10, 5, 10);
}

@end
