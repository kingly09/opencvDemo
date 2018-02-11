//
//  CvVideoCameraViewController.m
//  opencv2Framework
//
//  Created by kingly on 2018/2/7.
//  Copyright © 2018年 kingly. All rights reserved.
//

#import "CvVideoCameraViewController.h"
#import <mach/mach_time.h>

@interface CvVideoCameraViewController ()

@property (readwrite, nonatomic)  UIImageView *imageView;

@end

@implementation CvVideoCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.title = @"对获取的实时图像进行处理";
  
  self.imageView = [[UIImageView alloc] init];
  self.imageView.frame = CGRectMake(20,80,self.view.frame.size.width - 40,300);
  self.imageView.contentMode =  UIViewContentModeScaleAspectFill;
  [self.view addSubview:self.imageView];
  
  
  self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
  self.videoCamera.delegate = self;
  self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;//调用摄像头前置或者后置
  self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;//设置图像分辨率
  self.videoCamera.rotateVideo=YES;// 解决图像显示旋转90°问题
  
  self.videoCamera.grayscaleMode = NO;//获取图像是灰度还是彩色图像
  
  self.videoCamera.defaultFPS = 30;//摄像头频率
  [self.videoCamera start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CvVideoCameraDelegate

-(void)processImage:(cv::Mat &)image {
  
  //添加自己的图像处理算法
  
  if (!image.empty()) {
    
    if(image.channels()==4)
    {        cv::Mat gray;
      cv::cvtColor(image, gray, CV_BGRA2GRAY);
      cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2, 1.2);
      cv::Mat edges;
      cv::Canny(gray, edges, 0, 60);
      image.setTo(cv::Scalar::all(255));
      image.setTo(cv::Scalar(0,128,255,255), edges);
      self.imageView.image = MatToUIImage(image);
      
    }else if(image.channels()==3)
    {
      cv::Mat gray;
      cv::cvtColor(image, gray, CV_RGB2GRAY);
      cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2, 1.2);
      cv::Mat edges;
      cv::Canny(gray, edges, 0, 60);
      image.setTo(cv::Scalar::all(255));
      image.setTo(cv::Scalar(0,128,255,255), edges);
      self.imageView.image = MatToUIImage(image);
    }
    else if(image.channels()==1){
      cv::Mat gray;
      
      cv::GaussianBlur(image, gray, cv::Size(5,5), 1.2, 1.2);
      cv::Mat edges;
      cv::Canny(gray, edges, 0, 60);
      image.setTo(cv::Scalar::all(255));
      image.setTo(cv::Scalar(0,128,255,255), edges);
      self.imageView.image = MatToUIImage(image);
    }
    else{
      
    }
  }
}




@end
