//
//  videoCaptureManager.h
//  videoCaptureManager
//
//  Created by sunmingzhe 
//  Copyright © 2019 sunmingzhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol CaptureDataOutputProtocol;

@interface videoCaptureManager : NSObject
@property (nonatomic, readwrite, weak) id<CaptureDataOutputProtocol> delegate;

@property (nonatomic, readwrite, assign) BOOL runningStatus;

/**
 * 设定使用前置摄像头或者后置摄像头
 * AVCaptureDevicePositionFront 前置摄像头(默认)
 * AVCaptureDevicePositionBack 后置摄像头
 */
@property (nonatomic, readwrite, assign) AVCaptureDevicePosition position;

- (void)startSession;

- (void)stopSession;

- (void)resetSession;

- (AVCaptureSession *)returnSession;

@end

@protocol CaptureDataOutputProtocol <NSObject>

/**
 * 回调每一个分帧的image
 */

- (void)captureOutputImage:(UIImage *)image;

- (void)captureOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)captureError;

@end
