//
//  DownloadViewController.m
//  SeesonDownload
//
//  Created by 夏财祥 on 2018/1/3.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadTableViewCell.h"
#import "SessionModel.h"
#import "RainbowProgress.h"
@interface DownloadViewController ()<UITableViewDelegate,UITableViewDataSource,NSURLSessionDownloadDelegate>

@property(nonatomic,strong)NSArray * array;
@property(nonatomic,strong)NSMutableArray * listTask;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSDate * date;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"video" ofType:@"json"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSArray * array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    self.array = array;
    [self UPUI];
    
}

-(void)UPUI
{
    UITableView * tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerNib:[UINib nibWithNibName:@"DownloadTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"wakaka"];
}
#pragma mark - UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"wakaka"];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData * data =[NSData dataWithContentsOfURL:[NSURL URLWithString:self.array[indexPath.row][@"cover"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.image.image = [UIImage imageWithData:data];
        });
    });
    RainbowProgress * rainProgress = [[RainbowProgress alloc]initWithFrame:cell.rainView.bounds];
    [cell.rainView addSubview:rainProgress];
    cell.rainProgress = rainProgress;
    cell.titleLabel.text = self.array[indexPath.row][@"title"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * urlString = self.array[indexPath.row][@"mp4_url"];
    for (int i = 0; i < self.listTask.count; i ++) {
        SessionModel * model = self.listTask[i];
        if ([model.urlString isEqualToString:urlString]) { // 说明下载队列中有这个url了

            if (model.downLoadTask.state == NSURLSessionTaskStateRunning) {
                [model.downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    model.resumeData = resumeData;
                }];
                return; //结束了这次循环 for
            }
            if (model.downLoadTask.state == NSURLSessionTaskStateCompleted) {
                //意味着现在是取消状态
                if (model.resumeData) {
                    model.downLoadTask = [model.session downloadTaskWithResumeData:model.resumeData];
                    [model.downLoadTask resume];
                }
                return;
            }
        }
    }
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"di%ldgeTask",(long)indexPath.row]];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:self.array[indexPath.row][@"mp4_url"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    NSURLSessionDownloadTask * downLoadTask = [session downloadTaskWithRequest:request];
    //添加model 到 数组中
    SessionModel * model = [[SessionModel alloc]initWithSession:session withDownTask:downLoadTask withIndexPath:indexPath withUrlString:self.array[indexPath.row][@"mp4_url"]];
    [self.listTask addObject:model];
    [downLoadTask resume];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - downloadDelegate

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    for (int i = 0 ; i < self.listTask.count; i ++) {
        SessionModel * model = self.listTask[i];
        if (session == model.session) {
            DownloadTableViewCell * cell = [self.tableView cellForRowAtIndexPath:model.indexPath];
            cell.rainProgress.progressValue = 1.0 *totalBytesWritten /totalBytesExpectedToWrite;
            cell.totalLabel.text = [NSString stringWithFormat:@"%.1fM",(double)totalBytesExpectedToWrite/(1024 *1024)];
            cell.currentLabel.text = [NSString stringWithFormat:@"%.2fM",(double)totalBytesWritten/(1024 * 1024)];
            NSDate * date = [NSDate date];
            if (self.date == nil) {
                self.date = date;
                return;
            }
            NSTimeInterval timeDif = [date timeIntervalSinceDate:self.date];
            self.date = date;
            cell.speedLabel.text = [NSString stringWithFormat:@"%.3fKB/s",(double)bytesWritten/( timeDif * 1024)];
        }
    }
}
//这个方法是当下载完成了开始运行  但是他怎么判断已经下载完成了????
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString * str = nil;
    for (int i = 0; i < self.listTask.count; i ++) {
        SessionModel * model = self.listTask[i];
        if (session == model.session) {
            str = model.identifier;
        }
    }
    NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingString:[NSString stringWithFormat:@"/%@.mp4",str]];
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:stringPath] error:nil];
    NSLog(@"%@",stringPath);
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//    NSLog(@"%@",error.userInfo.allKeys);
}

/**
 懒加载

 @return listarray
 */
-(NSMutableArray *)listTask
{
    if (_listTask == nil) {
        NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:@"listTask.src"];
        _listTask = [NSKeyedUnarchiver unarchiveObjectWithFile:stringPath];
        NSLog(@"初始化结果:%@",_listTask);
        if (_listTask == nil) {
            _listTask = [[NSMutableArray alloc]init];
        }
    }
    return _listTask;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 __block NSURLSessionDownloadTask * downTask = model.downLoadTask;
 if (downTask.state == 3  && model.resumeData != nil) {
 model.downLoadTask = [model.session downloadTaskWithResumeData:model.resumeData];
 downTask = model.downLoadTask;
 }
 NSLog(@"溜了一圈回来就成:%ld",(long)downTask.state);
 //            NSLog(@"%@",[[NSString alloc]initWithData:model.resumeData encoding:NSUTF8StringEncoding]);
 if (downTask.state == NSURLSessionTaskStateRunning) {
 [downTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
 model.resumeData = resumeData;
 downTask = nil;
 model.downLoadTask = [model.session downloadTaskWithResumeData:resumeData];
 }];
 return;
 }
 
 
*/

@end
