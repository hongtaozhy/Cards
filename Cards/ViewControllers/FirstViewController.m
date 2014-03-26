//
//  FirstViewController.m
//  Cards
//
//  Created by Alfred Hanssen on 3/22/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "InteractiveTransition.h"
#import "CardStyle.h"

@interface FirstViewController ()

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, strong) InteractiveTransition *interactiveTransition;

@end

@implementation FirstViewController

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
    
    [self setupGestureRecognizers];
    [self setupContentView];
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

#pragma mark - Setup

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackground:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitioningDelegate action:@selector(didPan:)];
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)setupContentView
{
    self.contentView.layer.cornerRadius = CornerRadius;
    self.contentView.layer.shadowOffset = ShadowOffset;
    self.contentView.layer.shadowRadius = ShadowRadius;
    self.contentView.layer.shadowOpacity = ShadowOpacity;
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.contentView.layer.shouldRasterize = YES;
}

#pragma mark

- (void)didTapBackground:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    if (!CGRectContainsPoint(self.contentView.frame, location))
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)didTapButton:(id)sender
{
    SecondViewController *viewController = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    self.interactiveTransition = [[InteractiveTransition alloc] initWithViewController:self];
    viewController.transitioningDelegate = self.interactiveTransition;

    [self presentViewController:viewController animated:YES completion:nil];
}

@end
