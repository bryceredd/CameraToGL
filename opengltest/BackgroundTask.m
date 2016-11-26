//
//  BackgroundTask.m
//  opengltest
//
//  Created by Bryce Redd on 11/14/16.
//  Copyright © 2016 Bryce Redd. All rights reserved.
//

#import "BackgroundTask.h"

@implementation BackgroundTask
{
  dispatch_queue_t _queue;
}

- (instancetype)init
{
  if (self = [super init]) {
    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
    _queue = dispatch_queue_create("com.facebook.backgroundtask", attr);
  }
  return self;
}

- (void)run:(void(^)(float))complete
{
  static const int samplesPerAverage = 10;
  static int count;
  static float num;
  static float times[samplesPerAverage];
  count++;
  dispatch_async(_queue, ^{
    @synchronized(self) {
      if (_isProcessing) {
        return;
      }
      _isProcessing = YES;
    }
    NSDate *start = [NSDate date];
    for (int i = 1; i < 5000000; i++) {
      num += sqrt(i);
    }
    @synchronized (self) {
      _isProcessing = NO;
    }
    times[count % samplesPerAverage] = [start timeIntervalSinceNow];
    float totalTime = 0;
    for (int i = 0; i < samplesPerAverage; i++) {
      totalTime += times[i];
    }
    complete(totalTime / (float)samplesPerAverage);
  });
}


@end
