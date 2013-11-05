//
//  DSViewController.m
//  DSZombieScroll
//
//  Created by Daniel Spinosa on 10/25/13.
//  Copyright (c) 2013 SETEC ASTRONOMY. All rights reserved.
//

#import "DSViewController.h"
#import "DSScrollDelegate.h"
#import "DSScrollView.h"

@interface DSViewController ()
@property (nonatomic, strong) UIScrollView *scroller;
@property (nonatomic, strong) DSScrollDelegate *scrollViewDelegate;
@property (weak, nonatomic) IBOutlet UIButton *runButton;

@end

@implementation DSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)runTheTests:(id)sender {
    self.runButton.enabled = NO;

    // Test 1
    // Add Scroller & Delegate
    [self setupScrollerAndDelegate];
    // Set content offset without animation, immediately nil scroller then delegate
    [self.runButton setTitle:@"Test 1..." forState:UIControlStateDisabled];
    [self scrollAnimated:NO nilScrollView:YES nilDelegate:YES];

    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        // Test 2
        // Add Scroller & Delegate
        [self setupScrollerAndDelegate];
        // Set content offset *with* animation
        // nil the scroll view but not the delegate
        [self.runButton setTitle:@"Test 2..." forState:UIControlStateDisabled];
        [self scrollAnimated:YES nilScrollView:YES nilDelegate:NO];

        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            // Test 3
            // Add Scroller & Delegate
            [self setupScrollerAndDelegate];
            // Set content offset *with* animation
            // do not nil the scroll view, do nil the delegate
            // watch out for zombies!
            [self.runButton setTitle:@"Deadly Test 3..." forState:UIControlStateDisabled];
            [self scrollAnimated:YES nilScrollView:NO nilDelegate:YES];
            [self.runButton setTitle:@"Test 3 Passed?" forState:UIControlStateDisabled];
            // PS - the same bug is encountered even if you nil the scroll view!
            
        });
        
    });
}

- (void)scrollAnimated:(BOOL)animated nilScrollView:(BOOL)shouldNilScrollView nilDelegate:(BOOL)shouldNilDelegate
{
    NSLog(@">> scrolling to bottom, animated ? %@", animated ? @"YES" : @"NO");
    [self.scroller setContentOffset:CGPointMake(0, self.view.bounds.size.height * 99)
                           animated:animated];

    if (shouldNilScrollView) {
        /*
         * We expect the ScrollView to be deallocated by ARC when our (one and only) reference to it is nil'd.
         * Interestingly, if a ScrollView is in the middle of a programatic animation, it is retained by
         * some participant in that animation and the deallocation is delayed.  You can easily confirm this by
         * observing the order of the logging.
         *
         */
        if (animated) {
            NSLog(@"                                        *** delayed dealloc of ScrollView expected ***");
        }

        NSLog(@">> removing ScrollView...");
        [self.scroller removeFromSuperview];
        self.scroller = nil;
        //ARC should dealloc scroller (we hold the only strong reference we know of)
        NSLog(@">> ScrollView nil'd");
    } else {
        NSLog(@">> [not removing ScrollView]");
    }

    if (shouldNilDelegate) {
        /*
         * If the ScrollView's delegate is nil'd while the animation is still running, we expect the
         * ScrollView's weak pointer to be set to nil by ARC.  But, somehow the ScrollView still holds 
         * a a dangling pointer to the delegate which it then referenes causing a EXC_BAD_ACCESS exception.
         *
         */
        if (animated) {
            NSLog(@"                                        *** EXC_BAD_ACCESS Expected ***");
        }

        NSLog(@">> removing ScrollViewDelegate...");
        self.scrollViewDelegate = nil;
        //ARC should dealloc the delegate and set weak pointers to nil
        NSLog(@">> ScrollViewDelegate nil'd");
    } else {
        NSLog(@">> [not removing ScrollViewDelegate]");
    }
}

- (void)setupScrollerAndDelegate
{
    NSLog(@"\n\n\n--------------------------------------------------------------------\n\n\n");
    NSLog(@"CLEAN UP...");
    self.scroller = nil;
    self.scrollViewDelegate = nil;

    NSLog(@"SETUP...");
    self.scroller = [[DSScrollView alloc] initWithFrame:self.view.bounds];
    self.scroller.backgroundColor = [UIColor redColor];
    self.scroller.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 100);
    [self.view addSubview:self.scroller];
    self.scrollViewDelegate = [[DSScrollDelegate alloc] init];
    self.scroller.delegate = self.scrollViewDelegate;
}

@end
