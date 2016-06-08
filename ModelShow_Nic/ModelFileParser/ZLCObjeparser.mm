//
//  ZLCObjeparser.m
//  ModelShow_Nic
//
//  Created by shining3d on 16/5/9.
//  Copyright © 2016年 shining3d. All rights reserved.
//

#import "ZLCObjeparser.h"
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;
#define MAX_LINE 1024


struct pointInfo
{
    float *squareVertexData;
    int   faceNum;
};

@implementation ZLCObjeparser




+ (NSValue *)ParserObjFileWithfilaPath:(NSString *)path
{
    struct ModelData{
        float *squareVertexData;
        int facetNum;
        int size;
    };
    
    NSValue *value1 = [NewParser getParserDataWithFile:path];
    
    //取到解析方法返回的NSValue（携带结构体参数）
    
    //定义结构体接受NSValue内的结构体参数
    struct ModelData pro1 ;
    [value1 getValue:&pro1];
    

    //给结构体赋值
    pointInfo pro = {pro1.squareVertexData,pro1.facetNum};
    //结构体转NSValue
    NSValue *value = [NSValue valueWithBytes:&pro objCType:@encode(pointInfo)];
    
    
    return value;

}
//{
//    float *squareVertexData;
//    int faceNum;
//
//
//
//
//    const char* destDir = [path UTF8String];//将NSString转为char *字符串
//    std::ifstream inOBJ;
//    std::string fp  = destDir;
//    destDir = nil;
//    inOBJ.open(fp);
//    std::vector<float>vec;//定义一个vector容器，用于存储float数组
//    
//    
//    
//    std::vector<float>dian;
//    std::vector<std::string>mian;
//    std::vector<float>faxiangliang;
//    std::vector<float>wenli;
//    
//    
//    std::cout<<fp<<std::endl;
//    if(!inOBJ.good())
//    {
//        printf("ERROR OPENING OBJ FILE");
//        
//        //        exit(1);
//    }
//    // Read stl file
//    
//    BOOL isStart = YES;
//    
//    while (!inOBJ.eof()) {
//        
//        std::string line;
//        getline(inOBJ,line);//将读取到得obj当前行存入line
//        
//        
//        
//        
//        
//        //判断当前行是否为正常的需要的数据
//        if (isStart)
//        {
//            
//            if (line[0] == 'v')
//            {
//                isStart = NO;
//            }
//            else
//            {
//                continue;
//                
//            }
//        }
//        
//        
//        
//        
//        
//        std::string str = line;//获取此行字符串
//        //下述从开始到结束，为处理当前行数据以空格分隔成新的多个字符串存放在vector里
//        //----------开始---------
//        auto it2 = std::find_if( str.begin() , str.end() , [](char ch){
//            return !std::isspace<char>(ch , std::locale::classic() ) ;
//        });
//        str.erase(str.begin(), it2);
//        
//        std::vector<std::string> vector;
//        
//        std::string::size_type pos1, pos2;
//        std::string pattern = " ";
//        pos2 = str.find(pattern);
//        pos1 = 0;
//        while(std::string::npos != pos2)
//        {
//            vector.push_back(str.substr(pos1, pos2-pos1));
//            
//            pos1 = pos2 + pattern.size();
//            pos2 = str.find(pattern, pos1);
//        }
//        if(pos1 != str.length()) {
//            vector.push_back(str.substr(pos1));
//        }
//        
//        //----------结束---------
//        
//        
//        int count=0;
//        NSString *type = @"";
//        NSString *record = @"";
//        
//        
//        for( auto i : vector)
//        {
//            
//            //判断当前字符串是否为空格，如为空格，进行下一次循环
//            if (i == "\0") {
//                continue;
//            }
//            
//            
//            if (count == 0) {
//                //                                printf(i.c_str());
//                
//                if (i == "vn") {
//                    type = @"vn";
//                    record = @"vn";
//                }
//                else if (i == "v")
//                {
//                    type = @"v";
//                    record = @"v";
//                }
//                else if(i == "vt")
//                {
//                    type = @"vt";
//                    record = @"vt";
//                }
//                else if(i == "f")
//                {
//                    type = @"f";
//                    record = @"f";
//                }
//                else if (i.length()>3)
//                {
//                    type = @"other";
//                    //                                    printf(i.c_str());
//                    //                                    NSLog(@"is float");
//                }
//                
//                
//            }
//            else
//            {
//                
//                
//                
//                
//                if ([type isEqualToString:@"v"]) {
//                    
//                    
//                    dian.push_back(atof(i.c_str()));
//                }
//                else if ([type isEqualToString:@"vt"])
//                {
//                    
//                    wenli.push_back(atof(i.c_str()));
//                }
//                else if ([type isEqualToString:@"vn"])
//                {
//                    
//                    faxiangliang.push_back(atof(i.c_str()));
//                }
//                else if ([type isEqualToString:@"f"])
//                {
//                    
//                    mian.push_back(i.c_str());
//                    
//            //                                    cout<<i<<endl;
//                    
//                    
//                    
//                }
//                else if ([type isEqualToString:@"other"])
//                {
//                    
//                    if ([record isEqualToString:@"v"]) {
//                        dian.pop_back();
//                        dian.push_back(atof(i.c_str()));
//                    }
//                    else if ([record isEqualToString:@"vt"])
//                    {
//                        wenli.pop_back();
//                        wenli.push_back(atof(i.c_str()));
//                    }
//                    else if ([record isEqualToString:@"vn"])
//                    {
//                        faxiangliang.pop_back();
//                        faxiangliang.push_back(atof(i.c_str()));
//                    }
//                    else if ([record isEqualToString:@"f"])
//                    {
//                        mian.pop_back();
//                        mian.push_back(i.c_str());
//                    }
//                    
//                }
//                
//            }
//            
//            count++;
//            
//        }
//        
//        
//        
//        
//    }
//    
//    
//    
//    
//    
//    faceNum =(int)mian.size()/3;
//    
//    
//    
//    
//    
//    std::cout<<"mian:"<<mian.size()<<std::endl;//求vec数据个数
//    squareVertexData = (float *)malloc(mian.size()*8*sizeof(float));
//    
//    
//    
//    int count =0;
//    for( std::string i : mian)
//    {
//        NSString *shunxuStr = [NSString stringWithUTF8String:i.c_str()];
//        NSMutableArray *shunxu ;
//        
//        if (shunxu == nil) {
//            shunxu =         [[NSMutableArray alloc]initWithArray:[shunxuStr componentsSeparatedByString:@"/"]];
//        }
//        else
//        {
//            [shunxu removeAllObjects];
//            [shunxu addObjectsFromArray:[shunxuStr componentsSeparatedByString:@"/"]];
//        }
//        
//        
//        
//        
//        
//    
//        squareVertexData[count++]   = dian[([shunxu[0] intValue]-1)*3 +0];
//        squareVertexData[count++] = dian[([shunxu[0] intValue]-1)*3 +1];
//        squareVertexData[count++] = dian[([shunxu[0] intValue]-1)*3 +2];
//        
//        squareVertexData[count++] = faxiangliang[([shunxu[2] intValue]-1)*3 +0 ];
//        squareVertexData[count++] = faxiangliang[([shunxu[2] intValue]-1)*3 +1 ];
//        squareVertexData[count++] = faxiangliang[([shunxu[2] intValue]-1)*3 +2 ];
//        
//        squareVertexData[count++] = 1.0;
//        squareVertexData[count++] = 1.0;
//        
//        
//        
//        
//        
//    }
//    
//    
//
//    
//    //给结构体赋值
//     pointInfo pro = {squareVertexData,faceNum};
//    //结构体转NSValue
//    NSValue *value = [NSValue valueWithBytes:&pro objCType:@encode(pointInfo)];
//    
//    
//    
//    
//    for (int i=0; i<16; i++) {
//        NSLog(@"%f",pro.squareVertexData[i]);
//    }
//    
//    
////    [[NSUserDefaults standardUserDefaults] setObject:value forKey:path];
//    
//    
//    return value;
//    
//    
//    
//    
//}



@end
