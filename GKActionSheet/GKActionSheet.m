//
//  GKActionSheet.m
//  GKActionSheet
//
//  Created by Jiang Chuncheng on 6/7/15.
//  Copyright (c) 2015 SenseForce. All rights reserved.
//

#import "GKActionSheet.h"

#define BUTTON_WIDTH    60
#define BUTTON_HEIGHT   60


@interface GKActionSheetItem ()

- (void)initItem;

@end

@implementation GKActionSheetItem

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(GKActionSheetItemHandler)handler {
    return [[self alloc] initWithImage:image title:title handler:handler];
}

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
    self.titleFont = [UIFont systemFontOfSize:12];
}

@end

#pragma mark -

@interface UIImage (GKActionSheet)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end

@implementation UIImage (GKActionSheet)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

#pragma mark -

@interface GKActionSheet () <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *referView;

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *buttonsScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *destructiveButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *destructiveButtonTitle;
@property (nonatomic, copy) GKButtonHandler destructiveHandler;
@property (nonatomic, strong) NSMutableDictionary *destructiveButtonBackgroundColors;
@property (nonatomic, strong) NSMutableDictionary *destructiveButtonTitleColors;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, assign, getter=isShowing) BOOL showing;

- (void)initSubViews;

- (void)prepareForShow;

- (void)addButtons;

@end

@implementation GKActionSheet

+ (instancetype)actionSheetWithTitle:(NSString *)title items:(NSArray *)items cancelButtonTitle:(NSString *)cancelButtonTitle {
    return [[self alloc] initWithTitle:title items:items cancelButtonTitle:cancelButtonTitle];
}

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
    self.shouldDismissOnBackgroundTouch = YES;
    
    self.items = [NSMutableArray array];
    
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.maskView = [[UIView alloc] initWithFrame:self.frame];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    self.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 350)];
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    
    self.shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, width, 5)];
    self.shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.shadowImageView.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithWhite:0.75f alpha:1.0f].CGColor,
                       (id)[UIColor colorWithWhite:0.9f alpha:1.0f].CGColor,nil];
    [self.shadowImageView.layer addSublayer:gradient];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, width, 20)];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.buttonsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), width, 180)];
    self.buttonsScrollView.pagingEnabled = YES;
    self.buttonsScrollView.scrollEnabled = YES;
    self.buttonsScrollView.scrollsToTop = NO;
    self.buttonsScrollView.delegate = self;
    self.buttonsScrollView.showsHorizontalScrollIndicator = NO;
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.buttonsScrollView.frame), width, 20)];
    self.pageControl.numberOfPages = 1;
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    
    [self addSubview:self.maskView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.shadowImageView];
    [self.contentView addSubview:self.buttonsScrollView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.pageControl];
    
    self.destructiveButtonBackgroundColors = [NSMutableDictionary dictionaryWithCapacity:2];
    self.destructiveButtonBackgroundColors[@(UIControlStateNormal)] = [UIColor whiteColor];
    self.destructiveButtonBackgroundColors[@(UIControlStateHighlighted)] = [UIColor colorWithWhite:0.8f alpha:1.0f];
    
    self.destructiveButtonTitleColors = [NSMutableDictionary dictionaryWithCapacity:2];
    self.destructiveButtonTitleColors[@(UIControlStateNormal)] = [UIColor grayColor];
    self.destructiveButtonTitleColors[@(UIControlStateHighlighted)] = [UIColor grayColor];
    
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMaskTapGesture:)];
    gesture.numberOfTouchesRequired = 1;
    gesture.numberOfTapsRequired = 1;
    [self.maskView addGestureRecognizer:gesture];
}

- (void)handleMaskTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (self.shouldDismissOnBackgroundTouch) {
        [self dismiss];
    }
}

- (void)addItem:(GKActionSheetItem *)item {
    if ([item isKindOfClass:[GKActionSheetItem class]]) {
        [self.items addObject:item];
    }
}

- (void)setDestructiveButtonWithTitle:(NSString *)title handler:(GKButtonHandler)handler {
    self.destructiveButtonTitle = title;
    self.destructiveHandler = handler;
}

- (void)setDestructiveButtonBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    if (color) {
        self.destructiveButtonBackgroundColors[@(state)] = color;
    }
    else {
        [self.destructiveButtonBackgroundColors removeObjectForKey:@(state)];
    }
}

- (void)setDestructiveButtonTitleColor:(UIColor *)color forState:(UIControlState)state {
    if (color) {
        self.destructiveButtonTitleColors[@(state)] = color;
    }
    else {
        [self.destructiveButtonTitleColors removeObjectForKey:@(state)];
    }
}

- (void)show {
    [self showFromView:nil];
}

- (void)showFromView:(UIView *)view {
    UIView *referView;
    if ( ! referView) {
        UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (controller.presentedViewController != nil) {
            controller = controller.presentedViewController;
        }
        referView = controller.view;
    }
    
    self.referView = referView;
    
    [self prepareForShow];
    
    CGRect screen = referView.frame;
    self.frame = screen;
    self.maskView.frame = screen;
    self.maskView.alpha = 0;
    CGRect frame = self.contentView.frame;
    frame.origin.y = screen.size.height;
    self.contentView.frame = frame;
    [referView addSubview:self];
    
    self.showing = YES;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect targetFrame = frame;
        self.maskView.alpha = 1;
        targetFrame.origin.y = screen.size.height - frame.size.height;
        self.contentView.frame = targetFrame;
    }];
}


- (void)dismiss {
    if ( ! self.isShowing) {
        return;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect screen = self.referView.frame;
        self.maskView.alpha = 0;
        CGRect frame = self.contentView.frame;
        frame.origin.y = screen.size.height;
        self.contentView.frame = frame;
        [self.referView addSubview:self];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)prepareForShow {
    [self addButtons];
    
    self.pageControl.hidden = ([self.items count] <= 8);
    self.pageControl.numberOfPages = ceilf([self.items count] / 8.0f);
    self.pageControl.userInteractionEnabled = NO;

    
    CGRect frame = self.frame;
    frame.size = self.referView.bounds.size;
    self.frame = frame;

    frame = self.pageControl.frame;
    frame.origin.y = CGRectGetMaxY(self.buttonsScrollView.frame);
    self.pageControl.frame = frame;
    
    frame = self.destructiveButton.frame;
    frame.origin.y = CGRectGetMaxY(self.pageControl.frame) + (self.pageControl.hidden ? 0 : 5);
    self.destructiveButton.frame = frame;
    
    frame = self.cancelButton.frame;
    frame.origin.y = CGRectGetMaxY(self.pageControl.frame) + (self.pageControl.hidden ? 0 : 5) + CGRectGetHeight(self.destructiveButton.bounds) + 10;
    self.cancelButton.frame = frame;
    
    frame = self.contentView.frame;
    frame.size.height = CGRectGetMaxY(self.cancelButton.frame) + 20;
    frame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(frame);
    self.contentView.frame = frame;
}

- (void)addButtons {
    CGFloat pageWidth = CGRectGetWidth(self.buttonsScrollView.bounds);
    CGFloat paddingLeft = 20.0f;
    CGFloat paddingRight = 20.0f;
    CGFloat paddingTop = 15.0f;
    CGFloat paddingBottom = 5.0f;
    CGFloat spacingHorizontal = (pageWidth - paddingLeft - paddingRight - BUTTON_WIDTH * 4) / 3;
    CGFloat rowHeight = BUTTON_HEIGHT + 25.0f;
    
    NSUInteger row = 0;
    NSUInteger col = 0;
    NSUInteger page = 0;
    
    for (UIView *view in self.buttonsScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    for (NSInteger index = 0, count = [self.items count]; index < count; index ++) {
        page = index / 8;
        row = (index % 8) / 4;
        col = (index % 8) % 4;
        
        GKActionSheetItem *item = self.items[index];
        
        CGFloat x = pageWidth * page + paddingLeft + (spacingHorizontal + BUTTON_WIDTH) * col;
        CGFloat y = paddingTop + rowHeight * row;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [button setImage:item.image forState:UIControlStateNormal];
        button.tag = index;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x - 5, y + 62, BUTTON_WIDTH + 10, 14)];
        label.text = item.title;
        label.textColor = item.titleColor;
        label.font = item.titleFont;
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [button setAccessibilityLabel:item.title];
        
        [self.buttonsScrollView addSubview:button];
        [self.buttonsScrollView addSubview:label];
        [label setAccessibilityElementsHidden:YES];
        
    }
    
    CGRect frame = self.buttonsScrollView.frame;
    frame.size.height = rowHeight * ([self.items count] >= 4 ? 2 : 1) + paddingTop + paddingBottom;
    self.buttonsScrollView.frame = frame;
    
    self.buttonsScrollView.contentSize = CGSizeMake(ceilf([self.items count] / 8.0f) * CGRectGetWidth(self.buttonsScrollView.bounds), CGRectGetHeight(self.buttonsScrollView.bounds));
    
    if (self.destructiveButtonTitle || self.destructiveHandler) {
        if ( ! self.destructiveButton) {
            self.destructiveButton = [self actionButtonWithTitle:self.destructiveButtonTitle top:CGRectGetMaxY(self.pageControl.frame)];
            [self.destructiveButton addTarget:self action:@selector(destructiveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *button = self.destructiveButton;
            for (NSNumber *state in self.destructiveButtonBackgroundColors.allKeys) {
                UIColor *color = self.destructiveButtonBackgroundColors[state];
                [button setBackgroundImage:[UIImage imageWithColor:color size:button.bounds.size] forState:[state unsignedIntegerValue]];
            }
            for (NSNumber *state in self.destructiveButtonTitleColors.allKeys) {
                UIColor *color = self.destructiveButtonTitleColors[state];
                [button setTitleColor:color forState:[state unsignedIntegerValue]];
            }
        }
        else {
            [self.destructiveButton removeFromSuperview];
        }
    }
    else {
        [self.destructiveButton removeFromSuperview];
        self.destructiveButton = nil;
    }
    
    if ( ! self.cancelButton) {
        self.cancelButton = [self actionButtonWithTitle:self.cancelButtonTitle top:CGRectGetMaxY(self.pageControl.frame) + CGRectGetHeight(self.destructiveButton.bounds) + 10];
        [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.cancelButton removeFromSuperview];
    }
    
    [self.contentView addSubview:self.destructiveButton];
    [self.contentView addSubview:self.cancelButton];
}

- (UIButton *)actionButtonWithTitle:(NSString *)title top:(CGFloat)top {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(22, top, CGRectGetWidth(self.contentView.bounds) - 44, 42)];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:button.bounds.size] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.8f alpha:1.0f] size:button.bounds.size] forState:UIControlStateHighlighted];
    return button;
}

- (IBAction)buttonClicked:(id)sender {
    NSInteger index = ((UIButton *)sender).tag;
    if (index < [self.items count]) {
        GKActionSheetItem *item = self.items[index];
        GKActionSheetItemHandler handler = item.handler;
        if (handler) {
            handler(item);
        }
    }
    
    [self dismiss];
}

- (IBAction)destructiveButtonClicked:(id)sender {
    GKButtonHandler handler = self.destructiveHandler;
    if (handler) {
        handler(sender);
    }
    [self dismiss];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismiss];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = (NSInteger)scrollView.contentOffset.x / CGRectGetWidth(self.bounds);
}

@end
