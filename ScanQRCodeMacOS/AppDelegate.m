//
//  AppDelegate.m
//  ScanQRCodeMacOS
//
//  Created by qiang on 2021/6/14.
//

#import "AppDelegate.h"
#import <AppKit/AppKit.h>
#import "Utils.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<NSMenuDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSStatusItem *scanCodeItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    // Do any additional setup after loading the view.
    self.scanCodeItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *image = [NSImage imageNamed:@"scan"];
    [self.scanCodeItem.button setImage:image];
    self.scanCodeItem.button.action = @selector(mouseDownAction);
    [self.scanCodeItem.button sendActionOn:NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown];
    self.scanCodeItem.button.target = self;

//    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown handler:^(NSEvent * _Nonnull event) {
//        if (event.type == NSEventTypeLeftMouseDown || event.type == NSEventTypeRightMouseDown) {
//            self.scanCodeItem.button.state = NSControlStateValueOff;
//        }
//    }];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(foundQRCodeWithNoti:) name:@"NOTIFY_FOUND_QR_CODE" object:nil];
    
    // 请求通知权限
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            NSLog(@"用户未授权通知");
        }
    }];
}

- (void)mouseDownAction {
    NSEvent *event = NSApp.currentEvent;
    if (event.type == NSEventTypeLeftMouseDown) {
        [self scanQRCodeAction];
    } else if (event.type == NSEventTypeRightMouseDown) {
        [self extraAction];
    }
}

- (void)scanQRCodeAction {
    [Utils scanQRCodeOnScreen];
}

- (void)extraAction {
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"关于" action:@selector(aboutAction) keyEquivalent:@""];
    [menu addItemWithTitle:@"退出" action:@selector(quitAction) keyEquivalent:@""];
    [self.scanCodeItem setMenu:menu];
}

- (void)aboutAction {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"http://yuqiangcoder.com"]];
}

- (void)quitAction {
    [NSApp terminate:nil];
}

- (void)foundQRCodeWithNoti:(NSNotification *)noti {
    NSLog(@"noti = %@", noti);
    NSArray <NSString *>*message = noti.userInfo[@"message"];
    
    // 创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"二维码扫描结果";
    content.sound = [UNNotificationSound defaultSound];
    
    if (message.count) {
        // 将识别到的内容复制到剪贴板
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, nil] owner:nil];
        NSString *joinedString = [message componentsJoinedByString:@"\n"];
        BOOL isSuccess = [pasteboard setString:joinedString forType:NSPasteboardTypeString];
        content.body = joinedString;
    } else {
        content.body = @"未识别到二维码";
    }
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"QRCodeNotification" content:content trigger:nil];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {}];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)menuDidClose:(NSMenu *)menu {
    self.scanCodeItem.button.highlighted = NO;
    self.scanCodeItem.button.state = NSControlStateValueOff;
}

#pragma mark - UNUserNotificationCenterDelegate

// 在应用处于前台时也显示通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    // 设置通知在前台时的展示方式
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

@end
