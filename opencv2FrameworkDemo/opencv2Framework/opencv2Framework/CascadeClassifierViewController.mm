//
//  CascadeClassifierViewController.m
//  opencv2Framework
//
//  Created by kingly on 2018/2/10.
//  Copyright © 2018年 kingly. All rights reserved.
//

#import "CascadeClassifierViewController.h"

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/highgui.hpp>

@interface CascadeClassifierViewController () <CvVideoCameraDelegate> {
  

  std::vector<cv::Rect> _faceRects;
  
  BOOL isLoadFace;
  BOOL isLoadEye;
  BOOL isLoadNose;
  BOOL isLoadMouth;
  
  int flag;  //标记  1为人脸 2为人眼 3为鼻子 4为嘴巴
  
}
@property (strong, nonatomic)  UIImageView *theImageView;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic) cv::CascadeClassifier theClassifier;       //人脸分类器
@property (nonatomic) cv::CascadeClassifier theClassifierEye;    //人眼分类器
@property (nonatomic) cv::CascadeClassifier theClassifierNose;   //鼻子分类器
@property (nonatomic) cv::CascadeClassifier theClassifierMouth;   //嘴巴分类器

@end

@implementation CascadeClassifierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.title = @"使用CascadeClassifier检测人脸";
  self.view.backgroundColor = [UIColor whiteColor];
  
  _theImageView = [[UIImageView alloc] init];
  _theImageView.frame = CGRectMake(30,80,self.view.frame.size.width - 60 ,200);
  _theImageView.contentMode =  UIViewContentModeScaleAspectFill;
  [self.view addSubview:_theImageView];
  
}


- (void)viewDidAppear:(BOOL)animated{
  
  [self loadClassifier];
  [self startCamera];
  
}



-(void)loadClassifier{
  
  //加载人脸分类器
  [self loadFaceHaar];
  //加载人眼分类器
  [self loadEye];
  //加载鼻子分类器
  [self loadNose];
  //加载嘴巴分类器
  [self loadMouth];
  
}


-(void)loadFaceHaar {
  
  NSString* pathToModel = [[NSBundle mainBundle] pathForResource:@"xl_haarcascade_frontalface_alt2" ofType:@"xml"];
  const CFIndex CASCADE_NAME_LEN = 2048;
  char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
  CFStringGetFileSystemRepresentation( (CFStringRef)pathToModel, CASCADE_NAME, CASCADE_NAME_LEN);
  isLoadFace = _theClassifier.load(CASCADE_NAME);
  free(CASCADE_NAME);
  
}

-(void)loadEye {
  
  NSString* pathToModel = [[NSBundle mainBundle] pathForResource:@"xl_haarcascade_eye" ofType:@"xml"];
  const CFIndex CASCADE_NAME_LEN = 2048;
  char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
  CFStringGetFileSystemRepresentation( (CFStringRef)pathToModel, CASCADE_NAME, CASCADE_NAME_LEN);
  isLoadEye = _theClassifierEye.load(CASCADE_NAME);
  free(CASCADE_NAME);
  
}

-(void)loadNose {
  
  NSString* pathToModel = [[NSBundle mainBundle] pathForResource:@"xl_haarcascade_mcs_nose" ofType:@"xml"];
  const CFIndex CASCADE_NAME_LEN = 2048;
  char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
  CFStringGetFileSystemRepresentation( (CFStringRef)pathToModel, CASCADE_NAME, CASCADE_NAME_LEN);
  isLoadNose = _theClassifierNose.load(CASCADE_NAME);
  free(CASCADE_NAME);
  
}

-(void)loadMouth {
  
  NSString* pathToModel = [[NSBundle mainBundle] pathForResource:@"xl_haarcascade_mcs_mouth" ofType:@"xml"];
  const CFIndex CASCADE_NAME_LEN = 2048;
  char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
  CFStringGetFileSystemRepresentation( (CFStringRef)pathToModel, CASCADE_NAME, CASCADE_NAME_LEN);
  isLoadMouth = _theClassifierMouth.load(CASCADE_NAME);
  free(CASCADE_NAME);
  
}


-(void)startCamera {
  
  self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.view];
  
  self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
  self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
  self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
  self.videoCamera.defaultFPS = 30;
  self.videoCamera.grayscaleMode = NO;
  self.videoCamera.delegate = self;
  [self.videoCamera start];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image {
  
//  if (loadFace == NO) {
//    NSLog(@"加载人脸分类器失败");
//    return;
//  }
//
//  if (loadEye == NO) {
//    NSLog(@"加载人眼分类器失败");
//    return;
//  }
//
//  if (loadNose == NO) {
//    NSLog(@"加载鼻子分类器失败");
//    return;
//  }
//  if (loadMouth == NO) {
//    NSLog(@"加载嘴巴分类器失败");
//    return;
//  }
  
  [self cascadeTest:image];
}


- (void)cascadeTest:(cv::Mat&)image {
  
  
  std::vector<cv::Rect> faceRects;
  
  double scalingFactor = 1.1;
  int minNeighbors = 20;
  int flags = 0;
  int theMinSize = 32;
  int theMaxSize = 480;
  
  cv::Size minimumSize(theMinSize,theMinSize);
  cv::Size maximumSize(theMaxSize,theMaxSize);
  
   // 人脸识别与标记
  if (isLoadFace) {
    
    _theClassifier.detectMultiScale(image, faceRects, scalingFactor, minNeighbors, flags, minimumSize, maximumSize );
    
    for( std::vector<cv::Rect>::const_iterator r = faceRects.begin(); r != faceRects.end(); r++)
    {

      //This is one of the rectangles returned as a hit by the classifier.
      cv::Rect theHit(r->x,r->y,r->width,r->height);
      
      bool saveHits = false;  //Set to true to capture hits as files to sort and use for samples in training.
      
      if (saveHits)
      {
        cv::Mat HitMat = image(theHit);
        [self writeMatToFile:HitMat withFolderName:@"theHits"];
      }
      
      //Draw a rectangle around the hit on the image before sending it on to be displaed by the image view.
      cv::rectangle( image, cvPoint( r->x , r->y), cvPoint( r->x + r->width, r->y + r->height), cv::Scalar(0,255,0),2);
      
      flag = 1;
    }
  }else{
    NSLog(@"加载人脸分类器失败");
  }
  // 人眼识别与标记
  if (isLoadEye == YES) {
    
    if(flag == 1){
      
      _theClassifierEye.detectMultiScale(image, faceRects, scalingFactor, minNeighbors, flags, minimumSize, maximumSize );
      for( std::vector<cv::Rect>::const_iterator r = faceRects.begin(); r != faceRects.end(); r++){
        
        cv::rectangle( image, cvPoint( r->x , r->y), cvPoint( r->x + r->width, r->y + r->height), cv::Scalar(193,0,0),1);
        flag = 2;
      }
    }
  }else{
    NSLog(@"加载人眼分类器失败");
  }
  
  // 鼻子识别与标记
  if (isLoadNose == YES) {
    
    if(flag == 2){
      
      _theClassifierNose.detectMultiScale(image, faceRects, scalingFactor, minNeighbors, flags, minimumSize, maximumSize );
      for( std::vector<cv::Rect>::const_iterator r = faceRects.begin(); r != faceRects.end(); r++){
        
        cv::rectangle( image, cvPoint( r->x , r->y), cvPoint( r->x + r->width, r->y + r->height), cv::Scalar(0,0,39),1);
        flag = 3;
      }
    }
  }else{
    NSLog(@"加载鼻子分类器失败");
  }
  
  // 嘴巴识别与标记
  if (isLoadMouth == YES) {
    
    if(flag == 3){
      
      _theClassifierMouth.detectMultiScale(image, faceRects, scalingFactor, minNeighbors, flags, minimumSize, maximumSize );
      for( std::vector<cv::Rect>::const_iterator r = faceRects.begin(); r != faceRects.end(); r++){
        
        cv::rectangle( image, cvPoint( r->x , r->y), cvPoint( r->x + r->width, r->y + r->height), cv::Scalar(254,0,255),1);
        flag = 4;
      }
    }
  }else{
    NSLog(@"加载嘴巴分类器失败");
  }
  
}


-(void)writeMatToFile:(cv::Mat&)image withFolderName:(NSString*)theFolderName {
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docs = [paths objectAtIndex:0];
  NSString *unclassFolderPath = [docs stringByAppendingPathComponent:theFolderName];
  [[[NSFileManager alloc] init] createDirectoryAtPath:unclassFolderPath withIntermediateDirectories: YES attributes:nil error:nil];
  NSTimeInterval theMark = [[NSDate date] timeIntervalSince1970];
  NSString *theFileName = [NSString stringWithFormat:@"%f.jpg",theMark];
  NSString *vocabPath = [unclassFolderPath stringByAppendingPathComponent:theFileName];
  
  NSLog(@"vocabPath::%@",vocabPath);
  
  cv::String FullPath = [vocabPath UTF8String];
  cv::imwrite(FullPath, image);
  
}



@end
