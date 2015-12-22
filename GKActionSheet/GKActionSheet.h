//
//  GKActionSheet.h
//  GKActionSheet
//
//  Created by Jiang Chuncheng on 6/7/15.
//  Copyright (c) 2015 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKActionSheetItem;
@class GKActionSheet;

typedef void(^GKActionSheetItemHandler)(GKActionSheetItem *item);
typedef void(^GKButtonHandler)(UIButton *button);

@interface GKActionSheetItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, copy) GKActionSheetItemHandler handler;

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(GKActionSheetItemHandler)handler;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title handler:(GKActionSheetItemHandler)handler;

@end

#pragma mark -

@interface GKActionSheet : UIView

+ (instancetype)actionSheetWithTitle:(NSString *)title items:(NSArray *)items cancelButtonTitle:(NSString *)cancelButtonTitle;
- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items cancelButtonTitle:(NSString *)cancelButtonTitle;

- (void)addItem:(GKActionSheetItem *)item;
- (void)setDestructiveButtonWithTitle:(NSString *)title handler:(GKButtonHandler)handler;
- (void)setDestructiveButtonBackgroundColor:(UIColor *)color forState:(UIControlState)state;
- (void)setDestructiveButtonTitleColor:(UIColor *)color forState:(UIControlState)state;


- (void)show;
- (void)showFromView:(UIView *)view;

- (void)dismiss;

@end
