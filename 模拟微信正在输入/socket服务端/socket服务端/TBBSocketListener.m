//
//  TBBSocketListener.m
//  socket服务端
//
//  Created by YiGuo on 2017/2/22.
//  Copyright © 2017年 tbb. All rights reserved.
//

#import "TBBSocketListener.h"
#import "GCDAsyncSocket.h"
@interface TBBSocketListener()<GCDAsyncSocketDelegate>
//服务端socket对象
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
//客户端的所有socket对象
@property (nonatomic, strong) NSMutableArray *clientSockets;
@end


@implementation TBBSocketListener
-(id)init{
    if (self = [super init]) {
        self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return self;
}
-(NSMutableArray *)clientSockets{
    if (!_clientSockets) {
        _clientSockets = [NSMutableArray array];
    }
    
    return _clientSockets;
}
-(void)startListener{
    NSError *err = nil;
    BOOL success = [self.serverSocket acceptOnPort:5266 error:&err];
    if (success) {
        NSLog(@"服务开启成功");
    } else {
        NSLog(@"服务开启失败");
    }
}
#pragma mark 有客户端的socket连接到服务器
-(void)socket:(GCDAsyncSocket *)serverSocket didAcceptNewSocket:(GCDAsyncSocket *)clientSocket{
    NSLog(@"serverSocket %@ ",serverSocket);
    NSLog(@"clientSocket %@ host:%@ port:%d",clientSocket,clientSocket.connectedHost,clientSocket.connectedPort);
    //1.保存客户端的socket
    [self.clientSockets addObject:clientSocket];
    
    // 2.监听客户端有没有数据上传
    //timeout -1 代表不超时
    //tag 标识作用，现在不用，就写0
    [clientSocket readDataWithTimeout:-1 tag:0];
    
    NSLog(@"当前有%ld 客户已经连接到服务器",self.clientSockets.count);
}

#pragma mark 读取客户端请求的数据
-(void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag{
    
    // 1.把NSData转NSString
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // 2.把当前客户端的数据 转发给 其它的客户端
    NSLog(@"接收到客户端上传的数据：%@",str);
    for (GCDAsyncSocket *socket in self.clientSockets) {
        if (socket != clientSocket) {//不要发送给自己
            [socket writeData:data withTimeout:-1 tag:0];
        }
        
    }
#warning 每次读完数据后，都要调用一次监听数据的方法
    [clientSocket readDataWithTimeout:-1 tag:0];
}
//数据发送成功时调用
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"数据发送成功..");
}

@end
