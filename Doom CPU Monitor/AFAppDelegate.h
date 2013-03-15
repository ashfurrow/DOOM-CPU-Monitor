//
//  AFAppDelegate.h
//  Doom CPU Monitor
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BCStatusItemView.h>
#import <NSStatusItem+BCStatusItem.h>

@interface AFAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (nonatomic, assign) NSUInteger dangerLevel;

@property (strong) NSStatusItem *statusItem;
@property (strong) IBOutlet NSMenu *statusMenu;

@end
