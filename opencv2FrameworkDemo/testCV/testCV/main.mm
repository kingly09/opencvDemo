//
//  main.m
//  testCV
//
//  Created by kingly on 2018/2/5.
//  Copyright © 2018年 kingly. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <opencv2/opencv.hpp>

int main(int argc, const char * argv[]) {
  
  
  IplImage* img = cvLoadImage( argv[1] );
  cvNamedWindow("Example1", CV_WINDOW_AUTOSIZE );
  cvShowImage("Example1", img );
  cvWaitKey(0);
  cvReleaseImage( &img );
  cvDestroyWindow("Example1");
  
  @autoreleasepool {
      // insert code here...
    NSLog(@"Hello, World!");
    std::cout << "Hello, World!\n";
    
  }
  return 0;
}
