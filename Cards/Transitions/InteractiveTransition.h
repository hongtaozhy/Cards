//
//  InteractiveTransition.h
//  Cards
//
//  Created by Alfred Hanssen on 3/23/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InteractiveTransition : UIPercentDrivenInteractiveTransition <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIViewController *viewController;

- (void)didPan:(UIPanGestureRecognizer *)recognizer;

@end
