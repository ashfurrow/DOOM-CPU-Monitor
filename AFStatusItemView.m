//
//  AFStatusItemView.m
//  Doom CPU Monitor
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "AFStatusItemView.h"

@implementation AFStatusItemView

-(void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedRed:1.0f green:0.0f blue:0.0f alpha:self.alpha] set];
    NSRectFill(dirtyRect);
}

-(void)mouseDown:(NSEvent *)theEvent
{
    
}

-(void)mouseUp:(NSEvent *)theEvent
{
    [AppDelegate openMenu];
}

@end
