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
    GKActionSheetItem *item1 = [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_QQ"] title:@"QQ" handler:^(GKActionSheetItem *item) {
        NSLog(@"点击了：%@", item.title);
    }];
    GKActionSheetItem *item2 = [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_WeChat"] title:@"微信" handler:^(GKActionSheetItem *item) {
        NSLog(@"点击了：%@", item.title);
    }];
    GKActionSheetItem *item3 = [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_WeChat_Moments"] title:@"朋友圈" handler:^(GKActionSheetItem *item) {
        NSLog(@"点击了：%@", item.title);
    }];
    GKActionSheetItem *item4 = [[GKActionSheetItem alloc] initWithImage:[UIImage imageNamed:@"Share_Sina"] title:@"微博" handler:^(GKActionSheetItem *item) {
        NSLog(@"点击了：%@", item.title);
    }];
    GKActionSheet *actionSheet = [[GKActionSheet alloc] initWithTitle:@"请选择您的操作" items:@[item1, item2, item3, item4, item1, item2, item3, item4, item1, item2, item3, item4, item1, item2, item3, item4] cancelButtonTitle:@"取消"];
    [actionSheet show];
}

@end
