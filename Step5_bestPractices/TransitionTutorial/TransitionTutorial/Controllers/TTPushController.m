//
//  TTNavigationController.m
//  TransitionTutorial
//
//  Created by Brad Bambara on 4/14/14.
//  Copyright (c) 2014 Brad Bambara. All rights reserved.
//

#import "TTPushController.h"
#import "TTPushAnimator.h"
#import "TTPopAnimator.h"

@interface TTPushController ()

@property (nonatomic, strong) TTInteractivePinchTransition* transition;
@property (nonatomic, strong) UIPinchGestureRecognizer* pinch;

@end

@implementation TTPushController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.transition = [[TTInteractivePinchTransition alloc] init];
	_transition.delegate = self;
	_transition.sensitivity = 0.5f;
	_transition.pinchFilter = PinchFilter_RecognizeOpenOnly;
	
	self.pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:_transition action:@selector(handlePinch:)];
	[self.view addGestureRecognizer:_pinch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        if (self.navigationController) {
            [self.navigationController setNavigationBarHidden:NO animated:animated];
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        NSArray *debugViews = [context containerView].subviews;
        NSLog(@"%@", debugViews);
        
        if ([context isCancelled] ) {
            if( self.navigationController ) {
                [self.navigationController setNavigationBarHidden:YES animated:animated];
            }
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[self transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        if (self.navigationController) {
            [self.navigationController setNavigationBarHidden:YES animated:animated];
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        if ([context isCancelled] ) {
            if( self.navigationController ) {
                [self.navigationController setNavigationBarHidden:NO animated:animated];
            }
        }
    }];
    
    [super viewWillDisappear:animated];
}


#pragma mark - TTInteractivePinchTransitionDelegate

-(void)delegateShouldPerformSegue:(TTInteractivePinchTransition*)transition
							pinch:(UIPinchGestureRecognizer*)pinch
{
	[self performSegueWithIdentifier:@"push" sender:pinch];
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
	if([animationController isKindOfClass:[TTBaseAnimator class]])
		return ((TTBaseAnimator*)animationController).interactiveTransitioning;
	return nil;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
	if(operation == UINavigationControllerOperationPush)
	{
		TTPushAnimator* anim = [[TTPushAnimator alloc] init];
		
		//we can determine here if this transition should be interactive
		BOOL transitionCausedByGesture = YES;
		anim.interactiveTransitioning = transitionCausedByGesture ? _transition : nil;
		
		return anim;
	}
	return nil;
}

@end
