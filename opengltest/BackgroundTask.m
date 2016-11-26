//
//  BackgroundTask.m
//  opengltest
//
//  Created by Bryce Redd on 11/14/16.
//  Copyright © 2016 Bryce Redd. All rights reserved.
//

#import "BackgroundTask.h"

static const int kSamplesPerAverage = 10;

static float average(float *nums, int length) {
  float totalTime = 0;
  for (int i = 0; i < length; i++) {
    totalTime += nums[i];
  }
  return totalTime / (float)length;
}

@implementation BackgroundTask
{
  dispatch_queue_t _queue;
  int _count;
  float _times[kSamplesPerAverage];

  // Keep the garbage value around so the compiler doesn't optimize it out
  float _num;
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
  _count++;
  dispatch_async(_queue, ^{
    NSDate *start = [NSDate date];
    for (int i = 1; i < 5000000; i++) {
      _num += sqrt(i);
    }
    _times[_count % kSamplesPerAverage] = [start timeIntervalSinceNow];
    complete(average(_times, kSamplesPerAverage));
  });
}


@end
