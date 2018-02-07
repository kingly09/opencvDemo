//
//  CvVideoCameraViewController.h
//  opencv2Framework
//
//  Created by kingly on 2018/2/7.
//  Copyright © 2018年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

using namespace cv;
using namespace std;

@interface CvVideoCameraViewController : UIViewController <CvVideoCameraDelegate>

@property CvVideoCamera *videoCamera;

@end
