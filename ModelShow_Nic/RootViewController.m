//
//  RootViewController.m
//  ModelShow_Nic
//
//  Created by shining3d on 16/1/21.
//  Copyright © 2016年 shining3d. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController
{
    UITableView *tableView;
    NSMutableArray *modelData;
    
    
    
    UILabel *alertLabel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"模型";
    self.view.backgroundColor = [UIColor greenColor];
    self.navigationItem.backBarButtonItem = nil;
    modelData = [[NSMutableArray alloc]initWithArray:@[@"哆啦A梦.stl (binary) 1.4M",@"板子.stl(ascii) 934KB",@"男人.obj 4kb"]];
    
    //创建列表
    [self cretaTableView];
    
}


//创建列表视图
- (void)cretaTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor grayColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:tableView];
    tableView.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

#pragma mark --tableview Delegate&DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return modelData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"1992"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"1992"];
    }
    
    cell.textLabel.text = modelData[indexPath.row];
    
    cell.contentView.backgroundColor = [self randomColor];
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark --click action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"您点击了%@",modelData[indexPath.row]);
    
    
   
    
    
    MyGlViewController *glk = [[MyGlViewController alloc]init];//创建GL 控制器
//    [self initAlertLabel];//初始化提示标签（作为加载模型时候的提示）
    
    
    
    
    
   
    

//  long long size =  [self fileSizeAtPath:[[NSBundle mainBundle] pathForResource:@"dddn" ofType:@"stl"]]/(1024.0*1024.0);
//    NSLog(@"本文件size：%lld",size);

    
    
    //模型数组
    NSArray *modelList = @[[[NSBundle mainBundle]pathForResource:@"哆啦A梦" ofType:@"stl"],[[NSBundle mainBundle]pathForResource:@"k3" ofType:@"stl"],[[NSBundle mainBundle]pathForResource:@"man11" ofType:@"obj"]];
    
    
    
    
    

    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //判断用户点击
        if (indexPath.row == 0) {
            glk.curFileName = [[NSBundle mainBundle]pathForResource:@"哆啦A梦" ofType:@"stl"];
        }else if (indexPath.row == 1){
            glk.curFileName = [[NSBundle mainBundle]pathForResource:@"k3" ofType:@"stl"];
        }else if (indexPath.row == 2){
            glk.curFileName = [[NSBundle mainBundle]pathForResource:@"man11" ofType:@"obj"];
        }else{
            NSLog(@"没找到文件");
            return ;
        }

        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            glk.modelList = modelList;
            [self.navigationController pushViewController:glk animated:YES];
        });
    });
    
    
}





//获得随机颜色
- (UIColor *) randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}



//初始化alertLabel
- (void)initAlertLabel{
    alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(tableView.frame.size.width/2-100, tableView.frame.size.height/2-50, 200, 100)];
    alertLabel.text = @"读取中...";
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.font = [UIFont systemFontOfSize:40.0];
    alertLabel.backgroundColor = [UIColor grayColor];
    alertLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:alertLabel];
}




-(void)viewDidDisappear:(BOOL)animated
{
    [alertLabel removeFromSuperview];
}




//获取文件大小
-(long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        
    }  
    
    return 0;  
    
}









@end
