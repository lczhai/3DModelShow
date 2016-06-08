//
//  STLParser.h
//  Tutorial03
//
//  Created by shining3d on 16/1/15.
//  Copyright © 2016年 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STLParser : NSObject




+ (NSArray *)stlParserWithAscii:(NSString *)fileName;

+ (NSArray *)stlParserWithBinary:(NSString *)fileName;



@end
