//
//  ViewController.m
//  socket用户端
//
//  Created by YiGuo on 2017/2/22.
//  Copyright © 2017年 tbb. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
@interface ViewController ()<GCDAsyncSocketDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (weak, nonatomic) IBOutlet UITextField *textField;
/**数据源*/
@property (nonatomic, strong) NSMutableArray *dataSources;

@property (nonatomic, strong)GCDAsyncSocket *clientSocket;
@end

@implementation ViewController
-(NSMutableArray *)dataSources{
    if (!_dataSources) {
        _dataSources = [NSMutableArray new];
    }
    return _dataSources;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title =  @"消息";
    // 1.连接到群聊服务器
    // 1.1.创建一个客户端的socket对象
    GCDAsyncSocket *clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    self.clientSocket = clientSocket;
    
    // 1.2 发送连接请求
    NSError *error = nil;
    [clientSocket connectToHost:@"192.168.0.102" onPort:5266 error:&error];
    if (!error) {
        NSLog(@"%@",error);
    }

}
#pragma mark--GCDAsyncSocketDelegate
-(void)socket:(GCDAsyncSocket *)clientSocket didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"与服务器连接成功");
    // 监听读取数据
    [clientSocket readDataWithTimeout:-1 tag:0];
    
}

// Disconnect 断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"与服务器断开连接 %@",err);
}
//读取消息
-(void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag{
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"信息是什么%@",str);
    NSLog(@"%@",[NSThread currentThread]);
    // 把消息添加到数据源
    if (str) {
        
        if ([str isEqualToString:@"66.$.#.11@正在输入111@.#.#88."]) {
            NSLog(@"str是否为正在输入：%@",str);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.navigationItem.title = @"...正在输入...";
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.navigationItem.title = @"信息";
            }];
            
            [self.dataSources addObject:str];
        }
        // 刷新表格
#warning 要在主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableVIew reloadData];
        }];
        
    }
    
    
    // 监听读取数据
    [clientSocket readDataWithTimeout:-1 tag:0];
    
}


- (IBAction)sendAction:(id)sender {
    NSString *str = self.textField.text;
    if (str.length == 0) {//无数据发送
        return;
    }
    
    // 把数据添加数据源
    [self.dataSources addObject:self.textField.text];
    
    // 刷新表格
    [self.tableVIew reloadData];
    
    // 发数据
    [self.clientSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [self.textField resignFirstResponder];
    [self.textField resignFirstResponder];
}
#pragma mark tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSources.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    // 信息
    cell.textLabel.text = self.dataSources[indexPath.row];
    
    return cell;
}

//向通知中心添加观察者
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
    
}
//在界面隐藏时，取消键盘的监听
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    
}
//将输入框架弹起
- (void)openKeyboard:(NSNotification *)notification
{
    //如果是手动布局就计算输入框架的frame,如果是自动布局,那就添加或修改约束
    //键盘有多高
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    //键盘升起动画的时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    //动画选项
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]intValue];
    
    //修改约束,让输入框架距离父视图的下边正好和键盘一样高
    self.bottomConstraint.constant = keyboardFrame.size.height;
    //让输入框架和键盘做完全一样的动画效果
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
                         //让修改后的约束起作用
                         [self.view layoutIfNeeded];
                         
                     } completion:nil];
    
    
}

//让输入框回到下边
- (void)closeKeyboard:(NSNotification *)notification
{
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]intValue];
    self.bottomConstraint.constant = 0;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
}
#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"开始输入");
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"输入结束");
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    // 发数据
    [self.clientSocket writeData:[@"66.$.#.11@正在输入111@.#.#88." dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    //    NSLog(@"正在输入");
    return YES;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
