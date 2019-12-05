//
//  ViewController.m
//  videoCaptureManager
//
//  Created by sunmingzhe
//  Copyright © 2019 sunmingzhe. All rights reserved.
//

#import "ViewController.h"
#import "videoCaptureManager.h"
@interface ViewController ()<CaptureDataOutputProtocol>
@property (nonatomic, readwrite, retain) videoCaptureManager *videoCapture;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoLayer;


@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self startCamera];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.videoCapture stopSession];
}
#pragma mark -初始化相机
- (void)startCamera {
    self.videoCapture = [[videoCaptureManager alloc] init];
    self.videoCapture.delegate = self;
    self.videoCapture.runningStatus = YES;
    [self.videoCapture startSession];
    self.videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self.videoCapture returnSession]];
    self.view.layer.masksToBounds = YES;
    self.videoLayer.frame = self.view.bounds;
    //    self.videoLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:self.videoLayer];
}

- (void)captureOutputImage:(UIImage *)image {
    //可以对Image做操作
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
    //对UI刷新的操作，比如人脸画框功能等
    //weakself .....
    });
}
- (void)captureOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    //对数据流进行操作，可以自己转换成自己需要的数据
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
    //weakself .....
    //对UI刷新的操作，比如人脸画框功能等

    });
}

@end
