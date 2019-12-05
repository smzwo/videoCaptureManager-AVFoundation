//
//  videoCaptureManager.m
//  videoCaptureManager
//
//  Created by sunmingzhe
//  Copyright © 2019 sunmingzhe. All rights reserved.
//

#import "videoCaptureManager.h"

@interface videoCaptureManager() <AVCaptureVideoDataOutputSampleBufferDelegate>{
    dispatch_queue_t _queue;
}
@property (nonatomic, readwrite, retain) AVCaptureSession *session;
@property (nonatomic, readwrite, retain) AVCaptureDevice *captureDevice;
@property (nonatomic, readwrite, retain) AVCaptureDeviceInput *input;
@property (nonatomic, readwrite, retain) AVCaptureVideoDataOutput *output;
@property (nonatomic, readwrite, assign) BOOL isSessionBegin;
@end

@implementation videoCaptureManager

- (void)setPosition:(AVCaptureDevicePosition)position {
    if (_position ^ position) {
        _position = position;
        if (self.isSessionBegin) {
            [self resetSession];
        }
    }
}

- (instancetype)init {
    if (self = [super init]) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPreset640x480;
        _queue = dispatch_queue_create("myQueue", NULL);
        _isSessionBegin = NO;
        _position = AVCaptureDevicePositionFront;
    }
    return self;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (void)startSession {
    if ([self.session isRunning]) {
        return;
    }
    if (!self.isSessionBegin) {
        self.isSessionBegin = YES;
        // 配置相机设备
        _captureDevice = [self cameraWithPosition:_position];
        // 初始化输入
        NSError *error = nil;
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:_captureDevice error:&error];
        if (error == nil) {
            [_session addInput:_input];
        } else {
            if ([self.delegate respondsToSelector:@selector(captureError)]) {
                [self.delegate captureError];
            }
        }
        // 输出设置
        _output = [[AVCaptureVideoDataOutput alloc] init];
        _output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [_output setSampleBufferDelegate:self queue:_queue];
        [_session addOutput:_output];
        AVCaptureConnection *conn = [_output connectionWithMediaType:AVMediaTypeVideo];
        conn.videoOrientation = AVCaptureVideoOrientationPortrait;
        // 调节摄像头翻转
        [conn setVideoMirrored:YES];
        [self.session startRunning];
    }
}

- (void)stopSession {
    if (![self.session isRunning]) {
        return;
    }
    if(self.isSessionBegin){
        self.isSessionBegin = NO;
        [self.session stopRunning];
        if(nil != self.output){
            [self.session removeInput:self.input];
        }
        if(nil != self.output){
            [self.session removeOutput:self.output];
        }
    }
}

- (void)resetSession {
    [self stopSession];
    [self startSession];
}

- (AVCaptureSession *)returnSession {
    return _session;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (!_runningStatus) {
        return;
    }
    UIImage *sampleImage = [self imageFromSamplePlanerPixelBuffer:sampleBuffer];
    if ([self.delegate respondsToSelector:@selector(captureOutputImage:)] && sampleImage != nil) {
        [self.delegate captureOutputImage:sampleImage];
    }
    if ([self.delegate respondsToSelector:@selector(captureOutputSampleBuffer:)] && sampleImage != nil) {
        [self.delegate captureOutputSampleBuffer:sampleBuffer];
    }
}

- (UIImage *) imageFromSamplePlanerPixelBuffer:(CMSampleBufferRef)sampleBuffer{
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little);
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        UIImage *image = [UIImage imageWithCGImage:quartzImage];
        CGImageRelease(quartzImage);
        return (image);
    }
}

@end


