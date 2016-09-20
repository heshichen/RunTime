//
//  Model.h
//  RunTime
//
//  Created by heshichen on 16/9/12.
//  Copyright © 2016年 heshichen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger age;
//- (void)chanageName:(NSString *)name;

- (void)addAssociatedObject:(id)object;
//获取关联对象
- (id)getAssociatedObject;


@end
