//
//  ViewController.m
//  ThreadAnalyze
//
//  Created by yanyw on 2019/5/16.
//  Copyright © 2019 闫跃文. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

// 串行队列同步执行
- (IBAction)serialQueueSynOperate:(id)sender {
    
    NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(test1) object:nil];
    thread.name = @"thread1";
    [thread start];
}

- (void)test1 {
    
    dispatch_queue_t queue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        NSLog(@"task1");
        NSLog(@"task1---%@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"task2");
        NSLog(@"task2---%@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"task3");
        NSLog(@"task3---%@", [NSThread currentThread]);
    });
    
    NSLog(@"task4");
    NSLog(@"task4---%@", [NSThread currentThread]);

    /*
     任务是在当前线程(当前是主线程)顺序执行的。这也验证了
     串行队列同步执行：任务都在当前线程执行（同步），并且顺序执行（串行）
     */
}

- (IBAction)serialQueueAsynOperate:(id)sender {
    
    NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(test2) object:nil];
    thread.name = @"thread2";
    [thread start];
}

- (void)test2 {
    
    dispatch_queue_t queue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSLog(@"task1");
        NSLog(@"task1---%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"task2");
        NSLog(@"task2---%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"task3");
        NSLog(@"task3---%@", [NSThread currentThread]);
    });
    
    NSLog(@"task4");
    NSLog(@"task4---%@", [NSThread currentThread]);
    /*
     主线程异步调用，任务1、2、3，确实都是在开辟了的新线程<NSThread: 0x60000007a9c0>{number = 3, name = (null)}上顺序执行的，关于task4，由于是异步的，它也没加入队列queue，啥时候输出就看电脑心情了...验证结果:
     串行队列异步执行：任务都在开辟的新的子线程中执行（异步），并且顺序执行（串行）
     这里需要注意，由于新创建了串行线程，所以任务会在新开辟的线程上执行，若是直接在主队列异步调用，任务执行都在主线程上。
     */
}

- (IBAction)concurrentQueueSynOperate:(id)sender {
    
    NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(test3) object:nil];
    thread.name = @"thread3";
    [thread start];
}

- (void)test3 {
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        NSLog(@"task1");
        NSLog(@"task1---%@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"task2");
        NSLog(@"task2---%@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"task3");
        NSLog(@"task3---%@", [NSThread currentThread]);
    });
    
    NSLog(@"task4");
    NSLog(@"task4---%@", [NSThread currentThread]);
    
    /*
     任务是在当前线程(是主线程没有开辟新线程)顺序执行的，跟串行同步一样，虽是并发队列，却不能并发。
     验证结果: 并发队列同步执行：任务都在当前线程执行（同步），但是是顺序执行的（并没有体现并发的特性）
     */
}

- (IBAction)concurrentQueueAsynOperate:(id)sender {
    
    NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(test4) object:nil];
    thread.name = @"thread4";
    [thread start];
}

- (void)test4 {
    
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"task1");
        NSLog(@"task1---%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"task2");
        NSLog(@"task2---%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^ {
        NSLog(@"task3");
        NSLog(@"task3---%@", [NSThread currentThread]);
    });
    
    NSLog(@"task4");
    NSLog(@"task4---%@", [NSThread currentThread]);
    
    /*
     task4没有加入队列，所以肯定是在主线程执行的，由于异步，啥时候执行不确定,任务1、2、3 都会开辟新的线程去执行 在不同的线程中无序执行的，体现了并发的特性。
     验证结果：并发队列异步执行：任务在开辟的多个子线程中执行（异步），并且是同时执行的（并发）
     */
}


@end
