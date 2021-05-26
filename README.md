## Reddit Media Grabber

Reddit Media Grabber is a small library that can be used by tweak developers
for use on the official Reddit applciation (for Apple IOS)

This wasn't originally intended to be released publicly so a lot of the
methods are hardcoded and may need tinkering depending on how you want things.

### Prerequisites

You will need:
* Jailbroken iPhone (IOS Firmware >= 13.0)
* Theos Project (Tweak, etc..)
* Reddit Official App from the AppStore

### Installation & Usage

1. Download the files [here.](https://github.com/ClarenceBain/Reddit-Media-Grabber-IOS/tree/main/src)
2. Transfer RedditHeaders.h, RedditMediaGrabber.h, & RedditMediaGrabber.xm to your Tweaks directory
3. After transfer make sure your Makefile the following:
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

After setting up your Makefile you can begin usage, example below:
```objc
// This is an example of using RMG, this hook may or may not work in actual testing
#import "RedditMediaGrabber.h"

%hook TheatreViewController
- (void)viewDidLoad {
  %orig;
  FBApplicationInfo *redditApp = [%c(LSApplicationProxy) applicationProxyForIdentifier: @"com.reddit.Reddit"]; // Downloaded files are saved to the apps documents folder, we use this to get there
  NSString *videoLink = [RMG getVideoLinkFromJson:self];     // Get the video
  NSString *audioLink = [RMG getAudioLinkFromURL:videoLink]; // Audio is detached from Reddit Videos by default so we have to grab it separately
  [RMG downloadMp4FromURL:videoLink isMp3:false];
  [RMG downloadMp4FromURL:audioLink isMp3:true];             // The audio link is really just an .mp4 without video, only reason i've added it to this method.


  // Some videos do not come with audio and return as an access denied, so we check if the audio can be played to avoid crashes.
  // By default audio is saved as "tempaudio.mp3" in the Reddit Applications Documents folder, you can change this in RedditMediaGrabber.xm
  // ^ The same goes for the temporary video file & final video file. (temp.mp4, final.mov)
  NSString *mp3Path = [redditApp.dataContainerURL.path stringByAppendingPathComponent:@"/Documents/tempaudio.mp3"];
  NSString *mp4Path = [redditApp.dataContainerURL.path stringByAppendingPathComponent:@"/Documents/temp.mp4"]
  NSString *finalPath = [redditApp.dataContainerURL.path stringByAppendingPathComponent:@"/Documents/final.mov"]
  if([RMG isMp3Playable:[NSURL fileURLWithPath:mp3Path]])
  {
    [RMG mergeMp3WithMp4:mp3Path mp4:mp4Path]
    [RMG saveToPhotos:finalPath view:self isVideo:true];
    [RMG deleteFileAtPath:mp3Path];      // Make sure the files are deleted in case of closing the share tab
    [RMG deleteFileAtPath:mp4Path];      // Make sure the files are deleted in case of closing the share tab
    [RMG deleteFileAtPath:finalPath];    // Make sure the files are deleted in case of closing the share tab
  } else {
    // Since the video didn't have audio we don't have to merge anything and can just use the temp file
    [RMG saveToPhotos:mp4Path view:self isVideo:true];
    [RMG deleteFileAtPath:mp3Path];      // Make sure the files are deleted in case of closing the share tab
    [RMG deleteFileAtPath:mp4Path];      // Make sure the files are deleted in case of closing the share tab
  }
}
%end
```

## License

Distributed under the MIT License. See [LICENSE](https://github.com/ClarenceBain/Taikasauva/blob/main/LICENSE) for more information.
