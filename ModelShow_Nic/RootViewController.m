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
    UITableView *tv;
    NSMutableArray *modelData;
    
    
    
    UILabel *tishi;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"模型";
    self.view.backgroundColor = [UIColor greenColor];
    
    
    self.navigationItem.backBarButtonItem = nil;

    
    
    
    
    if (modelData == nil) {
        modelData = [[NSMutableArray alloc]init];
    }
    
    
    
    NSArray *modelArr = @[@"哆啦A梦.stl (binary) 1.4M",@"板子.stl(ascii) 934KB",@"男人.obj 4kb"];
    
    [modelData addObjectsFromArray:modelArr];
    
    [self cretaTableView];
    
}


- (void)cretaTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    tv = [[UITableView alloc]init];
    tv.frame = self.view.frame;
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
    
    
    //让底部不被遮挡
    tv.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"你点击了%@",modelData[indexPath.row]);
    
    
    
    
    
    MyGlViewController *glk = [[MyGlViewController alloc]init];
    
        tishi = [[UILabel alloc]initWithFrame:CGRectMake(tv.frame.size.width/2-100, tv.frame.size.height/2-50, 200, 100)];
        tishi.text = @"读取中...";
        tishi.textColor = [UIColor greenColor];
    tishi.font = [UIFont systemFontOfSize:40.0];
        tishi.backgroundColor = [UIColor blackColor];
        [self.view addSubview:tishi];
    
    
    
//    
//    
//    
//  long long size =  [self fileSizeAtPath:[[NSBundle mainBundle] pathForResource:@"dddn" ofType:@"stl"]]/(1024.0*1024.0);
//    NSLog(@"本文件size：%lld",size);
//    
    
    
    
    NSArray *modelList = @[[[NSBundle mainBundle]pathForResource:@"哆啦A梦" ofType:@"stl"],[[NSBundle mainBundle]pathForResource:@"k3" ofType:@"stl"],[[NSBundle mainBundle]pathForResource:@"man11" ofType:@"obj"]];
    
    
    
    
    //GCD执行
    dispatch_async(dispatch_get_main_queue(), ^{
    
        
        
        switch (indexPath.row + 1) {
            case 1:
            {
                NSString *fileName = [[NSBundle mainBundle]pathForResource:@"哆啦A梦" ofType:@"stl"];
                glk.curFileName = fileName;
            }
                break;
                
            case 2:
            {
                NSString *fileName = [[NSBundle mainBundle]pathForResource:@"k3" ofType:@"stl"];
                glk.curFileName = fileName;
            }
                break;
                
            case 3:
            {
                NSString *fileName = [[NSBundle mainBundle]pathForResource:@"man11" ofType:@"obj"];
                NSLog(@"%@",fileName);
                glk.curFileName = fileName;
            }
                break;
           
                
                
            default:
                break;
        }
        
        
        if (glk.curFileName == nil) {
            NSLog(@"没找到文件");
        }
        
        
        
        
        glk.modelList = modelList;
        [self.navigationController pushViewController:glk animated:YES];
        
        

        
        
    });

    
    

    
    
    
    
    


    
    
    
}





//获得随机颜色
- (UIColor *) randomColor

{
    
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}





- (void)viewWillDisappear:(BOOL)animated
{
//    avc.hidden = NO;
}


-(void)viewDidDisappear:(BOOL)animated
{


    [tishi removeFromSuperview];
}





-(long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        
    }  
    
    return 0;  
    
}





- (float *)backFloatArr
{
    float *squareVertexData;//定义数组
    //给它malloc一个空间
    squareVertexData = (float *)malloc(20*8*sizeof(float));
    
    for (int i=0; i<20; i++) {
        squareVertexData[i] = i*0.14;
    }
    
    
    
    return squareVertexData;
    
}






@end
