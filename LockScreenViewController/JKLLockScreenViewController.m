//
//  JKLLockScreenViewController.m
//

#import "JKLLockScreenViewController.h"

#import "JKLLockScreenPincodeView.h"

#import <AudioToolbox/AudioToolbox.h>
#import <LocalAuthentication/LocalAuthentication.h>

static const CGFloat LSVShakeAnimationDuration = 0.5f;
static const CGFloat LSVSwipeAnimationDuration = 0.3f;

@interface JKLLockScreenViewController()<JKLLockScreenPincodeViewDelegate> {
    
    NSString * _confirmPincode;
}

@property (nonatomic, weak) IBOutlet UILabel  * titleLabel;
@property (nonatomic, weak) IBOutlet UILabel  * subtitleLabel;
@property (nonatomic, weak) IBOutlet UIButton * cancelButton;
@property (nonatomic, weak) IBOutlet JKLLockScreenPincodeView * pincodeView;

@end


@implementation JKLLockScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (_lockScreenMode) {
        case LockScreenModeNormal: {
            // [일반 모드] Cancel 버튼 감춤
            [_cancelButton setHidden:YES];
        }
        case LockScreenModeNew: {
            // [신규 모드]
            [self lsv_updateTitle:NSLocalizedStringFromTable(@"Pincode Title",    @"JKLockScreen", nil)
                         subtitle:NSLocalizedStringFromTable(@"Pincode Subtitle", @"JKLockScreen", nil)];

            break;
        }
        case LockScreenModeChange:
            // [변경 모드]
            [self lsv_updateTitle:NSLocalizedStringFromTable(@"New Pincode Title",    @"JKLockScreen", nil)
                         subtitle:NSLocalizedStringFromTable(@"New Pincode Subtitle", @"JKLockScreen", nil)];
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Touch ID를 지원하고, [일반모드] 였을 경우
    BOOL isModeNormal = (_lockScreenMode == LockScreenModeNormal);
    if (isModeNormal && [_delegate respondsToSelector:@selector(allowTouchIDLockScreenViewController:)]) {
        if ([_dataSource allowTouchIDLockScreenViewController:self]) {
            // Touch ID 암호 입력창 호출
            [self lsv_policyDeviceOwnerAuthentication];
        }
    }
}

/**
 Touch ID 창을 호출하는 메소드
 */
- (void)lsv_policyDeviceOwnerAuthentication {
    
    NSError   * error   = nil;
    LAContext * context = [[LAContext alloc] init];
    
    // check if the policy can be evaluated
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        // evaluate
        __weak id weakSelf = self;
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:NSLocalizedStringFromTable(@"Pincode TouchID", @"JKLockScreen", nil)
                          reply:^(BOOL success, NSError * authenticationError) {
                              if (success) {
                                  
                                  // 인증이 완료된 후 창이 dismiss될 때
                                  // 너무 빨리 dimiss되면 잔상처럼 남으므로 0.4초 딜레이 걸어서 dismiss 함
                                  dispatch_time_t delayInSeconds = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC));
                                  dispatch_after(delayInSeconds, dispatch_get_main_queue(), ^(void){
                                      dispatch_async(dispatch_get_main_queue(), ^{

                                          [self dismissViewControllerAnimated:NO completion:^{
                                              if ([_delegate respondsToSelector:@selector(unlockWasSuccessfulLockScreenViewController:)]) {
                                                  [_delegate unlockWasSuccessfulLockScreenViewController:weakSelf];
                                              }
                                          }];
                                      });
                                  });
                              }
                              else {
                                  NSLog(@"LAContext::Authentication Error : %@", authenticationError);
                              }
                          }];
    }
    else {
        NSLog(@"LAContext::Policy Error : %@", [error localizedDescription]);
    }

}

/**
 핀코드가 일치하는지 반판하는 메소드: [확인모드]와 [일반모드]가 다르다
 @param  NSString PIN code
 @return BOOL 암호 유효성
 */
- (BOOL)lsv_isPincodeValid:(NSString *)pincode {
    
    // 기존에 암호가 없거나, [변경모드]라면 무조건 YES
    BOOL confirm = [_confirmPincode isEqualToString:pincode];
    if (confirm) return YES;
    
    if ([_dataSource respondsToSelector:@selector(lockScreenViewController:pincode:)]) {
        return [_dataSource lockScreenViewController:self pincode:pincode];
    }
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must DataSource implement cmd : %@", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/**
 타이틀과 서브타이틀을 변경하는 메소드
 @param NSString 주 제목
 @param NSString 서브 제목
 */
- (void)lsv_updateTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [_titleLabel    setText:title];
    [_subtitleLabel setText:subtitle];
}

/**
 잠금 해제에 성공했을 경우 발생하는 메소드
 @param NSString PIN code
 */
- (void)lsv_unlockScreenSuccessful:(NSString *)pincode {
    [self dismissViewControllerAnimated:NO completion:^{
        if ([_delegate respondsToSelector:@selector(unlockWasSuccessfulLockScreenViewController:pincode:)]) {
            [_delegate unlockWasSuccessfulLockScreenViewController:self pincode:pincode];
        }
    }];
}

/**
 잠금 해제에 실패했을 경우 발생하는 메소드
 */
- (void)lsv_unlockScreenFailure {

    if ([_delegate respondsToSelector:@selector(unlockWasFailureLockScreenViewController:)]) {
        [_delegate unlockWasFailureLockScreenViewController:self];
    }
    
    // 디바이스 진동
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    // make shake animation
    CAAnimation * shake = [self lsv_makeShakeAnimation];
    [_pincodeView.layer addAnimation:shake forKey:@"shake"];
    [_pincodeView setEnabled:NO];
    [_subtitleLabel setText:NSLocalizedStringFromTable(@"Pincode Not Match Title", @"JKLockScreen", nil)];
    
    dispatch_time_t delayInSeconds = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LSVShakeAnimationDuration * NSEC_PER_SEC));
    dispatch_after(delayInSeconds, dispatch_get_main_queue(), ^(void){
        [_pincodeView initPincode];
        [_subtitleLabel setText:NSLocalizedStringFromTable(@"Pincode Subtitle", @"JKLockScreen", nil)];
    });
}

/**
 쉐이크 에니메이션을 생성하는 메소드
 @return CAAnimation
 */
- (CAAnimation *)lsv_makeShakeAnimation {
    
    CAKeyframeAnimation * shake = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    [shake setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [shake setDuration:LSVShakeAnimationDuration];
    [shake setValues:@[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ]];
    
    return shake;
}

/**
 서브 타이틀과 ScreenPinView를 애니메이션 하는 메소드
 ! PincodeView는 제약이 서브타이틀과 같이 묶여 있으므로 따로 해주지 않아도 됨
 1차 : 화면 왼쪽 끝으로 이동 with Animation
 2차 : 화면 오른쪽 끝으로 이동 without Animation
 3차 : 화면 가운데로 이동 with Animation
 */
- (void)lsv_swipeSubtitleAndPincodeView {
    
    __weak UIView * weakView = [self view];
    
    [_pincodeView setEnabled:NO];
    
    CGFloat width = CGRectGetWidth([self view].bounds);
    NSLayoutConstraint * centerX = [self lsv_findLayoutConstraint:self.view  childView:_subtitleLabel attribute:NSLayoutAttributeCenterX];
    
    centerX.constant = width;
    [UIView animateWithDuration:LSVSwipeAnimationDuration animations:^{
        [weakView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        centerX.constant = -width;
        [weakView layoutIfNeeded];
        
        centerX.constant = 0;
        [UIView animateWithDuration:LSVSwipeAnimationDuration animations:^{
            [weakView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_pincodeView setEnabled:YES];
        }];
    }];
}

#pragma mark -
#pragma mark NSLayoutConstraint
- (NSLayoutConstraint *)lsv_findLayoutConstraint:(UIView *)superview childView:(UIView *)childView attribute:(NSLayoutAttribute)attribute {
    for (NSLayoutConstraint * constraint in superview.constraints) {
        if (constraint.firstItem == superview && constraint.secondItem == childView && constraint.firstAttribute == attribute) {
            return constraint;
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark IBAction
- (IBAction)onNumberClicked:(id)sender {
    
    NSInteger number = [sender tag];
    [_pincodeView appendingPincode:[@(number) description]];
}

- (IBAction)onCancelClicked:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(unlockWasCancelledLockScreenViewController:)]) {
        [_delegate unlockWasCancelledLockScreenViewController:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onDeleteClicked:(id)sender {
    
    [_pincodeView removeLastPincode];
}

#pragma mark -
#pragma mark JKLLockScreenPincodeViewDelegate
- (void)lockScreenPincodeView:(JKLLockScreenPincodeView *)lockScreenPincodeView pincode:(NSString *)pincode {
    
    if (_lockScreenMode != LockScreenModeNormal) {
        // [기입 모드], [변경 모드]
        _confirmPincode = pincode;
        [self setLockScreenMode:LockScreenModeNormal];
        
        // 재입력 타이틀로 전환
        [self lsv_updateTitle:NSLocalizedStringFromTable(@"Pincode Title Confirm",    @"JKLockScreen", nil)
                     subtitle:NSLocalizedStringFromTable(@"Pincode Subtitle Confirm", @"JKLockScreen", nil)];
        
        // 서브타이틀과 pincodeviw 이동 애니메이션
        [_pincodeView initPincode];
        [self lsv_swipeSubtitleAndPincodeView];
    }
    else {
        // [일반 모드]
        if ([self lsv_isPincodeValid:pincode]) {
            [self lsv_unlockScreenSuccessful:pincode];
        }
        else {
            [self lsv_unlockScreenFailure];
        }
    }
}

@end
