//
//  CascadeClassifierViewController.h
//  opencv2Framework
//
//  Created by kingly on 2018/2/10.
//  Copyright © 2018年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 使用CascadeClassifier检测人脸
 */

/**
 *
 1.分别用facedetect功能将两张图片中的人脸检测出来
 2.将人脸部分的图片剪切出来，存到两张只有人脸的图片里。
 3.这两张人脸图片转换成单通道的图像
 4.使用直方图比较这两张单通道的人脸图像，得出相似度。
 *
 **/
@interface CascadeClassifierViewController : UIViewController

@end
