//
//  AFStatusItemView.m
//  Doom CPU Monitor
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "AFStatusItemView.h"

const NSUInteger kMaxDangerLevel = 6;

@implementation AFStatusItemView

-(void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    [self setNeedsDisplay:YES];
}

-(void)setDangerLevel:(NSUInteger)dangerLevel
{
    _dangerLevel = dangerLevel;
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect rect = self.bounds;
    
    rect.origin.x = 2;
    rect.origin.y = 2;
    rect.size.width = 17;
    rect.size.height = 19;
    
    if ([self isSelected])
    {
        [[NSColor blueColor] set];
        NSRectFill(self.bounds);
    }
    
    [[NSImage imageNamed:[NSString stringWithFormat:@"%lu", self.dangerLevel]] drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];

}

-(void)mouseUp:(NSEvent *)theEvent
{
    [AppDelegate openMenu];
    
    [self setNeedsDisplay:YES];
}

@end
