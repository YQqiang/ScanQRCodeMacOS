//
//  AppDelegate.m
//  ScanQRCodeMacOS
//
//  Created by qiang on 2021/6/14.
//

#import "AppDelegate.h"
#import <AppKit/AppKit.h>
#import "Utils.h"

@interface AppDelegate ()<NSMenuDelegate>

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
//    [self.scanCodeItem setMenu:menu];
    [self.scanCodeItem popUpStatusItemMenu:menu];
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
    if (message.count) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, nil] owner:nil];
        BOOL isSuccess = [pasteboard setString:[message componentsJoinedByString:@"\n"] forType:NSPasteboardTypeString];
        NSLog(@"%d", isSuccess);
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)menuDidClose:(NSMenu *)menu {
    self.scanCodeItem.button.highlighted = NO;
//    self.scanCodeItem.button.state = NSControlStateValueOff;
}

@end
