//
//  ViewController.m
//  GKActionSheetExample
//
//  Created by Jiang Chuncheng on 6/7/15.
//  Copyright (c) 2015 SenseForce. All rights reserved.
//

#import "ViewController.h"

#import "GKActionSheet.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *showButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.showButton addTarget:self action:@selector(showButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showButtonClicked:(id)sender {
    GKActionSheetItemHandler handler = ^(GKActionSheetItem *item) {
        NSLog(@"分享到：%@", item.title);
    };
    NSArray *items = @[[[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_QQ"] title:@"QQ" handler:handler],
                      [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_WeChat"] title:@"微信" handler:handler],
                      [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_WeChat_Moments"] title:@"朋友圈" handler:handler],
                      [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_Sina"] title:@"微博" handler:handler],
                      [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_Evernote"] title:@"印象笔记" handler:handler],
                       [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_Pocket"] title:@"Pocket" handler:handler],
                       [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_Copylink"] title:@"复制链接" handler:handler],
                       [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_Email"] title:@"电子邮件" handler:handler],
                       [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_Message"] title:@"信息" handler:handler],
                       [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_Twitter"] title:@"Twitter" handler:handler],
                       [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_Facebook"] title:@"Facebook" handler:handler]
                      ];
    GKActionSheet *actionSheet = [[GKActionSheet alloc] initWithTitle:@"分享这篇文章" items:items cancelButtonTitle:@"取 消"];
    [actionSheet setDestructiveButtonWithTitle:@"收 藏" handler:^(UIButton *button) {
        NSLog(@"已收藏");
    }];
    [actionSheet setDestructiveButtonBackgroundColor:[UIColor colorWithRed:56/255.0f green:187/255.0f blue:73/255.0f alpha:1.0f]
                                            forState:UIControlStateNormal];
    [actionSheet show];
}

@end
