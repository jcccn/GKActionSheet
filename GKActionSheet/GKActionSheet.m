//
//  GKActionSheet.m
//  GKActionSheet
//
//  Created by Jiang Chuncheng on 6/7/15.
//  Copyright (c) 2015 SenseForce. All rights reserved.
//

#import "GKActionSheet.h"

@interface GKActionSheetItem ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

- (void)initContentView;

@end

@implementation GKActionSheetItem

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title handler:(GKActionSheetItemHandler)handler {
    self = [super init];
    if (self) {
        self.image = image;
        self.title = title;
        self.handler = handler;
        
        [self initContentView];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initContentView];
    }
    return self;
}

- (void)initContentView {
    self.titleColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
    self.titleFont = [UIFont systemFontOfSize:14];
    
    [self addObserver:self forKeyPath:@"image" options:0 context:nil];
    [self addObserver:self forKeyPath:@"title" options:0 context:nil];
    [self addObserver:self forKeyPath:@"titleColor" options:0 context:nil];
    [self addObserver:self forKeyPath:@"titleFont" options:0 context:nil];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 60)];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
    self.iconImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.iconImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.iconImageView.frame) + 5, 30, 20)];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = self.titleColor;
    self.titleLabel.font = self.titleFont;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        self.iconImageView.image = self.image;
    }
    else if ([keyPath isEqualToString:@"title"]) {
        self.titleLabel.text = self.title;
    }
    else if ([keyPath isEqualToString:@"titleColor"]) {
        self.titleLabel.textColor = self.titleColor;
    }
    else if ([keyPath isEqualToString:@"titleFont"]) {
        self.titleLabel.font = self.titleFont;
    }
    else {
        if ([super respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"image"];
    [self removeObserver:self forKeyPath:@"title"];
    [self removeObserver:self forKeyPath:@"titleColor"];
    [self removeObserver:self forKeyPath:@"titleFont"];
}

@end

#pragma mark -

@interface GKActionSheet () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSMutableArray *items;

- (void)initSubViews;

@end

@implementation GKActionSheet

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items cancelButtonTitle:(NSString *)cancelButtonTitle {
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 216)];
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
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.bounds) - 10, 20)];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.titleLabel];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.bounds) - 46, CGRectGetWidth(self.bounds) - 40, 36)];
    self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.1f alpha:1.0f] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    
    self.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
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
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetHeight(superView.bounds) - CGRectGetHeight(self.bounds);
    frame.size.width = CGRectGetWidth(superView.bounds);
    self.frame = frame;
    [superView addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)cancelButtonClicked:(id)sender {
    [self dismiss];
}

@end
