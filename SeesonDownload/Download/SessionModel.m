//
//  SessionModel.m
//  SeesonDownload
//
//  Created by 夏财祥 on 2018/1/4.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import "SessionModel.h"

@implementation SessionModel


-(instancetype)initWithSession:(NSURLSession *)session withDownTask:(NSURLSessionDownloadTask *)downTask withIndexPath:(NSIndexPath *)indexPath withUrlString:(NSString *)string
{
    if (self = [super init]) {
        self.session = session;
        self.downLoadTask = downTask;
        self.indexPath = indexPath;
        self.urlString = string;
    }
    return self;
}
//归档
//对 对象中想要归档的所有属性,进行序列化操作
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_session forKey:@"session"];
    [aCoder encodeObject:_indexPath forKey:@"inde"];
    [aCoder encodeObject:_urlString forKey:@"url"];
    [aCoder encodeObject:_resumeData forKey:@"resum"];
    [aCoder encodeObject:_identifier forKey:@"identifier"];
}
//反序列化 得到一个对象,所有属性都是通过反序列化得到
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        self.session = [aDecoder decodeObjectForKey:@"session"];
        self.indexPath = [aDecoder decodeObjectForKey:@"inde"];
        self.urlString = [aDecoder decodeObjectForKey:@"url"];
        self.resumeData = [aDecoder decodeObjectForKey:@"resum"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    }
    return self;
}

@end
