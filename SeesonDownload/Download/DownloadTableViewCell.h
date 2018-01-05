//
//  DownloadTableViewCell.h
//  SeesonDownload
//
//  Created by 夏财祥 on 2018/1/3.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RainbowProgress.h"
@interface DownloadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (weak, nonatomic) IBOutlet UIView *rainView;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) RainbowProgress *rainProgress;

@end
