//
//  DynamicInteractiveTransition.m
//  Cards
//
//  Created by Hanssen, Alfie on 3/26/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "DynamicInteractiveTransition.h"

static const CGFloat AnimationDuration = 0.30f;

@interface DynamicInteractiveTransition () <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIDynamicAnimatorDelegate>

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, assign) CGFloat lastPercentComplete; // We shouldn't need this, but self.percentComplete is always 0 [AH]

@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation DynamicInteractiveTransition

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
    if (self.isInteractive)
    {
        return self;
    }
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    if (self.isInteractive)
    {
        return self;
    }
    
    return nil;
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
    UIView *containerView = transitionContext.containerView;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:transitionContext.containerView];
    self.animator.delegate = self;
    
    if (self.isPresenting)
    {
        fromViewController.view.userInteractionEnabled = NO;
        
        toViewController.view.frame = [self rectForDismissedState:transitionContext];
        [containerView addSubview:toViewController.view];
        
        
        UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[toViewController.view]];
        [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -1.0f * CGRectGetWidth(transitionContext.containerView.bounds), 0, 0)];
        
        UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[toViewController.view]];
        gravityBehaviour.gravityDirection = CGVectorMake(0.0f, 5.0f);
        
        UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[toViewController.view]];
        itemBehaviour.elasticity = 0.5f;
        
        [self.animator addBehavior:collisionBehaviour];
        [self.animator addBehavior:gravityBehaviour];
        [self.animator addBehavior:itemBehaviour];
        
//        
//        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//            
//            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
//            toViewController.view.frame = [self rectForPresentedState:transitionContext];
//            
//        } completion:^(BOOL finished) {
//            
//            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//            
//        }];
    }
    else
    {
        toViewController.view.userInteractionEnabled = YES;

        UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[fromViewController.view]];
        [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -CGRectGetWidth(transitionContext.containerView.bounds), 0, 0)];
        
        UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[fromViewController.view]];
        gravityBehaviour.gravityDirection = CGVectorMake(0.0f, -5.0f);
        
        UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[fromViewController.view]];
        itemBehaviour.elasticity = 0.5f;
        
        [self.animator addBehavior:collisionBehaviour];
        [self.animator addBehavior:gravityBehaviour];
        [self.animator addBehavior:itemBehaviour];
        
//        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//            
//            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
//            fromViewController.view.frame = [self rectForDismissedState:transitionContext];
//            
//        } completion:^(BOOL finished) {
//            
//            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//            [fromViewController.view.superview removeFromSuperview];
//            
//        }];
    }
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    fromViewController.view.userInteractionEnabled = YES;
    toViewController.view.userInteractionEnabled = YES;
    
    self.interactive = NO;
    self.presenting = NO;
    self.viewController = nil;
    self.transitionContext = nil;
    
    [self.animator removeAllBehaviors];
    self.animator.delegate = nil;
    self.animator = nil;
}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
//    if (!self.interactiveTransitionInteracting)
//    {
        [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
//    }
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

#pragma mark - Percent Driven Gesture

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
        percent = fmaxf(0.0f, percent); // Clamp values in the event of fast pan
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

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    self.lastPercentComplete = percentComplete;
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    fromViewController.view.frame = [self rectForPresentedState:transitionContext percentComplete:percentComplete];
}

- (void)finishInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.userInteractionEnabled = YES;
    toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    
    [UIView animateWithDuration:[self completionSpeed] animations:^{
        
        fromViewController.view.frame = [self rectForDismissedState:transitionContext];
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
    }];
}

- (void)cancelInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:[self completionSpeed] animations:^{
        
        fromViewController.view.frame = [self rectForPresentedState:transitionContext];
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:NO];
        
    }];
}

#pragma mark - Utilities

// These are necessary because containerView is always portrait orientation (doesn't respect rotation changes)
// http://stackoverflow.com/questions/20013929/workaround-for-custom-uiviewcontroller-animations-in-landscape
// http://www.brightec.co.uk/blog/ios-7-custom-view-controller-transitions-and-rotation-making-it-all-work

- (CGRect)rectForDismissedState:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = nil;
    
    if (self.isPresenting)
    {
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    }
    else
    {
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    
    CGRect frame = CGRectZero;
    
    switch (fromViewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            frame = CGRectMake(-containerView.bounds.size.width,
                               0,
                               containerView.bounds.size.width,
                               containerView.bounds.size.height);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            frame = CGRectMake(containerView.bounds.size.width,
                               0,
                               containerView.bounds.size.width,
                               containerView.bounds.size.height);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            frame = CGRectMake(0,
                               -containerView.bounds.size.height,
                               containerView.bounds.size.width,
                               containerView.bounds.size.height);
            break;
            
        case UIInterfaceOrientationPortrait:
            frame = CGRectMake(0,
                               containerView.bounds.size.height,
                               containerView.bounds.size.width,
                               containerView.bounds.size.height);
            break;
            
        default:
            break;
    }
    
    return frame;
}


- (CGRect)rectForPresentedState:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = nil;
    
    if (self.isPresenting)
    {
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    }
    else
    {
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    
    CGRect frame = CGRectZero;
    
    switch (fromViewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            frame = CGRectOffset([self rectForDismissedState:transitionContext], containerView.bounds.size.width, 0);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            frame = CGRectOffset([self rectForDismissedState:transitionContext], -1.0f * containerView.bounds.size.width, 0);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            frame = CGRectOffset([self rectForDismissedState:transitionContext], 0, containerView.bounds.size.height);
            break;
            
        case UIInterfaceOrientationPortrait:
            frame = CGRectOffset([self rectForDismissedState:transitionContext], 0, -1.0f * containerView.bounds.size.height);
            break;
            
        default:
            break;
    }
    
    return frame;
}

- (CGRect)rectForPresentedState:(id<UIViewControllerContextTransitioning>)transitionContext percentComplete:(CGFloat)percentComplete
{
    UIViewController *fromViewController = nil;
    if (self.isPresenting)
    {
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    }
    else
    {
        fromViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    
    CGRect frame = [self rectForPresentedState:transitionContext];
    
    switch (fromViewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            frame = CGRectOffset(frame, -1.0f * CGRectGetWidth(frame) * percentComplete, 0.0f);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            frame = CGRectOffset(frame, CGRectGetWidth(frame) * percentComplete, 0.0f);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            frame = CGRectOffset(frame, 0.0f, -1.0f * CGRectGetHeight(frame) * percentComplete);
            break;
            
        case UIInterfaceOrientationPortrait:
            frame = CGRectOffset(frame, 0.0f, CGRectGetHeight(frame) * percentComplete);
            break;
            
        default:
            break;
    }
    
    return frame;
}

@end
