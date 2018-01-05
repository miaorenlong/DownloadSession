//
//  ViewController.m
//  SeesonDownload
//
//  Created by 夏财祥 on 2018/1/3.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<NSURLSessionDownloadDelegate>
@property(nonatomic,strong)AVPlayer *avplayer;
@property(nonatomic,strong)NSURLSessionDownloadTask * downLoadTask;
@property(nonatomic,strong)RainbowProgress * rainbowProgress;
@property(nonatomic,strong)NSData * resumeData;
@property(nonatomic,strong)NSURLSession * session;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject]);
//    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"json"];
    NSData * data = [[NSData alloc]initWithContentsOfFile:path];
    
    NSArray * array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSDictionary * dict = array[0];
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.session = session;
  
    NSURLSessionDownloadTask * downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:dict[@"mp4_url"]]];
    NSLog(@"刚初始化:%ld %@",(long)downloadTask.state,downloadTask);
    self.downLoadTask = downloadTask;
    

}
#pragma mark - session Delegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (self.totalByte == nil || [self.totalByte.text doubleValue] != totalBytesExpectedToWrite) {
        self.totalByte.text = [NSString stringWithFormat:@"%.2fM",(double)totalBytesExpectedToWrite/(1024 * 1024)];
    }
    //bytesWritten 每秒下载的速度
    if (self.rainbowProgress) {
        self.speedLabel.text = [NSString stringWithFormat:@"%fkb/s",(double)bytesWritten/1024];
        self.rainbowProgress.progressValue = 1.0 *totalBytesWritten/totalBytesExpectedToWrite;
    }

}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString * fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"1.mp4"];
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
}

- (IBAction)resumeButtonClick:(UIButton *)sender {
    RainbowProgress * progress = [[RainbowProgress alloc]initWithFrame:self.rainbowView.bounds];
    [self.rainbowView addSubview:progress];
    self.rainbowProgress = progress;
    //启动
    [self.downLoadTask resume];
    NSLog(@"开始启动后:%ld %@",(long)self.downLoadTask.state,self.downLoadTask);
    [self.rainbowProgress startAnimating];
}

- (IBAction)stopButtonClick:(UIButton *)sender {
    [self.downLoadTask suspend];
    NSLog(@"暂停后:%ld %@",(long)self.downLoadTask.state,self.downLoadTask);
}
- (IBAction)huifuButtonClick:(UIButton *)sender {
    //如果是cancel 也就是downloadtask取消 ,如果要重新下载,就需要重建downloadtask.与此同时,需要从之前已经下载的部分末尾开始下载
    NSURLSessionDownloadTask * downLoadTask = [self.session downloadTaskWithResumeData:self.resumeData];
    NSLog(@"恢复后:%ld %@",(long)self.downLoadTask.state,downLoadTask);
    [downLoadTask resume];
    self.downLoadTask = downLoadTask;
}
- (IBAction)cancelButtonClick:(UIButton *)sender {
//    [self.downLoadTask cancel];
    if (self.downLoadTask) {
        [self.downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            self.resumeData = resumeData;
            NSLog(@"取消后:%ld %@",(long)self.downLoadTask.state,self.downLoadTask);
        }];
    }
}


#pragma mark - block
-(void)sessionBlockDownload
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"json"];
    NSData * data = [[NSData alloc]initWithContentsOfFile:path];
    
    NSArray * array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    //获取沙盒路径
    NSString * pathDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSLog(@"%@",pathDocument);
    NSDictionary * dict = array[0];
    NSURLSession * session = [NSURLSession sharedSession];
 
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dict[@"mp4_url"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1];
    NSURLSessionDownloadTask * dataLoad = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString * fullPath = [pathDocument stringByAppendingPathComponent:@"2.mp4"];
        [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
        NSLog(@"%@",[NSThread currentThread]);
        
    }];
    [dataLoad resume];
    
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"%@",error);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
