//
//  TLDrawViewController.m
//  TouchTracker
//
//  Created by lushuishasha on 2016/12/13.
//  Copyright © 2016年 lushuishasha. All rights reserved.
//

#import "TLDrawViewController.h"
#import "TLDrawView.h"

@interface TLDrawViewController ()

@end

@implementation TLDrawViewController
- (void)loadView
{
    self.view = [[TLDrawView alloc]initWithFrame:CGRectZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
@end
