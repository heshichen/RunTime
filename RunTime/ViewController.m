//
//  ViewController.m
//  RunTime
//
//  Created by heshichen on 16/9/12.
//  Copyright © 2016年 heshichen. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Model.h"
#import "UIViewController+swizzling.h"

//首先定义一个全局变量，用它的地址作为关联对象的key
static char associatedObjectKey;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self testTarget];
    
    //[self associatedObject];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)test
{
    
    unsigned int count;
    
    //获取属性列表
    objc_property_t *propertyList = class_copyPropertyList([Model class], &count);
    for (unsigned int i=0; i<count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"property---->%@",[NSString stringWithUTF8String:propertyName]);
    }
    
    //获取方法列表
    Method *methodList = class_copyMethodList([Model class], &count);
    for (unsigned int i=0; i<count; i++) {
        Method method = methodList[i];
        NSLog(@"method---->%@",NSStringFromSelector(method_getName(method)));
    }
    
    //获取成员变量列表
    Ivar *ivarList = class_copyIvarList([Model class], &count);
    for (unsigned int i=0; i<count; i++) {
        Ivar ivar = ivarList[i];
        const char *ivarName = ivar_getName(ivar);
        NSLog(@"Ivar---->%@",[NSString stringWithUTF8String:ivarName]);
    }
     
    //获取协议列表
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([Model class], &count);
    for (unsigned int i=0; i<count; i++) {
        Protocol *protocol = protocolList[i];
        const char *protocolName = protocol_getName(protocol);
        NSLog(@"protocol---->%@",[NSString stringWithUTF8String:protocolName]);
    }
     
}

//动态添加方法
- (void)testTarget
{
    Model *entity = [[Model alloc]init];
    
    //[entity performSelector:@selector(resolveAdd:) withObject:@"test"];
}


- (void)associatedObject
{
    Model *entity = [[Model alloc]init];
    //设置关联对象
    objc_setAssociatedObject(entity, &associatedObjectKey, @"关联对象测试", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *string = objc_getAssociatedObject(entity, &associatedObjectKey);
    NSLog(@"AssociatedObject=%@",string);
    
    [entity addAssociatedObject:@"天气好"];
    string = [entity getAssociatedObject];
    NSLog(@"AssociatedObject=%@",string);
}

- (IBAction)push:(id)sender {
    
    NSDictionary *userInfo = @{
                               @"class": @"SecondViewController",
                               @"property": @{
                                       @"ID": @"123",
                                       @"type": @"12"
                                       }
                               };
    [self pushsss:userInfo];
}

- (void)pushsss:(NSDictionary *)params
{
    // 类名
    NSString *class =[NSString stringWithFormat:@"%@", params[@"class"]];
    const char *className = [class cStringUsingEncoding:NSASCIIStringEncoding];
    // 从一个字串返回一个类
    Class newClass = objc_getClass(className);
    if (!newClass)
    {
        // 创建一个类
        Class superClass = [NSObject class];
        newClass = objc_allocateClassPair(superClass, className, 0);
        // 注册你创建的这个类
        objc_registerClassPair(newClass);
    }
    // 创建对象
    id instance = [[newClass alloc] init];
    // 对该对象赋值属性
    NSDictionary * propertys = params[@"property"];
    [propertys enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // 检测这个对象是否存在该属性
        if ([self checkIsExistPropertyWithInstance:instance verifyPropertyName:key]) {
            // 利用kvc赋值
            [instance setValue:obj forKey:key];
        }
    }];
    
    // 跳转到对应的控制器
    [self.navigationController
     pushViewController:instance animated:YES];
}

- (BOOL)checkIsExistPropertyWithInstance:(id)instance verifyPropertyName:(NSString *)verifyPropertyName
{
    unsigned int outCount, i;
    // 获取对象里的属性列表
    objc_property_t * properties = class_copyPropertyList([instance
                                                           class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property =properties[i];
        //  属性名转成字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        // 判断该属性是否存在
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    return NO;
}

@end
