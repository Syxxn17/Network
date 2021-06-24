//
//  ViewController.m
//  Network
//
//  Created by YuSiyuan on 2021/6/24.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getRequest];
}

- (void)getRequest
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict = @{
        @"username":@"sy",
        @"pwd":@"123"
    };
    [manager GET:@"https://www.baidu.com/" parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // task:可以通过task拿到响应头
            //responseObject:请求成功返回的响应结果（AFN内部已经把响应体转换为OC对象，通常是字典或数组)
            NSLog(@"responseObject---%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error---%@", error);
        }];
}

@end
