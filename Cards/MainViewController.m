//
//  MainViewController.m
//  Cards
//
//  Created by Alfred Hanssen on 3/22/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "MainViewController.h"
#import "ProfileViewController.h"
#import "TransitioningDelegate.h"

@interface MainViewController ()

@property (nonatomic, strong) TransitioningDelegate *transitioningDelegate;

@end

@implementation MainViewController

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
    
    self.transitioningDelegate = [TransitioningDelegate new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark

- (IBAction)didTapProfile:(id)sender
{
    ProfileViewController *viewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    viewController.transitioningDelegate = self.transitioningDelegate;
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
