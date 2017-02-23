//
//  main.m
//  socket服务端
//
//  Created by YiGuo on 2017/2/22.
//  Copyright © 2017年 tbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBBSocketListener.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //1.创建一个服务监听对象
        TBBSocketListener *socketlistener = [[TBBSocketListener alloc] init];
        //2.开启监听
        [socketlistener startListener];
        //3.开启主运行循环，让服务不能停
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
