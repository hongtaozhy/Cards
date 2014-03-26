
//  InteractiveTransition.m
//  Cards
//
//  Created by Alfred Hanssen on 3/23/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "InteractiveTransition.h"

static const CGFloat AnimationDuration = 0.35f;

@interface InteractiveTransition () <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, assign) CGFloat lastPercentComplete;

@end

@implementation InteractiveTransition

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        _viewController = viewController;
    }
    
    return self;
}

#pragma mark - Transitioning Delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.presenting = YES;
    
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.presenting = NO;
    
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    if (self.interactive)
    {
        return self;
    }
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    if (self.interactive)
    {
        return self;
    }
    
    return nil;
}

#pragma mark - Transitioning

- (void)animationEnded:(BOOL)transitionCompleted
{
    self.interactive = NO;
    self.presenting = NO;
    if (self.interactive)
    {
        self.viewController = nil;
    }
    self.transitionContext = nil;
}

#pragma mark - Animated Transitioning

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
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            toViewController.view.frame = endFrame;
            
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            
        }];
    }
    else
    {
        toViewController.view.userInteractionEnabled = YES;
        
        CGRect endFrame = fromViewController.view.frame;
        endFrame.origin.y += fromViewController.view.frame.size.height;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            fromViewController.view.frame = endFrame;
            
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            
        }];
    }
}

#pragma mark - Gesture Recognizer

- (void)didPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.interactive = YES;
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat percent = translation.y / recognizer.view.bounds.size.height;
        percent = fmaxf(0.0f, percent);
        percent = fminf(1.0f, percent);
        [self updateInteractiveTransition:percent];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (velocity.y > 0)
        {
            [self finishInteractiveTransition];
        }
        else
        {
            [self cancelInteractiveTransition];
        }
    }
}

#pragma mark - Interactive Transitioning

- (CGFloat)completionSpeed
{
    return [self transitionDuration:self.transitionContext] * (1.0f - self.lastPercentComplete);
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
}

#pragma mark

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    self.lastPercentComplete = percentComplete;
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect bounds = transitionContext.containerView.bounds;
    bounds = CGRectOffset(bounds, 0, CGRectGetHeight(bounds) * percentComplete);
    fromViewController.view.frame = bounds;
}

- (void)finishInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.userInteractionEnabled = YES;
    toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;

    CGRect endFrame = transitionContext.containerView.bounds;
    endFrame.origin.y += endFrame.size.height;

    [UIView animateWithDuration:[self completionSpeed] animations:^{
   
        fromViewController.view.frame = endFrame;
    
    } completion:^(BOOL finished) {
    
        [transitionContext completeTransition:YES];
        
    }];
}

- (void)cancelInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect endFrame = transitionContext.containerView.bounds;

    [UIView animateWithDuration:[self completionSpeed] animations:^{
    
        fromViewController.view.frame = endFrame;
    
    } completion:^(BOOL finished) {
    
        [transitionContext completeTransition:NO];
        
    }];
}


@end
