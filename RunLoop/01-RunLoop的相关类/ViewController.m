//
//  ViewController.m
//  01-RunLoop的相关类
//
//  Created by iso9007 on 16/8/25.
//  Copyright © 2016年 iso9007. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self timer1];
//    [NSThread detachNewThreadSelector:@selector(timer1) toTarget:self withObject:nil];
//    [self timer2];
    [self observer];
}

- (void)timer1
{
    //创建定时器每两秒执行task方法
    //该方法内部会自动将创建的定时器添加到当前运行循环中，指定模式是Default模式
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(task) userInfo:nil repeats:YES];
    //主动创建并开启runloop
    [[NSRunLoop currentRunLoop] run];
    
}



- (void)timer2
{
    //1.创建定时器
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(task) userInfo:nil repeats:YES];
    //2.主动将当前定时器添加到runloop中，并指定runloop模式
    /*
     参数1：添加的定时器
     参数2：指定runloop的运行模式
     */
    //指定NSDefaultRunLoopMode运行模式，意味着该定时器只在runloop的运行模式为Default下才工作
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    //要求拖动界面的时候，定时器也会工作
    //意味着该定时器只在runloop运行模式为Tracking下才工作
    //[[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    
    //要求在任何时候定时器都会工作
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    //[[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    
    
    //NSRunLoopCommonModes：占位模式
    //NSRunLoopCommonModes相当于添加：NSDefaultRunLoopMode + UITraskingRunLoopMode
    /*common modes = <CFBasicHash 0x7f9148406030 [0x10cc55a40]>{type = mutable set, count = 2,
        entries =>
        0 : <CFString 0x10db8d210 [0x10cc55a40]>{contents = "UITrackingRunLoopMode"}
        2 : <CFString 0x10cc765e0 [0x10cc55a40]>{contents = "kCFRunLoopDefaultMode"}
    } 这是打印当前runloop对象中观察到哪个运行模式mode打上Common标签 */
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    NSLog(@"%@",[NSRunLoop currentRunLoop]);
    
    
}
- (IBAction)btnClick:(id)sender {
    NSLog(@"btnClick");
}
- (void)task
{
    NSLog(@"task-------%@",[NSRunLoop currentRunLoop].currentMode);
}
- (void)observer
{
    //1.创建监听观察者----因为比较底层不能使用OC语言，要C语言
    //这个使用函数方式回调
//    CFRunLoopObserverCreate(<#CFAllocatorRef allocator#>, <#CFOptionFlags activities#>, <#Boolean repeats#>, <#CFIndex order#>, <#CFRunLoopObserverCallBack callout#>, <#CFRunLoopObserverContext *context#>)
    //这个是用block方式回调---一般用这种
    /*
     参数1：分配存储空间，但我们不知道怎么样分配,可以获取一个默认分配方式的CFAllocatorGetDefault()
     参数2：监听runloop状态类型
     参数3：是否要持续监听
     参数4：优先级相关
     参数5：当监听到runloop状态改变时候会执行block任务
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(),kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        //activity runloop状态
        
        /*
        kCFRunLoopEntry = (1UL << 0),  runloop启动
        kCFRunLoopBeforeTimers = (1UL << 1),  即将开始处理定时器事件
        kCFRunLoopBeforeSources = (1UL << 2), 即将开始处理sources事件
        kCFRunLoopBeforeWaiting = (1UL << 5), 即将进入休眠
        kCFRunLoopAfterWaiting = (1UL << 6),  休眠被唤醒
        kCFRunLoopExit = (1UL << 7),          runloop退出
        kCFRunLoopAllActivities = 0x0FFFFFFFU  状态
        */
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"runloop启动");
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"即将开始处理定时器事件");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"即将开始处理sorces事件");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"即将进入休眠");
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"休眠被唤醒");
            case kCFRunLoopExit:
                NSLog(@"runloop退出");
                break;
                
            default:
                break;
        }
        
    });
    
    //2.监听runloop
    /*
     参数1：要监听哪个runloop
     参数2：哪个监听者
     参数3：模式，这里不能传UITrackingRunLoopMode，因为
     */
    //kCFRunLoopDefaultMode == NSFRunLoopDefaultMode
    //kCFRunLoopCommonModes == NSRunLoopCommonModes
    
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    
//    CFRelease(observer);
}


@end
