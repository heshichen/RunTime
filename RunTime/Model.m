




//
//  Model.m
//  RunTime
//
//  Created by heshichen on 16/9/12.
//  Copyright © 2016年 heshichen. All rights reserved.
//

#import "Model.h"
#import <objc/runtime.h>

@interface Model()
{
    NSString *address;
}
@end

@implementation Model

void runAddMethod(id self, SEL _cmd, NSString *string)
{
    NSLog(@"add C IMP %@",string);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    //给本类动态添加一个方法
    if ([NSStringFromSelector(sel) isEqualToString:@"resolveAdd:"]) {
        class_addMethod(self, sel, (IMP)runAddMethod, "v@:*");
    }
    
    return YES;
}

//添加关联对象
- (void)addAssociatedObject:(id)object{
    objc_setAssociatedObject(self, @selector(getAssociatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
//获取关联对象
- (id)getAssociatedObject{
    ;
    return objc_getAssociatedObject(self, _cmd);
}

@end
