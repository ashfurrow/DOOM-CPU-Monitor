//
//  AFAppDelegate.m
//  Doom CPU Monitor
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

#import "AFAppDelegate.h"
#import "AFStatusItemView.h"

@interface AFAppDelegate ()

@property (strong) NSTimer *updateTimer;
@property (strong) NSLock *CPUUsageLock;

@property (strong) AFStatusItemView *statusItemView;

@end

@implementation AFAppDelegate
{
    processor_info_array_t prevCpuInfo;
    processor_info_array_t cpuInfo;
    mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    unsigned numCPUs;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    self.statusItemView = [[AFStatusItemView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    
    [self.statusItem setTitle:@" "];
    [self.statusItem setView:self.statusItemView];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setEnabled:YES];
    
    [self.statusItem setMenu:self.statusMenu];

    [self.statusItem setTarget:self];
    [self.statusItem setAction:@selector(openMenu:)];
    
    self.CPUUsageLock = [[NSLock alloc] init];
    
    
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    if(status)
        numCPUs = 1;
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                    target:self
                                                  selector:@selector(updateInfo:)
                                                  userInfo:nil
                                                   repeats:YES];
    [self updateInfo:nil];
}

-(void)openMenu
{
    [self.statusItem popUpStatusItemMenu:self.statusMenu];
}

// Credit for this solution goes to http://stackoverflow.com/questions/6785069/get-cpu-percent-usage and
// http://stackoverflow.com/questions/6094444/how-can-i-programmatically-check-free-system-memory-on-mac-like-the-activity-mon
- (void)updateInfo:(NSTimer *)timer
{
    CGFloat highestValue = -1;
    natural_t numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    if(err == KERN_SUCCESS) {
        [self.CPUUsageLock lock];
        
        for(unsigned i = 0U; i < numCPUs; ++i) {
            float inUse, total;
            if(prevCpuInfo) {
                inUse = (
                         (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                         );
                total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            CGFloat usage = inUse/total;
            if (highestValue < usage) highestValue = usage;
            
            NSLog(@"Core: %u Usage: %f", i, usage);
        }
        [self.CPUUsageLock unlock];
        
        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
    } else {
        NSLog(@"Error!");
        [NSApp terminate:nil];
    }
    
    NSLog(@"Highest Core Usage: %f", highestValue);
    self.statusItemView.alpha = highestValue;
    
    int mib[6];
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    
    int pagesize;
    size_t length;
    length = sizeof (pagesize);
    if (sysctl (mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        NSLog (@"Error getting page size.");
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics (mach_host_self (), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        NSLog (@"Failed to get VM statistics.");
    }
    
    double total = vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count;
    double wired = vmstat.wire_count / total;
    double active = vmstat.active_count / total;
    double inactive = vmstat.inactive_count / total;
    double free = vmstat.free_count / total;

    
    
//    task_basic_info_64_data_t info;
//    unsigned size = sizeof (info);
//    task_info (mach_task_self (), TASK_BASIC_INFO_64, (task_info_t) &info, &size);
//    
//    double unit = 1024 * 1024;
//    NSLog(@"%@", [NSString stringWithFormat: @"% 3.1f MB\n% 3.1f MB\n% 3.1f MB", vmstat.free_count * pagesize / unit, (vmstat.free_count + vmstat.inactive_count) * pagesize / unit, info.resident_size / unit]);
}

@end
