//
//  Animator.m
//  Cards
//
//  Created by Alfred Hanssen on 3/22/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "Animator.h"

static const CGFloat AnimationDuration = 0.35f;

@implementation Animator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return AnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting)
    {
        CGRect endFrame = fromViewController.view.frame;
        
        CGRect startFrame = endFrame;
        startFrame.origin.y += fromViewController.view.bounds.size.height;
        
        fromViewController.view.userInteractionEnabled = NO;
        toViewController.view.frame = startFrame;

        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            toViewController.view.frame = endFrame;
        
        } completion:^(BOOL finished) {
        
            [transitionContext completeTransition:YES];
        
        }];
    }
    else
    {
        toViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        CGRect endFrame = fromViewController.view.frame;
        endFrame.origin.y += fromViewController.view.frame.size.height;

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            fromViewController.view.frame = endFrame;
        
        } completion:^(BOOL finished) {
        
            [transitionContext completeTransition:YES];
        
        }];
    }
}

@end
