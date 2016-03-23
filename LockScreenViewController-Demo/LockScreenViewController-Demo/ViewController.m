//
//  ViewController.m
//

#import "ViewController.h"

#import "JKLLockScreenViewController.h"

@interface ViewController ()<JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate>

@property (nonatomic, strong) NSString * enteredPincode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.enteredPincode = @"0000";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPincodeClikced:(id)sender {
    JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
    [viewController setLockScreenMode:[sender tag]];    // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
    [viewController setDelegate:self];
    [viewController setDataSource:self];
    [viewController setTintColor:[UIColor redColor]];
    
    [self presentViewController:viewController animated:YES completion:NULL];
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDelegate
- (void)unlockWasCancelledLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    NSLog(@"LockScreenViewController dismiss because of cancel");
}

- (void)unlockWasSuccessfulLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
    self.enteredPincode = pincode;
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDataSource
- (BOOL)lockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
#ifdef DEBUG
    NSLog(@"Entered Pincode : %@", self.enteredPincode);
#endif
    
    return [self.enteredPincode isEqualToString:pincode];
}

- (BOOL)allowTouchIDLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    return YES;
}

@end
