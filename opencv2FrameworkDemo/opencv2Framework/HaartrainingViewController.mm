//
//  HaartrainingViewController.m
//  opencv2Framework
//
//  Created by kingly on 2018/2/6.
//  Copyright © 2018年 kingly. All rights reserved.
//

#import "HaartrainingViewController.h"

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/objdetect/objdetect.hpp>

@interface HaartrainingViewController () {
  
  UIImageView *imageView;
  UIImageView *imageView02;
}

@end

@implementation HaartrainingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"使用Haar特征分类器";
    self.view.backgroundColor = [UIColor whiteColor];
  
   imageView = [[UIImageView alloc] init];
   imageView.frame = CGRectMake(20,80,self.view.frame.size.width - 40,300);
   imageView.image = [UIImage imageNamed:@"learn03.jpg"];
   imageView.contentMode =  UIViewContentModeScaleAspectFill;
   [self.view addSubview:imageView];
  
  
  imageView02 = [[UIImageView alloc] init];
  imageView02.frame = CGRectMake(20,imageView.frame.origin.y + imageView.frame.size.height + 10,self.view.frame.size.width - 40,300);
  imageView02.image = [UIImage imageNamed:@"learn03.jpg"];
  imageView02.contentMode =  UIViewContentModeScaleAspectFill;
  [self.view addSubview:imageView02];
  
  
  [self opencvFaceDetect:[UIImage imageNamed:@"learn04.jpg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)opencvEdgeDetect
{
 
  if(imageView02.image) {
    cvSetErrMode(CV_ErrModeParent);
    
    // Create grayscale IplImage from UIImage
    IplImage *img_color = [self CreateIplImageFromUIImage:imageView.image];
    IplImage *img = cvCreateImage(cvGetSize(img_color), IPL_DEPTH_8U, 1);
    cvCvtColor(img_color, img, CV_BGR2GRAY);
    cvReleaseImage(&img_color);
    
    // Detect edge
    IplImage *img2 = cvCreateImage(cvGetSize(img), IPL_DEPTH_8U, 1);
    cvCanny(img, img2, 64, 128, 3);
    cvReleaseImage(&img);
    
    // Convert black and whilte to 24bit image then convert to UIImage to show
    IplImage *image = cvCreateImage(cvGetSize(img2), IPL_DEPTH_8U, 3);
    for(int y=0; y<img2->height; y++) {
      for(int x=0; x<img2->width; x++) {
        char *p = image->imageData + y * image->widthStep + x * 3;
        *p = *(p+1) = *(p+2) = img2->imageData[y * img2->widthStep + x];
      }
    }
    cvReleaseImage(&img2);
    imageView02.image = [self UIImageFromIplImage:image];
    cvReleaseImage(&image);
    
  
  }
  
  
}



- (void) opencvFaceDetect:(UIImage *)overlayImage  {
  
  if(imageView.image) {
    cvSetErrMode(CV_ErrModeParent);
    
    IplImage *image = [self CreateIplImageFromUIImage:imageView.image];
    
    // Scaling down
    IplImage *small_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3);
    cvPyrDown(image, small_image, CV_GAUSSIAN_5x5);
    int scale = 2;
    
    // Load XML
    NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
    CvHaarClassifierCascade* cascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
    CvMemStorage* storage = cvCreateMemStorage(0);
    
    // Detect faces and draw rectangle on them
    CvSeq* faces = cvHaarDetectObjects(small_image, cascade, storage, 1.2f, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(0,0), cvSize(20, 20));
    cvReleaseImage(&small_image);
    
    // Create canvas to show the results
    CGImageRef imageRef = imageView.image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(NULL, imageView.image.size.width, imageView.image.size.height,
                                                    8, imageView.image.size.width * 4,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height), imageRef);
    
    CGContextSetLineWidth(contextRef, 4);
    CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 1.0, 0.5);
    
    // Draw results on the iamge
    for(int i = 0; i < faces->total; i++) {
     
      // Calc the rect of faces
      CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, i);
      CGRect face_rect = CGContextConvertRectToDeviceSpace(contextRef, CGRectMake(cvrect.x * scale, cvrect.y * scale, cvrect.width * scale, cvrect.height * scale));
      
      if(overlayImage) {
        CGContextDrawImage(contextRef, face_rect, overlayImage.CGImage);
      } else {
        CGContextStrokeRect(contextRef, face_rect);
      }

    }
    
    imageView.image = [UIImage imageWithCGImage:CGBitmapContextCreateImage(contextRef)];
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    cvReleaseMemStorage(&storage);
    cvReleaseHaarClassifierCascade(&cascade);
    
   
  }
  
}


// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
  CGImageRef imageRef = image.CGImage;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
  CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
                                                  iplimage->depth, iplimage->widthStep,
                                                  colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
  CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
  CGContextRelease(contextRef);
  CGColorSpaceRelease(colorSpace);
  
  IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
  cvCvtColor(iplimage, ret, CV_RGBA2BGR);
  cvReleaseImage(&iplimage);
  
  return ret;
}

// NOTE You should convert color mode as RGB before passing to this function
- (UIImage *)UIImageFromIplImage:(IplImage *)image {
  NSLog(@"IplImage (%d, %d) %d bits by %d channels, %d bytes/row %s", image->width, image->height, image->depth, image->nChannels, image->widthStep, image->channelSeq);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
  CGImageRef imageRef = CGImageCreate(image->width, image->height,
                                      image->depth, image->depth * image->nChannels, image->widthStep,
                                      colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                      provider, NULL, false, kCGRenderingIntentDefault);
  UIImage *ret = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  return ret;
}


@end
