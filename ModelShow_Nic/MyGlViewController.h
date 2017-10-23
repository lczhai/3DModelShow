//
//  MyGlViewController.h
//  ModelShow_Nic
//
//  Created by shining3d on 16/1/20.
//  Copyright © 2016年 shining3d. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES1/gl.h>
#import "SVProgressHUD.h"
#import "ZLCObjeparser.h"
#import "ZLCStlparser.h"


@interface MyGlViewController : GLKViewController<UIGestureRecognizerDelegate>


@property NSString *curFileName;


@property NSArray  *modelList;


@end
