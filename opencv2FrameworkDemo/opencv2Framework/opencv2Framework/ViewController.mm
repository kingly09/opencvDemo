//
//  ViewController.m
//  opencv2Framework
//
//  Created by kingly on 2018/2/2.
//  Copyright © 2018年 kingly. All rights reserved.
//

#import "ViewController.h"

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>

#import "HaartrainingViewController.h"


@interface ViewController ()
{
  cv::Mat cvImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *originalPicture;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;


@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  self.view.backgroundColor = [UIColor blackColor];
  
  //Canny边缘检测算法的实现
  [self setupMatToUIImage];
  
}

- (IBAction)onClickSelectFunction:(id)sender {
  
  UIAlertAction *haarAction = [UIAlertAction actionWithTitle:@"使用Haar特征分类器" style:UIAlertActionStyleDefault handler:^(UIAlertAction *haarAct){
    
    [self haartraining];
    
  }];

  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *cancelAct){}];
  UIAlertController *alerCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  [alerCtr addAction:haarAction];
  [alerCtr addAction:cancel];
  [self presentViewController:alerCtr animated:YES completion:^{}];
  

}

/**
 在OpenCV中使用Haar特征分类器来对图像中的人脸进行检测和识别
 */
-(void)haartraining {
  
  HaartrainingViewController *haartrainingVC = [[HaartrainingViewController alloc] init];
  [self.navigationController pushViewController:haartrainingVC animated:YES];
  
}

/**
 Canny边缘检测算法的实现
 */
-(void)setupMatToUIImage {
  
  
  UIImage *image = [UIImage imageNamed:@"learn.jpg"];
  UIImageToMat(image, cvImage);
  
  if(!cvImage.empty()){
    
    cv::Mat gray;
    // 将图像转换为灰度显示
    cv::cvtColor(cvImage,gray,CV_RGB2GRAY);
    // 应用高斯滤波器去除小的边缘
    cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2,1.2);
    // 计算与画布边缘
    cv::Mat edges; cv::Canny(gray, edges, 0, 50);
    // 使用白色填充
    cvImage.setTo(cv::Scalar::all(225));
    // 修改边缘颜色
    cvImage.setTo(cv::Scalar(0,128,255,255),edges);
    // 将Mat转换为Xcode的UIImageView显示
    self.imgView.image = MatToUIImage(cvImage);
    
  }
  
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


/**
 UIImage to cv::Mat
 */
-(cv::Mat )cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
  
  cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
  
  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                  cols,                       // Width of bitmap
                                                  rows,                       // Height of bitmap
                                                  8,                          // Bits per component
                                                  cvMat.step[0],              // Bytes per row
                                                  colorSpace,                 // Colorspace
                                                  kCGImageAlphaNoneSkipLast |
                                                  kCGBitmapByteOrderDefault); // Bitmap info flags
  
  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);
  
  return cvMat;
}


/**
 cv::Mat to UIImage
 
 */
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
  NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
  CGColorSpaceRef colorSpace;
  
  if (cvMat.elemSize() == 1) {//可以根据这个决定使用哪种
    colorSpace = CGColorSpaceCreateDeviceGray();
  } else {
    colorSpace = CGColorSpaceCreateDeviceRGB();
  }
  
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  
  // Creating CGImage from cv::Mat
  CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                      cvMat.rows,                                 //height
                                      8,                                          //bits per component
                                      8 * cvMat.elemSize(),                       //bits per pixel
                                      cvMat.step[0],                            //bytesPerRow
                                      colorSpace,                                 //colorspace
                                      kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                      provider,                                   //CGDataProviderRef
                                      NULL,                                       //decode
                                      false,                                      //should interpolate
                                      kCGRenderingIntentDefault                   //intent
                                      );
  
  
  // Getting UIImage from CGImage
  UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  
  return finalImage;
}




@end
