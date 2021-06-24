//
//  ViewController.m
//  Network
//
//  Created by YuSiyuan on 2021/6/24.
//

#import "ViewController.h"

#define FileName @"rl.pdf"
#define FileLength @"sy.xx"

@interface ViewController () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSOutputStream *stream;
@property (nonatomic, assign) NSInteger totalLength;
@property (nonatomic, assign) NSInteger currentLength;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:FileLength];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if (dict) {
        self.progressView.progress = 1.0 * [self getCurrent]/[dict[FileLength] integerValue];
    }
    NSLog(@"%@",dict);
}

- (NSURLSessionDataTask *)dataTask
{
    if (_dataTask == nil) {
        self.currentLength = [self getCurrent];
        NSURL *url = [NSURL URLWithString:@"https://web.stanford.edu/class/psych209/Readings/SuttonBartoIPRLBook2ndEd.pdf"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        _dataTask = [self.session dataTaskWithRequest:request];
    }
    return _dataTask;
}
- (NSURLSession *)session
{
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

-(NSInteger )getCurrent
{
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:FileName];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *dict = [manager attributesOfItemAtPath:filePath error:nil];
    return [dict[@"NSFileSize"] integerValue];
}
-(void)saveTotal:(NSInteger )length
{
    NSLog(@"开始存储文件大小");
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:FileLength];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(length) forKey:FileLength];
    [dict writeToFile:filePath atomically:YES];
}

- (IBAction)startBtn:(id)sender {
    [self.dataTask resume];
}
- (IBAction)stopBtn:(id)sender {
    [self.dataTask suspend];
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 拿到文件总大小 获得的是当次请求的数据大小，当我们关闭程序以后重新运行，开下载请求的数据是不同的 ,所以要加上之前已经下载过的内容
    NSLog(@"接收到服务器响应");
    self.totalLength = response.expectedContentLength + self.currentLength;
    // 把文件总大小保存的沙盒 没有必要每次都存储一次,只有当第一次接收到响应，self.currentLength为零时，存储文件总大小就可以了
    if (self.currentLength == 0) {
        [self saveTotal:self.totalLength];
    }
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:FileName];
    NSLog(@"%@",filePath);
    // 创建输出流 如果没有文件会创建文件，YES：会往后面进行追加
    NSOutputStream *stream = [[NSOutputStream alloc]initToFileAtPath:filePath append:YES];
    [stream open];
    self.stream = stream;
    //NSLog(@"didReceiveResponse 接受到服务器响应");
    completionHandler(NSURLSessionResponseAllow);
}
// 接收到服务器返回数据时调用，会调用多次
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    self.currentLength += data.length;
    // 输出流写数据
    [self.stream write:data.bytes maxLength:data.length];
    NSLog(@"%f",1.0 * self.currentLength / self.totalLength);
    self.progressView.progress = 1.0 * self.currentLength / self.totalLength;
    //NSLog(@"didReceiveData 接受到服务器返回数据");
}
// 当请求完成之后调用，如果请求失败error有值
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // 关闭stream
    [self.stream close];
    self.stream = nil;
    NSLog(@"didCompleteWithError 请求完成");
}


@end
