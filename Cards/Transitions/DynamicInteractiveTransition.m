//
//  DynamicInteractiveTransition.m
//  Cards
//
//  Created by Hanssen, Alfie on 3/26/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "DynamicInteractiveTransition.h"

static const CGFloat AnimationDuration = 0.30f;
static const CGFloat Gravity = 20.0f;
static const CGFloat Elasticity = 0.15f;

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
    self.transitionContext = transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *dynamicViewController = nil;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:transitionContext.containerView];
    self.animator.delegate = self;
    
    if (self.isPresenting)
    {
        fromViewController.view.userInteractionEnabled = NO;
        dynamicViewController = toViewController;
        
        toViewController.view.frame = [self rectForDismissedState:transitionContext];
        [transitionContext.containerView addSubview:toViewController.view];
        
//        toViewController.view.frame = [self rectForPresentedState:transitionContext];
    }
    else
    {
        toViewController.view.userInteractionEnabled = YES;
        dynamicViewController = fromViewController;
        
//        fromViewController.view.frame = [self rectForDismissedState:transitionContext];
    }
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[dynamicViewController.view]];
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:[self collisionInsets:transitionContext]];
    
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[dynamicViewController.view]];
    gravityBehaviour.gravityDirection = [self gravityVector:transitionContext];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[dynamicViewController.view]];
    itemBehaviour.elasticity = Elasticity;
    
    [self.animator addBehavior:collisionBehaviour];
    [self.animator addBehavior:gravityBehaviour];
    [self.animator addBehavior:itemBehaviour];
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    NSLog(@"ANIMATION ENDED");
    
   id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    fromViewController.view.userInteractionEnabled = YES;
    toViewController.view.userInteractionEnabled = YES;
        
    self.interactive = NO;
    self.presenting = NO;
    self.transitionContext = nil;
    
    [self.animator removeAllBehaviors];
    self.animator.delegate = nil;
    self.animator = nil;
}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    NSLog(@"ANIMATION PAUSE");
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
}

#pragma mark - Interactive Transitioning

- (CGFloat)completionSpeed
{
    NSLog(@"COMPLETEION SPEED %.2f", [self transitionDuration:self.transitionContext] * (1.0f - self.lastPercentComplete));
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
    UIViewController *viewController = nil;
    
    if (self.isPresenting)
    {
        viewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    }
    else
    {
        viewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    
    CGRect frame = CGRectZero;
    
    switch (viewController.interfaceOrientation)
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
    UIViewController *viewController = nil;
    if (self.isPresenting)
    {
        viewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    }
    else
    {
        viewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    
    CGRect frame = [self rectForPresentedState:transitionContext];
    
    switch (viewController.interfaceOrientation)
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

- (UIEdgeInsets)collisionInsets:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (self.isPresenting)
    {
        insets = [self collisionInsetsForPresentation:transitionContext];
    }
    else
    {
        insets = [self collisionInsetsForDismissal:transitionContext];
    }
    
    return insets;
}

- (UIEdgeInsets)collisionInsetsForPresentation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    switch (viewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            insets = UIEdgeInsetsMake(0, -1.0f * CGRectGetWidth(transitionContext.containerView.bounds), 0, 0);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            insets = UIEdgeInsetsMake(0, 0, 0, -1.0f * CGRectGetWidth(transitionContext.containerView.bounds));
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            insets = UIEdgeInsetsMake(-1.0f * CGRectGetHeight(transitionContext.containerView.bounds), 0, 0, 0);
            break;
            
        case UIInterfaceOrientationPortrait:
            insets = UIEdgeInsetsMake(0, 0, -1.0f * CGRectGetHeight(transitionContext.containerView.bounds), 0);
            break;
            
        default:
            break;
    }
    
    return insets;
}

- (UIEdgeInsets)collisionInsetsForDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    switch (viewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            insets = UIEdgeInsetsMake(0, -1.0f * CGRectGetWidth(transitionContext.containerView.bounds), 0, 0);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            insets = UIEdgeInsetsMake(0, 0, 0, -1.0f * CGRectGetWidth(transitionContext.containerView.bounds));
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            insets = UIEdgeInsetsMake(-1.0f * CGRectGetHeight(transitionContext.containerView.bounds), 0, 0, 0);
            break;
            
        case UIInterfaceOrientationPortrait:
            insets = UIEdgeInsetsMake(0, 0, -1.0f * CGRectGetHeight(transitionContext.containerView.bounds), 0);
            break;
            
        default:
            break;
    }
    
    return insets;
}

- (CGVector)gravityVector:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CGVector vector = CGVectorMake(0.0f, 0.0f);
    
    if (self.isPresenting)
    {
        vector = [self gravityVectorForPresentation:transitionContext];
    }
    else
    {
        vector = [self gravityVectorForDismissal:transitionContext];
    }
    
    return vector;
}

- (CGVector)gravityVectorForPresentation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CGVector vector = CGVectorMake(0.0f, 0.0f);
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    switch (viewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            vector = CGVectorMake(Gravity, 0.0f);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            vector = CGVectorMake(-Gravity, 0.0f);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            vector = CGVectorMake(0.0f, Gravity);
            break;
            
        case UIInterfaceOrientationPortrait:
            vector = CGVectorMake(0.0f, -Gravity);
            break;
            
        default:
            break;
    }
    
    return vector;
}

- (CGVector)gravityVectorForDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CGVector vector = CGVectorMake(0.0f, 0.0f);
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    switch (viewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            vector = CGVectorMake(-Gravity, 0.0f);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            vector = CGVectorMake(Gravity, 0.0f);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            vector = CGVectorMake(0.0f, -Gravity);
            break;
            
        case UIInterfaceOrientationPortrait:
            vector = CGVectorMake(0.0f, Gravity);
            break;
            
        default:
            break;
    }
    
    return vector;
}

@end
