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

@interface GKActionSheetItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, copy) GKActionSheetItemHandler handler;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title handler:(GKActionSheetItemHandler)handler;

@end

#pragma mark -

@interface GKActionSheet : UIView

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items cancelButtonTitle:(NSString *)cancelButtonTitle;

- (void)addItem:(GKActionSheetItem *)item;

- (void)show;
- (void)showFromView:(UIView *)view;

- (void)dismiss;

@end
