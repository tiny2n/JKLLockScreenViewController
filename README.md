<h1 align="center">JKLLockScreenViewController</h1>

<p align="center">
<img src="https://img.shields.io/cocoapods/p/DeepLinkSDK.svg?style=flat" alt="Platform" /></a>
</p>

Overview
-------------
It is Lock Screen Controller on platform iOS.

Feature
-------------
- Touch ID
- IB_DESIGNABLE
- Autolayout
- Localization
- Cocoapods


### Installation
Add the files to your project manually by dragging the JKLLockScreenViewController directory into your Xcode project.


### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like JKLockScreenViewController in your projects. See the ["Getting Started" guide for more information].


#### Podfile

```ruby
platform :ios, '6.0'
pod 'JKLLockScreenViewController', '~> 1.0.0', :git => 'https://github.com/tiny2n/JKLLockScreenViewController.git'
```


### Usage

```
// Import the class
#import "JKLLockScreenViewController.h"

...

// ---------------------------------------------------
// ex) JKLLockScreenViewController in UIViewController ...
// ---------------------------------------------------
// add UIViewController
JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
[viewController setLockScreenMode:{{lock screen mode}}];    // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
[viewController setDelegate:self];
[viewController setDataSource:self];
[self presentViewController:viewController animated:YES completion:NULL];
    
...

// ---------------------------------------------------
// Delegate
// ---------------------------------------------------
- (void)unlockWasSuccessfulLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode;    // support for number
- (void)unlockWasSuccessfulLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController;                                // support for touch id
- (void)unlockWasCancelledLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController;
- (void)unlockWasFailureLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController;

// ---------------------------------------------------
// Delegate
// ---------------------------------------------------
- (BOOL)lockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode;
- (BOOL)allowTouchIDLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController;
...

```

![DropAlert](https://github.com/tiny2n/JKLLockScreenViewController/blob/master/Screenshot.png)


License
-------------------------------------------------------
The MIT License (MIT)

Copyright (c) 2015 JoongKwan Choi

JKLib

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

