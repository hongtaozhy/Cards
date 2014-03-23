//
//  FollowingViewController.m
//  Cards
//
//  Created by Alfred Hanssen on 3/23/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "FollowingViewController.h"
#import "CardStyle.h"

@interface FollowingViewController ()

@property (nonatomic, weak) IBOutlet UIView *contentView;

@end

@implementation FollowingViewController

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

#pragma mark - Setup

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackground:)];
    [self.view addGestureRecognizer:tapRecognizer];
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

@end
