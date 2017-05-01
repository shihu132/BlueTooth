//
//  ViewController.m
//  BlueTooth
//
//  Created by 石虎 on 2017/5/1.
//  Copyright © 2017年 shihu. All rights reserved.
//

/**
 
 注意: *测试必须要是真机
 *真机设备至少要2台
 *
 
 实现蓝牙的逻辑流程
 
 1. 建立中心管家
 2. 扫描外部设备
 3. 连接外部设备
 4. 扫描服务和特征
 5. 数据交互
 6. 断开连接
 
 
 
 其它网站
 *日历 Calen dome  <https://github.com/shihu132/Calen>
 *蓝牙 BlueTooth  dome  <https://github.com/shihu132/BlueTooth.git>
 作者 石虎: QQ 嗡嘛呢叭咪哄  1224614774
 
 */


#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;//中心管家
@property (nonatomic, strong) CBPeripheral *peripheral;//保存扫描到外部设备
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIView animateWithDuration:2 animations:^{
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.height /2 -50, [UIScreen mainScreen].bounds.size.width, 100)];
        label.text = @"现在扫描蓝牙设备中....";
        label.textColor = [UIColor orangeColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:20.0f];
        [self.view addSubview:label];
    }];
    
    self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil]; // 建立中心管家
}

#pragma mark - 中心管家=代理
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // 在开机状态下才进行扫描外部设备
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil]; // 扫描外部设备
    }
}

#pragma mark - 扫描发现外部设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    //打印 所有扫描的设备
    NSLog(@"peripheral = %@",peripheral);
    self.peripheral = peripheral;//设置全局设备
    self.peripheral.delegate = self; //设置代理为自己
    [self.centralManager connectPeripheral:self.peripheral options:nil];//扫描到的设备
}

#pragma mark - 发现设备 =服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"services = %@", peripheral.services);
    for (CBService *service in peripheral.services) {//遍历所有发现的设备
        // 扫描service 中所有的特征
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}

#pragma mark - 连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.peripheral discoverServices:nil]; // 扫描外部设备的所有服务
    NSLog(@"peripheral connect = %@",peripheral);
}

#pragma mark - 发现设备 =服务里的所有的特征属性
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    //...特征的交互 code
    
    // 打印 扫描特征里面的所有特征描述
    NSLog(@"==service.characteristics==>>>=%@",service.characteristics);
    for (CBCharacteristic *cteristic in service.characteristics) {//遍历所有的特征
        [self.peripheral discoverDescriptorsForCharacteristic:cteristic];//扫描特征里面的所有特征描述
        [self.peripheral readValueForCharacteristic:cteristic];//读取扫描特征
    }
}

#pragma mark - 描述器对应哪一个特征 的 代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //***********..真正.特征的交互 code ***********
    
    //打印 描述其的 特征描述
    NSLog(@"haracteristic.descriptors ==>>>= %@",characteristic.descriptors);
    
    for (CBDescriptor *descriptor in characteristic.descriptors) {//遍历所有的描述特征
        [self.peripheral readValueForDescriptor:descriptor]; // 读取特征描述
    }
}

@end
