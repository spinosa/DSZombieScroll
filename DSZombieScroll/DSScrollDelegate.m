//
//  DSScrollDelegate.m
//  DSZombieScroll
//
//  Created by Daniel Spinosa on 10/25/13.
//  Copyright (c) 2013 SETEC ASTRONOMY. All rights reserved.
//

#import "DSScrollDelegate.h"

@implementation DSScrollDelegate

- (void)dealloc
{
    NSLog(@"*** dealloc of scroll delegate ***");
}

#pragma mark - UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrolled to %@", NSStringFromCGPoint(scrollView.contentOffset));
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"scrolling animation ended at %@", NSStringFromCGPoint(scrollView.contentOffset));
}

@end
