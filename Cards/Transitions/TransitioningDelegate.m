//
//  TransitioningDelegate.m
//  Cards
//
//  Created by Alfred Hanssen on 3/22/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "TransitioningDelegate.h"
#import "Animator.h"

@implementation TransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{    
    Animator *animator = [Animator new];
    animator.presenting = YES;
    
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    Animator *animator = [Animator new];
    
    return animator;
}

@end
