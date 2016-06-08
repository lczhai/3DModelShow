//
//  ZLCObjeparser.h
//  ModelShow_Nic
//
//  Created by shining3d on 16/5/9.
//  Copyright © 2016年 shining3d. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NewParser.h"


@interface ZLCObjeparser : NSObject



//@property (nonatomic,copy) void




//解析obj文件，根据文件路径
+ (NSValue *)ParserObjFileWithfilaPath:(NSString *)path;



@end
