//
//  MainViewController.m
//  Cards
//
//  Created by Alfred Hanssen on 3/22/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "BaseViewController.h"
#import "FirstViewController.h"
#import "InteractiveTransition.h"

@interface BaseViewController ()

@property (nonatomic, strong) InteractiveTransition *interactiveTransition;

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    BOOL shouldAllowRotation = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        shouldAllowRotation = NO;
    }
    
    return shouldAllowRotation;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark

- (IBAction)didTapButton:(id)sender
{
    FirstViewController *viewController = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    self.interactiveTransition = [[InteractiveTransition alloc] initWithViewController:self];
    viewController.transitioningDelegate = self.interactiveTransition;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
