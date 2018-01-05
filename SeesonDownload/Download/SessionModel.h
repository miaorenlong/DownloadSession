//
//  SessionModel.h
//  SeesonDownload
//
//  Created by 夏财祥 on 2018/1/4.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionModel : NSObject<NSCopying>

@property(nonatomic,strong)NSURLSession * session;
@property (nonatomic, strong) NSURLSessionDownloadTask * downLoadTask;
@property(nonatomic,strong)NSIndexPath * indexPath;
@property (nonatomic, strong) NSData * resumeData;
@property (nonatomic, copy) NSString * urlString;
@property(nonatomic,copy)NSString * identifier;

-(instancetype)initWithSession:(NSURLSession *)session withDownTask:(NSURLSessionDownloadTask *)downTask withIndexPath:(NSIndexPath *)indexPath withUrlString:(NSString * )string;

@end
