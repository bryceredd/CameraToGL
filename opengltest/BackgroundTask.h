//
//  BackgroundTask.h
//  opengltest
//
//  Created by Bryce Redd on 11/14/16.
//  Copyright © 2016 Bryce Redd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundTask : NSObject
@property (nonatomic) BOOL isProcessing;
- (void)run:(void(^)(float))complete;
@end
