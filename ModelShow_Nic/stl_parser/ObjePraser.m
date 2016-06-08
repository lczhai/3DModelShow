//
//  ObjePraser.m
//  ObjPraser
//
//  Created by shining3d on 16/3/14.
//  Copyright © 2016年 shining3d. All rights reserved.
//

#import "ObjePraser.h"

@implementation ObjePraser




+ (NSArray *)getObjePointArray:(NSString *)filePath
{
    NSMutableArray *pointArr = [[NSMutableArray alloc]init];
    
    
    
    
    NSMutableArray *dian = [[NSMutableArray alloc]init];
    NSMutableArray *faxiangliang = [[NSMutableArray alloc]init];
    NSMutableArray *wenli  = [[NSMutableArray alloc]init];
    
    NSMutableArray *mian = [[NSMutableArray alloc]init];
    
    
//    NSString *file = [[NSBundle  mainBundle] pathForResource:@"方块" ofType:@"obj"];
    
    
    
    
    
    NSString *context = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *duan = [[NSMutableArray alloc]initWithArray:[context componentsSeparatedByString:@"\n"]];

    
    
    BOOL isStart = YES;
    
    for (NSString *str in duan) {
        
        
        
        
        
        
        
        
        NSArray *hang = [str componentsSeparatedByString:@" "];
        
        
        
        //判断当前行是否为正常的需要的数据
        if (isStart) {
            
            NSLog(@"当前第一个：%@",hang[0]);
            if (![hang[0] isEqualToString:@"v"]) {
                continue;
            }
            else
            {
                isStart = NO;
                
            }
        }
        
        
        if ([hang[0] isEqualToString:@"v"]) {
            
            
            
            
            NSString *zuhe = [NSString stringWithFormat:@"%@,%@,%@,",hang[1],hang[2],hang[3]];
            
            [dian addObject:zuhe];
            
        }
        
        if ([hang[0] isEqualToString:@"vt"]) {
            
            
            NSString *zuhe = [NSString stringWithFormat:@"%@,%@,",hang[1],hang[2]];
            
            [wenli addObject:zuhe];
            
        }
        
        
        if ([hang[0] isEqualToString:@"vn"]) {
            
            
            NSString *zuhe = [NSString stringWithFormat:@"%@,%@,%@,",hang[1],hang[2],hang[3]];
            
            [faxiangliang addObject:zuhe];
            
        }
        
        
        
        if ([hang[0] isEqualToString:@"f"]) {
            
            
            
            [mian addObject:hang[1]];
            [mian addObject:hang[2]];
            [mian addObject:hang[3]];
        }

        
        
    }
    
    
   
    
    for (int i=0 ; i<mian.count; i++) {
        
        
//        NSArray *shunxu = [mian[i] componentsSeparatedByString:@"/"];
        
        NSMutableArray *shunxu = [[NSMutableArray alloc]initWithArray:[mian[i] componentsSeparatedByString:@"/"]];
        
        if ([shunxu[1] isEqualToString:@""]) {
            [shunxu removeObjectAtIndex:1];
            [shunxu insertObject:@"1" atIndex:1];
        }
        
        
        
        
//        NSString *string = [NSString stringWithFormat:@"%@%@%@",dian[[shunxu[0] intValue]-1],faxiangliang[[shunxu[2] intValue]-1],wenli[[shunxu[1] intValue]-1]];
//        
//        
        
        
        
        
        [pointArr addObject:[dian[[shunxu[0] intValue]-1] componentsSeparatedByString:@","][0]];
        [pointArr addObject:[dian[[shunxu[0] intValue]-1] componentsSeparatedByString:@","][1]];
        [pointArr addObject:[dian[[shunxu[0] intValue]-1] componentsSeparatedByString:@","][2]];
        
        [pointArr addObject:[faxiangliang[[shunxu[2] intValue]-1] componentsSeparatedByString:@","][2]];
        [pointArr addObject:[faxiangliang[[shunxu[2] intValue]-1] componentsSeparatedByString:@","][1]];
        [pointArr addObject:[faxiangliang[[shunxu[2] intValue]-1] componentsSeparatedByString:@","][0]];
        
//        [pointArr addObject:[wenli[[shunxu[1] intValue]-1] componentsSeparatedByString:@","][0]];
//        [pointArr addObject:[wenli[[shunxu[1] intValue]-1] componentsSeparatedByString:@","][1]];
        

        [pointArr addObject:@"1"];
        [pointArr addObject:@"1"];
    }
    
    
//    NSLog(@"heji=%@",pointArr);
    
    
    
    
//    float a = [pointArr[0] floatValue];
    
    
    
    
    
    
    
    return pointArr;
}



@end
