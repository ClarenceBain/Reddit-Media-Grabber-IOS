## Reddit Media Grabber

Reddit Media Grabber is a small library that can be used by tweak developers
for use on the official Reddit applciation (for Apple IOS)

### Prerequisites

You will need:
* Jailbroken iPhone (IOS Firmware >= 13.0)
* Theos Project (Tweak, etc..)
* Reddit Official App from the AppStore

### Installation & Usage

1. Download the files [here.](https://github.com/ClarenceBain/Reddit-Media-Grabber-IOS/tree/main/src)
2. Transfer RedditHeaders.h, RedditMediaGrabber.h, & RedditMediaGrabber.xm to your Tweaks directory
3. After transfer make sure your Makefile has the following:
  * RedditMediaGrabber.xm on the _FILES line
  * UIKit & AVFoundation on the _FRAMEWORKS line
  * Example:
  ```make
  TARGET := iphone:clang:latest:13.4
  INSTALL_TARGET_PROCESSES = SpringBoard

  include $(THEOS)/makefiles/common.mk

  TWEAK_NAME = Example
  Example_FILES = Tweak.xm RedditMediaGrabber.xm
  Example_CFLAGS = -fobjc-arc
  Example_FRAMEWORKS = UIKit AVFoundation
  ```

After setting up your Makefile you can begin usage, examples below:

Using:
```objc
// This is an example of using RMG, this specific hook will not work in actual testing
// You will need some class that has access to Post
#import "RedditMediaGrabber.h"

%hook SomeClass
- (void)viewDidLoad {
  %orig;
  [RMG savePostMediaToPhotos:MSHookIvar<Post*>(self,"_post") view:self];
}
%end
```
## License

Distributed under the MIT License. See [LICENSE](https://github.com/ClarenceBain/Taikasauva/blob/main/LICENSE) for more information.
