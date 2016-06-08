//
//  STLParser.m
//  Tutorial03
//
//  Created by shining3d on 16/1/15.
//  Copyright © 2016年 kesalin@gmail.com. All rights reserved.
//

#import "STLParser.h"

@implementation STLParser





//转译ascii文件
+ (NSArray *)stlParserWithAscii:(NSString *)fileName
{
    NSString *fileContext = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    
    
    
    NSMutableArray *lineArr;
    if (lineArr == nil) {
     lineArr   = [[NSMutableArray alloc]init];
    }
    
    
    
    [lineArr addObjectsFromArray:[fileContext componentsSeparatedByString:@"\n"]];//按行取出模型文件数据
    
    
    [lineArr removeObjectAtIndex:0];//删除第一行solid+文件名 数据
    [lineArr removeLastObject];//删除最后一行“  ”数据
    [lineArr removeLastObject];//删除倒数第二行endsolid数据
    
    
    
    

    NSLog(@"此模型为ascii格式，共有%lu个三角面片",lineArr.count/7);
    
    
    
    
    NSMutableArray *pianmianArr;//定义数组挨个储存顶点数据
    
    
    int faceCount = (int)lineArr.count/7;
    
    for (int i=0; i<faceCount; i++) {
        
        if (pianmianArr == nil) {
            pianmianArr = [[NSMutableArray alloc]init];
        }

        
        NSArray *nor = [lineArr[0] componentsSeparatedByString:@" "];//将当前片面的normal数据按空格分开（法向量）
        NSArray *vex1 = [lineArr[2] componentsSeparatedByString:@" "];//将当前片面的第一个顶点数据用空格分开（点1）
        
        
        [pianmianArr addObject:vex1[vex1.count-3]];
        [pianmianArr addObject:vex1[vex1.count-2]];
        [pianmianArr addObject:vex1[vex1.count-1]];
        [pianmianArr addObject:nor[nor.count-3]];
        [pianmianArr addObject:nor[nor.count-2]];
        [pianmianArr addObject:nor[nor.count-1]];
        [pianmianArr addObject:@"1.0"];
        [pianmianArr addObject:@"1.0"];
        
        
        
        
        
        
        
        NSArray *vex2 = [lineArr[3] componentsSeparatedByString:@" "];//点2
        
        [pianmianArr addObject:vex2[vex2.count-3]];
        [pianmianArr addObject:vex2[vex2.count-2]];
        [pianmianArr addObject:vex2[vex2.count-1]];
        [pianmianArr addObject:nor[nor.count-3]];
        [pianmianArr addObject:nor[nor.count-2]];
        [pianmianArr addObject:nor[nor.count-1]];
        [pianmianArr addObject:@"1.0"];
        [pianmianArr addObject:@"1.0"];
        
        
        
        
        
        NSArray *vex3 = [lineArr[4] componentsSeparatedByString:@" "];//点3
        
        [pianmianArr addObject:vex3[vex3.count-3]];
        [pianmianArr addObject:vex3[vex3.count-2]];
        [pianmianArr addObject:vex3[vex3.count-1]];
        [pianmianArr addObject:nor[nor.count-3]];
        [pianmianArr addObject:nor[nor.count-2]];
        [pianmianArr addObject:nor[nor.count-1]];
        [pianmianArr addObject:@"1.0"];
        [pianmianArr addObject:@"1.0"];
        
        //每行数据为：顶点坐标+法矢量+纹理坐标
        
        
        
        
        
        nor = nil;
        vex1 = nil;
        vex3 = nil;
        vex2 = nil;
        [lineArr removeObjectAtIndex:6];
        [lineArr removeObjectAtIndex:5];
        [lineArr removeObjectAtIndex:4];
        [lineArr removeObjectAtIndex:3];
        [lineArr removeObjectAtIndex:2];
        [lineArr removeObjectAtIndex:1];
        [lineArr removeObjectAtIndex:0];
        
        
    }
    
    
    
    
    
    [lineArr removeAllObjects];

    
    
    //modelData 为最终所得参数
    return pianmianArr;
    
    
}




//转译binary文件
+(NSArray *)stlParserWithBinary:(NSString *)fileName
{
    
    NSLog(@"fileName:%@",fileName);//输出文件完整路径
    
    NSData *reader = [NSData dataWithContentsOfFile:fileName];//将文件转为NSData二进制格式
    
    
    
    
    char dataBuf[100];
    int offset = 0;
    [reader getBytes:&dataBuf range:NSMakeRange(offset, 80)];//读取stl文件的0-80字节，此段为stl文件的文件名
    
    int faceNum = 0;
    [reader getBytes:&faceNum range:NSMakeRange(80,4)];//读取stl文件的80-84字节，此段为stl的三角面片个数
     NSLog(@"face个数:%d",faceNum);
    
    
    
    
    
    
    int currRange = 80;//设定当前字节下标，默认从84开始读起起，即跳过文件名及face总数直接读取有效数据
        NSMutableArray *pianmianArr;
    if (pianmianArr == nil) {
        pianmianArr = [[NSMutableArray alloc]init];//用于模型几何数据的保存
    }

    
    
    for (int x = 0; x < faceNum ; x++) {
        
        
        
        
        
                
            float curr = 0.0;//临时变量
        

        
            [reader getBytes:&curr range:NSMakeRange(currRange+16, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
            [reader getBytes:&curr range:NSMakeRange(currRange+20, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
            [reader getBytes:&curr range:NSMakeRange(currRange+24, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        
        
        
        [reader getBytes:&curr range:NSMakeRange(currRange+4, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        [reader getBytes:&curr range:NSMakeRange(currRange+8, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        [reader getBytes:&curr range:NSMakeRange(currRange+12, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",1.0 ]];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",1.0 ]];
        
        
        
        
        
            [reader getBytes:&curr range:NSMakeRange(currRange+28, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
            [reader getBytes:&curr range:NSMakeRange(currRange+32, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
            [reader getBytes:&curr range:NSMakeRange(currRange+36, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        
        
        
        
        
        
        [reader getBytes:&curr range:NSMakeRange(currRange+4, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        [reader getBytes:&curr range:NSMakeRange(currRange+8, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        [reader getBytes:&curr range:NSMakeRange(currRange+12, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",1.0 ]];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",1.0 ]];
        
        
        
        
            [reader getBytes:&curr range:NSMakeRange(currRange+40, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
            [reader getBytes:&curr range:NSMakeRange(currRange+44, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
            [reader getBytes:&curr range:NSMakeRange(currRange+48, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        
        
        [reader getBytes:&curr range:NSMakeRange(currRange+4, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        [reader getBytes:&curr range:NSMakeRange(currRange+8, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        [reader getBytes:&curr range:NSMakeRange(currRange+12, 4)];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",curr ]];
        
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",1.0 ]];
        [pianmianArr addObject:[NSString stringWithFormat:@"%f",1.0 ]];
        
        
        
        
        currRange = currRange  + 50;//每个三角面信息的最后两个字节为描述字节，无用。+掉
        
        
        
    }
    
    
    
    
    
    
    
    
    
    reader = nil;
    
    return pianmianArr;
}








@end
