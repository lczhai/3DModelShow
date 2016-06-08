//
//  MyGlViewController.m
//  ModelShow_Nic
//
//  Created by shining3d on 16/1/20.
//  Copyright © 2016年 shining3d. All rights reserved.
//

#import "MyGlViewController.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;


#define MAX_LINE 1024


//创建于解析方法内结构体内一直的结构体
struct pointInfo
{
    float *squareVertexData;
    int   faceNum;
};


@interface MyGlViewController ()

@property EAGLContext *context;
@property GLKBaseEffect *effect;
@property float rotation;

//@property float *squareVertexData;



@end

@implementation MyGlViewController


{
    
    BOOL isExit;
    CGPoint lastLoc;
    
    
    //--------
    float _curRed;
    BOOL _increasing;
    float _rotation;
    GLKMatrix4 _rotMatrix;
    GLKVector3 _anchor_position;
    GLKVector3 _current_position;
    GLKQuaternion _quatStart;
    GLKQuaternion _quat;
    
    BOOL _slerping;
    float _slerpCur;
    float _slerpMax;
    GLKQuaternion _slerpStart;
    GLKQuaternion _slerpEnd;
    
    
    
    //---------
    
    
    GLKView *glview;
    
    int dataCount;//模型坐标个数
    float *squareVertexData;//定义数组
    int faceNum;//三角片面数
    
    float bigSize;//控制模型大小（1-180）
    float modelX;//模型位置x
    float modelY;//模型位置y
    float modelZ;//模型位置z
    
    CGPoint curTickleStart;//手势触及屏幕开始第一个点
    
    
    NSMutableArray *xPointRecord;//手势触及点得x坐标集合
    NSMutableArray *yPointRecord;//手势触及点得y坐标集合
    
    GLuint buffer;//缓冲
    
    
    
    
    UIView *maskView;//遮罩层
    
    
}

@synthesize context;
@synthesize effect;
@synthesize curFileName;



- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &buffer);
    //glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"模型";
    [SVProgressHUD dismiss];
    [self tearDownGL];
    
    
    
    //------
    _rotMatrix = GLKMatrix4Identity;
    _quat = GLKQuaternionMake(0, 0, 0, 1);
    _quatStart = GLKQuaternionMake(0, 0, 0, 1);
    
    //-------
    
    
    
    
    
    //自定义导航栏返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backButton_OnClick:)];
    //获取当前的当行进程内的所有ViewController
    NSMutableArray *oldViewControllers =[[NSMutableArray alloc]initWithArray: self.navigationController.viewControllers];
    //    [oldViewControllers removeObject:self];
    //判断当前进程中是否已经到达三个ViewController，若为三个则经第二个controller删除并充值导航
    if (oldViewControllers.count == 3) {
        [oldViewControllers removeObjectAtIndex:1];
        
        
        [UIView animateWithDuration:3 animations:^{
            [self.navigationController setViewControllers:[oldViewControllers copy] animated:YES];
        }];
        
    }
    
    
    
    
    glview = [[GLKView alloc]init];//声明glview
    [self setView:glview];//将glview作为glkviewcontroller主视图
    [self modelParser:curFileName];//解析模型文件
    
    
    
    
    maskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    maskView.backgroundColor = [UIColor colorWithRed:131/255.0 green:166/255.0 blue:205/255.0 alpha:1.000];
    [self.view addSubview:maskView];
    
    
    
    
    
    
    
    
    
    if (self.modelList.count > 1) {
        //多段选择视图对象可以接受一个数组作为item
        //创建多段选择视图对象
        UISegmentedControl *seg=[[UISegmentedControl alloc]initWithItems:[self getSegmentControlIndexWithArray:self.modelList]];
        seg.frame = CGRectMake([UIScreen mainScreen].bounds.size.width*0.25, [UIScreen mainScreen].bounds.size.height-50, [UIScreen mainScreen].bounds.size.width/2, 30);
        //设置多段选择视图某段为默认选择状态
        
        for (int i =0 ; i<self.modelList.count; i++) {
            NSString *filepath = self.modelList[i];
            
            
            
            
            if ([filepath isEqualToString:curFileName]) {
                seg.selectedSegmentIndex = i;
                break;
            }
        }
        
        //给多段选择视图一个颜色
        seg.tintColor = [UIColor blueColor];
        [seg addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];//添加事件
        [self.view addSubview:seg];
    }
    
    
    
}

#pragma mark -- 按钮点击事件
- (void)segmentChanged:(UISegmentedControl *)sender
{
    
    maskView.hidden = NO;
    
    
    
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    
    
    [SVProgressHUD show];
    
    
    //GCD执行
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        NSString *modelPath =  self.modelList[selectedSegment];
        NSLog(@"model name:  %@",modelPath);
        //操作2
        NSArray *files = self.modelList;
        
        MyGlViewController *glk = [[MyGlViewController alloc]init];
        glk.curFileName = modelPath;
        glk.modelList = files;
        [self.navigationController pushViewController:glk animated:NO];
    });
    
    
}








#pragma mark  --调用模型处理
- (void)modelParser:(NSString *)cfileName
{
    
    modelX         = 0.0f;//模型位置x
    modelY         = 0.0f;//模型位置y
    modelZ         = -3.0;//模型位置z
    
    bigSize        = 40.0;//控制模型大小（1-180）
    _rotation      = 0.0f;//初始旋转点
    
    [self addGesture];//给视图添加手势
    
    
    
    //    NSLog(@"%@",[[cfileName componentsSeparatedByString:@"."]lastObject]);
    if ([[[cfileName componentsSeparatedByString:@"."]lastObject] caseInsensitiveCompare:@"stl"]  == NSOrderedSame) {
        
        NSLog(@"是stl文件");
        [self renderingSTL:cfileName];
        
        
        
    }
    else
    {
        NSLog(@"是obj文件");
        
        
        [self renderingOBJ:cfileName];
        
    }
    
    
}

#pragma mark --读取stl
- (void)renderingSTL:(NSString *)filePath
{
    //创建于解析方法内结构体内一直的结构体
    struct pointInfo
    {
        float *squareVertexData;
        int   faceNum;
    };
    //取到解析方法返回的NSValue（携带结构体参数）
    NSValue *value   = [ZLCStlparser ParserStlFileWithfilaPath:filePath];
    //定义结构体接受NSValue内的结构体参数
    pointInfo pro ;
    [value getValue:&pro];
    //赋值
    squareVertexData = pro.squareVertexData;
    faceNum          = pro.faceNum;
    
    
    
    
    
    [self renderUI:squareVertexData];
}

#pragma mark --读取OBJ
- (void)renderingOBJ:(NSString*)filaPath
{
    NSLog(@"%@",filaPath);
    
    
    //取到解析方法返回的NSValue（携带结构体参数）
    NSValue *value   = [ZLCObjeparser ParserObjFileWithfilaPath:filaPath];
    
    //定义结构体接受NSValue内的结构体参数
    pointInfo pro ;
    [value getValue:&pro];
    
    //赋值
    squareVertexData = pro.squareVertexData;
    faceNum          = pro.faceNum;
    
    //将值传给opengl进行渲染
    [self renderUI:squareVertexData];
    
}



//4、修改模型视图矩阵
//有两个方法解决这个问题：一是修改原始的顶点数据（Z轴值），使之透视视点；二是通过所谓的“模型视图矩阵”，将正方形“变换”到远一点的位置。

- (void)update
{
    
    
    
    CGSize size                            = self.view.bounds.size;
    float aspect                           = fabs(size.width / size.height);
    GLKMatrix4 projectionMatrix            = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(bigSize), aspect, 1.0f, 10.0f);//GLKMathDegreesToRadians值越大，模型越小(0-180)
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    
    //模型复原
    if (_slerping) {
        
        _slerpCur += self.timeSinceLastUpdate;
        float slerpAmt = _slerpCur / _slerpMax;
        if (slerpAmt > 1.0) {
            slerpAmt = 1.0;
            _slerping = NO;
            
        }
        
        _quat = GLKQuaternionSlerp(_slerpStart, _slerpEnd, slerpAmt);
    }
    
    
    
    
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    modelViewMatrix                        = GLKMatrix4Translate(modelViewMatrix, modelX, modelY, modelZ); //平移
    //modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, _rotMatrix);
    GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(_quat);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotation);
    
    
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    
    
    
    
    
    
    
    
    //    CGSize size                            = self.view.bounds.size;
    //    float aspect                           = fabs(size.width / size.height);
    //    GLKMatrix4 projectionMatrix            = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(bigSize), aspect, 1.0f, 10.0f);//GLKMathDegreesToRadians值越大，模型越小(0-180)
    //
    //
    //
    //    //    GLKQuaternion oooooo = GLKQuaternionMake(0, 10, -10, 0);
    //    // GLKMatrix4 projectionMatrix1  =   GLKMatrix4MakeWithQuaternion(oooooo);
    //
    //
    //    self.effect.transform.projectionMatrix = projectionMatrix;
    //
    //
    //
    //
    //
    //    //    glViewport(150, 200, 20, 20);
    //    GLKMatrix4 modelViewMatrix =  GLKMatrix4MakeLookAt(xiangjiX, xiangjiY, xiangjiZ, 0, 0, 0, 0, 1.0, 1.0);//相机位置    目光所向的位置     相机的朝向（横屏或者竖屏）
    //
    //
    //
    //
    //
    ////        GLKMatrix4 modelViewMatrix             = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, 0.0f);
    //
    //#pragma mark   ---让图片旋转
    //    //    所谓动画，其实就是在“update”中有规律地修改一些Matrix参数，连续刷新时，即产生动画的“错觉”。
    //    //    1、旋转动画
    //    //    代码如下
    //
    //    modelViewMatrix                        = GLKMatrix4Translate(modelViewMatrix, modelX, modelY, modelZ); //平移
    //    modelViewMatrix                        = GLKMatrix4Rotate(modelViewMatrix, _rotation, 0.0f, 0.0f, 1.0f);   //旋转
    //
    //
    //    modelViewMatrix                        = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(_rotationX));
    //    modelViewMatrix                        = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(_rotationZ));
    //    modelViewMatrix                        = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(_rotationY));
    //
    ////    modelViewMatrix = GLKMatrix4Ap GLKMatrix4MakeRotation(_rotationX, 1, 0, 0);
    //
    //    GLKMatrix4 modelViewProjectionMatrix   = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    //    GLint mat                              = glGetUniformLocation(0.0f, "modelViewProjectionMatrix");
    //
    //    glUniformMatrix4fv(mat, 1, GL_FALSE, modelViewProjectionMatrix.m);
    //
    //
    //    self.effect.transform.modelviewMatrix  = modelViewMatrix;
    
    
    
    //遮罩层隐藏
    maskView.hidden = YES;
    
    
    
    
}


#pragma mark --清除颜色缓冲和深度缓冲
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    
    
    glClearColor(131/255.0, 166/255.0, 205/255.0, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, dataCount); //有几行数据，最后一个参数就是多少
    
    
    
    
    //    前两行为渲染前的“清除”操作，清除颜色缓冲区和深度缓冲区中的内容，并且填充淡蓝色背景（默认背景是黑色）。
    //    “prepareToDraw”方法，是让“效果Effect”针对当前“Context”的状态进行一些配置，它始终把“GL_TEXTURE_PROGRAM”状态定位到“Effect”对象的着色器上。此外，如果Effect使用了纹理，它也会修改“GL_TEXTURE_BINDING_2D”。
    //    接下来，用“glDrawArrays”指令，让OpenGL“画出”两个三角形（拼合为一个正方形）。OpenGL会自动从通用顶点属性中取出这些数据、组装、再用“Effect”内置的着色器渲染。
    
    
    
}



#pragma mark   --添加手势
- (void)addGesture
{
    //捏合手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(onPinch:)];
    
    //一指拖拽手势
    UIPanGestureRecognizer *pan     = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPan:)];
    pan.minimumNumberOfTouches      = 1;
    pan.maximumNumberOfTouches      = 1;
    pan.delegate                    = self;
    
    //二指禅
    UIPanGestureRecognizer *pan2    = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPan2:)];
    pan2.minimumNumberOfTouches     = 2;
    pan2.maximumNumberOfTouches     = 2;
    pan2.delegate                   = self;
    [glview addGestureRecognizer:pinch];
    [glview addGestureRecognizer:pan];
    [glview addGestureRecognizer:pan2];
    
    
    
    UITapGestureRecognizer * dtRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    dtRec.numberOfTapsRequired = 2;
    [glview addGestureRecognizer:dtRec];
    
    
}


#pragma mark 实现模型的捏合缩放
- (void)onPinch:(UIPinchGestureRecognizer *)sender
{
    
    if (sender.scale > 1.0) {
        bigSize = bigSize - 1;
    }
    else if(sender.scale < 1.0)
    {
        bigSize = bigSize + 1;
    }
    
    [sender setScale:1];
    
    
    
    
}



#pragma  mark  实现单指头拖拽旋转
- (void)onPan:(UIPanGestureRecognizer *)sender
{
    
    UIGestureRecognizerState state = [sender state];
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
    }
    
    
    
    //    UITouch * touch = [touches anyObject];
    CGPoint location = [sender locationInView:sender.view];
    CGPoint diff = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y);
    
    float rotX = -1 * GLKMathDegreesToRadians(diff.y / 2.0);
    float rotY = -1 * GLKMathDegreesToRadians(diff.x / 2.0);
    
    bool isInvertible;
    GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(1, 0, 0));
    _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
    GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(0, 1, 0));
    _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z);
    
    _current_position = GLKVector3Make(location.x, location.y, 0);
    _current_position = [self projectOntoSurface:_current_position];
    
    [self computeIncremental];
    
    lastLoc = [sender locationInView:sender.view];
    
    
    
    
    
    
    
}

//双击屏幕
- (void)doubleTap:(UITapGestureRecognizer *)tap {
    
    
    
    [UIView animateWithDuration:1 animations:^{
        _slerping = YES;
        _slerpCur = 0;
        _slerpMax = 1.0;
        _slerpStart = _quat;
        _slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
        _quat = GLKQuaternionMake(0, 0, 0, 1);
        bigSize = 40;
        modelX = 0.0;
        modelY = 0.0;
        //         modelZ = 0.0;
        
    }];
    
}



#pragma mark --两指移动位移模型
- (void)onPan2:(UIPanGestureRecognizer *)sender
{
    //    NSLog(@"你再使用两个手指拖动");
    //通过使用 locationInView 这个方法,来获取到手势的坐标
    CGPoint location = [sender locationInView:sender.view.superview];
    //    NSLog(@"2指头拖拽：%f,%f",location.x,location.y);
    
    
    
    [xPointRecord addObject:[NSString stringWithFormat:@"%f",location.x]];
    [yPointRecord addObject:[NSString stringWithFormat:@"%f",location.y]];
    
    float xqian      = [xPointRecord[xPointRecord.count - 2] floatValue];
    float xhou       = [xPointRecord[xPointRecord.count - 1] floatValue];
    
    float yqian      = [yPointRecord[yPointRecord.count -2] floatValue];
    float yhou       = [yPointRecord[yPointRecord.count -1] floatValue];
    
    modelX           = modelX + (xhou - xqian)/100;
    modelY           = modelY - (yhou - yqian)/100;
    
    
    
    
    
    
    
    
    
}



#pragma mark --手势开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch1       = [touches anyObject];
    [yPointRecord removeAllObjects];
    [xPointRecord removeAllObjects];
    
    
    self->curTickleStart = [touch1 locationInView:glview];
    
    if (xPointRecord == nil) {
        xPointRecord         = [[NSMutableArray alloc]init];
    }
    if (yPointRecord == nil) {
        yPointRecord         = [[NSMutableArray alloc]init];
    }
    [xPointRecord addObject:[NSString stringWithFormat:@"%f",self->curTickleStart.x]];
    [yPointRecord addObject:[NSString stringWithFormat:@"%f",self->curTickleStart.y]];
    
    
    
    
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    _anchor_position = GLKVector3Make(location.x, location.y, 0);
    _anchor_position = [self projectOntoSurface:_anchor_position];
    
    _current_position = _anchor_position;
    _quatStart = _quat;
    
    
    
    
}







#pragma mark ---渲染数据
- (void)renderUI:(float *)sqData
{
    
    
    //一下大括号内代码为转换模型数据用于重新绘制模型合适大小至屏幕中心及
    {
        
        //定义出6个变量用于储存最小和最大的xyz
        float xMax = squareVertexData[0];
        float yMax = squareVertexData[1];
        float zMax = squareVertexData[2];
        
        float xMin = squareVertexData[0];
        float yMin = squareVertexData[1];
        float zMin = squareVertexData[2];
        
        
        
        NSLog(@"点个数:%d",faceNum*24);
        //循环获取最小最大xyz
        for (int i=0; i<faceNum*24; i++) {
            if ((i+1)%8 == 1) {
                
                if (squareVertexData[i] > xMax) {
                    xMax = squareVertexData[i];
                }
                
                if (squareVertexData[i] < xMin)
                {
                    xMin = squareVertexData[i];
                }
                
                
                
            }
            else if ((i+1)%8 == 2) {
                
                if (squareVertexData[i] > yMax) {
                    yMax = squareVertexData[i];
                }
                
                if (squareVertexData[i] < yMin)
                {
                    yMin = squareVertexData[i];
                }
                
                
            }
            else if ((i+1)%8 == 3) {
                
                
                if (squareVertexData[i] > zMax) {
                    zMax = squareVertexData[i];
                }
                
                if (squareVertexData[i] < zMin)
                {
                    zMin = squareVertexData[i];
                }
                
                
            }
            
            
            
        }
        
        
        NSLog(@"xyz最小：%f,%f,%f",xMin,yMin,zMin);
        NSLog(@"xyz最大：%f,%f,%f",xMax,yMax,zMax);
        
        NSLog(@"中心点坐标为:%f,%f,%f",(xMax-xMin)/2+xMin,(yMax-yMin)/2+yMin,(zMax-zMin)/2+zMin);
        
        
        
        //求出最长的长径
        float diameter = -200.0;
        
        if ((xMax-xMin)>=(yMax-yMin) && (xMax-xMin)>=(zMax - zMin)) {
            diameter = xMax-xMin;
        }
        if ((yMax-yMin)>=(xMax-xMin) && (yMax-yMin)>=(zMax - zMin)) {
            diameter = yMax-yMin;
        }
        if ((zMax-zMin)>=(yMax-yMin) && (xMax-xMin)<=(zMax - zMin)) {
            diameter = zMax-zMin;
        }
        
        NSLog(@"最长的长径：%f",diameter);
        
        //算出一个合适的比例展示模型
        float bili = 2.0/diameter;
        
        
        
        
        float midX,midY,midZ;
        midX =(xMax-xMin)/2+xMin;
        midY =(yMax-yMin)/2+yMin;
        midZ =(zMax-zMin)/2+zMin;
        
        
        
        
        for (int i=0; i<faceNum*24; i++) {
            float tem = squareVertexData[i];
            if ((i+1)%8 == 1) {
                squareVertexData[i] = (tem - midX)*bili;
            }
            else if((i+1)%8 == 2)
            {
                squareVertexData[i] = (tem - midY)*bili;
            }
            else if ((i+1)%8 == 3)
            {
                squareVertexData[i] = (tem - midZ)*bili;
            }
            else
            {
                squareVertexData[i] = tem;
            }
            
        }
        
        
    }
    
    
    
    dataCount  = (int)(faceNum*3);
    
    //用es2创建一个“EAGLContext”实例。
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //将“view”的context设置为这个“EAGLContext”实例的引用。并且设置颜色格式和深度格式
    
    glview.context = self.context;
    glview.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    glview.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glview.center = self.view.center;
    
    
    
    
    
    
    //将此“EAGLContext”实例设置为OpenGL的“当前激活”的“Context”。这样，以后所有“GL”的指令均作用在这个“Context”上。随后，发送第一个“GL”指令：激活“深度检测”。
    [EAGLContext setCurrentContext:context];
    glEnable(GL_DEPTH_TEST);//激活深度检测
    
    
    
    
    
    
    //    顶点数组保存进缓冲区
    //vertex data
    
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, faceNum*24*4, squareVertexData, GL_STATIC_DRAW);
    
    
    
    //    3、将缓冲区的数据复制进通用顶点属性中
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 4*8, (char *)NULL + 0);  //读顶点坐标
    
    
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 4*8, (char *)NULL +12); //读法线
    
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4*8, (char *)NULL + 24);  //读纹理
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //创建一个GLK内置的“着色效果”，并给它提供一个光源，光的颜色为默认银灰色
    self.effect = [[GLKBaseEffect alloc]init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);//漫反射颜色,依然按照rgb
    
    //     self.effect.light0.diffuseColor = GLKVector4Make(0.231, 0.247, 0.271, 1.0);//漫反射颜色,依然按照rgb
    //    self.effect.light0.specularColor  =  GLKVector4Make(0.361, 0.475, 0.749, 1.0);//高光颜色,依然按照rgb
    //    self.effect.light0.ambientColor  =  GLKVector4Make(0.620, 0.761, 0.055, 1.0);//环境光颜色,依然按照rgb
    
    
    
    
    //    2、将纹理坐标原点改为左下角
    //    GLKit加载纹理，默认都是把坐标设置在“左上角”。然而，OpenGL的纹理贴图坐标却是在左下角，这样刚好颠倒。
    //    在加载纹理之前，添加一个“options”：
    
    //        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"Tulips" ofType:@"JPG"];
    //
    //        NSDictionary *options = [NSDictionary  dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil];
    //        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    //        self.effect.texture2d0.enabled = GL_TRUE;
    //        self.effect.texture2d0.name = textureInfo.name;
    //    这个参数可以让系统在加载纹理后，做一些基本的处理。如预乘Alpha、创建“Mipmaps”等。
    
    
    free(squareVertexData);
}





//当页面彻底消失时候
//- (void)viewDidDisappear:(BOOL)animated
//{
//    glDeleteBuffers(1, &buffer);
//
//}




- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}
- (void)computeIncremental {
    
    GLKVector3 axis = GLKVector3CrossProduct(_anchor_position, _current_position);
    float dot = GLKVector3DotProduct(_anchor_position, _current_position);
    float angle = acosf(dot);
    
    GLKQuaternion Q_rot = GLKQuaternionMakeWithAngleAndVector3Axis(angle * 2, axis);
    Q_rot = GLKQuaternionNormalize(Q_rot);
    
    // TODO: Do something with Q_rot...
    _quat = GLKQuaternionMultiply(Q_rot, _quatStart);
    
    
    
    
    
}
- (GLKVector3) projectOntoSurface:(GLKVector3) touchPoint
{
    //    float radius = self.view.bounds.size.width/3;
    float radius = self.view.bounds.size.width;
    
    GLKVector3 center = GLKVector3Make(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0);
    GLKVector3 P = GLKVector3Subtract(touchPoint, center);
    
    // Flip the y-axis because pixel coords increase toward the bottom.
    P = GLKVector3Make(P.x, P.y * -1, P.z);
    
    float radius2 = radius * radius;
    float length2 = P.x*P.x + P.y*P.y;
    
    
    
    
    
    if (length2 <= radius2)
        P.z = sqrt(radius2 - length2)/2;//此处可修改单次旋转弧度,P.z越小。旋转越快
    else
    {
        /*
         P.x *= radius / sqrt(length2);
         P.y *= radius / sqrt(length2);
         P.z = 0;
         */
        P.z = radius2 / (2.0 * sqrt(length2));
        float length = sqrt(length2 + P.z * P.z);
        P = GLKVector3DivideScalar(P, length);
    }
    
    return GLKVector3Normalize(P);
}








- (void)viewWillDisappear:(BOOL)animated
{
    UILabel *label = [self.navigationController.view viewWithTag:888];
    [label removeFromSuperview];
    
}



//设置backbarbuttonItem事件
- (void)backButton_OnClick:(UIBarButtonItem *)sender
{
    //    glDeleteBuffers(1, &buffer);
    isExit = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    if (isExit) {
        [EAGLContext setCurrentContext:self.context];
        
        
        glDeleteBuffers(1, &buffer);
        //glDeleteVertexArraysOES(1, &_vertexArray);
        
        self.effect = nil;    }
    
}


//为segmentcontrol生成顺号
- (NSArray *)getSegmentControlIndexWithArray:(NSArray *)modelList
{
    NSMutableArray *indexArr = [[NSMutableArray alloc]init];
    
    for (int i=0; i<modelList.count; i++) {
        [indexArr addObject:[NSString stringWithFormat:@"%d",i+1]];
    }
    
    return indexArr;
}


@end
