//
//  AFStatusItemView.h
//  Doom CPU Monitor
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const NSUInteger kMaxDangerLevel;

@interface AFStatusItemView : NSView

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) NSUInteger dangerLevel;

@end
