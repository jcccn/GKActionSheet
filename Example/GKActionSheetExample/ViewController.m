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
    GKActionSheet *actionSheet = [[GKActionSheet alloc] initWithTitle:@"请选择您的操作" items:nil cancelButtonTitle:@"取消"];
    [actionSheet show];
}

@end
