//
//  ViewController.h
//  SeesonDownload
//
//  Created by 夏财祥 on 2018/1/3.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RainbowProgress.h"
@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *rainbowView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalByte;

@end

