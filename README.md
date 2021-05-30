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

Grabbing video (automatic method):
```objc
// This is an example of using RMG, this hook may or may not work in actual testing
#import "RedditMediaGrabber.h"

%hook TheatreViewController
- (void)viewDidLoad {
  %orig;

  if([RMG returnMediaTypeFromView:self] == 2) // check if the media is a video
  {
    [RMG downloadAndSaveVideoToPhotos:self]; // automatic way
  }
}
%end
```

Grabbing video (manual method):
```objc
// This is an example of using RMG, this hook may or may not work in actual testing
#import "RedditMediaGrabber.h"

%hook TheatreViewController
- (void)viewDidLoad {
  %orig;

  if([RMG returnMediaTypeFromView:self] == 2) // check if the media is a video
  {
    // Get the video and audio links (reddit separates them)
    NSString *video = [RMG getVideoLinkFromJson:self];
    NSString *audio = [RMG getAudioLinkFromURLString:video];

    // Download the video and audio files and store them in the Reddit applications Documents folder using [RMG getRedditDocumentsPath]
    [RMG downloadMp4FromURL:[NSURL URLWithString:video] downloadPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
    [RMG downloadMp4FromURL:[NSURL URLWithString:audio] downloadPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];

    // Check if the audio file we downloaded is playable and not an access denied (aka video had no audio)
    if(![RMG isMp3Playable:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]]]) // if NO audio
    {
      [RMG saveToPhotos:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]] view:arg1 completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
        if(success)
        {
          [arg1 dismissViewControllerAnimated:YES completion:nil];
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
        } else { // if the person closes the share controller without saving the files make sure they get deleted
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
        }
      }];
    }
    else { // if there is audio
      // merge the two files we downloaded together
      [RMG mergeMp3WithMp4:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]] mp4:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]] outputMovPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/final.mov"]];
      [RMG saveToPhotos:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/final.mov"]] view:arg1 completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
        if(success)
        {
          [arg1 dismissViewControllerAnimated:YES completion:nil];
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/final.mov"]];
        } else {  // if the person closes the share controller without saving the files make sure they get deleted
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
          [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/final.mov"]];
        }
      }];
    }
  }
}
%end
```

Grabbing gif or gifv (automatic):
```objc
// This is an example of using RMG, this hook may or may not work in actual testing
#import "RedditMediaGrabber.h"

%hook TheatreViewController
- (void)viewDidLoad {
  %orig;

  if([RMG returnMediaTypeFromView:self] == 0 || [RMG returnMediaTypeFromView:self] == 1 ) // check if the media is a video
  {
    [RMG downloadAndSaveGifToPhotos:self]; // automatic way
  }
}
%end
```

Grabbing gif or gifv (manual):
```objc
// This is an example of using RMG, this hook may or may not work in actual testing
#import "RedditMediaGrabber.h"

%hook TheatreViewController
- (void)viewDidLoad {
  %orig;

  if([RMG returnMediaTypeFromView:self] == 0) // check if the media is a gif
  {
    NSString *imageL = [RMG getGifLinkFromPost:self];
    if(imageL != nil)
      [RMG downloadGifFromURL:[NSURL URLWithString:imageL] downloadPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
    [RMG saveToPhotos:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]] view:self completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
      if(success)
      {
        [self dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
      } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
      }
    }];
  }
  else if ([RMG returnMediaTypeFromView:self] == 1) // check if the media is a gifv
  {
    NSString *imageL = [[RMG getGifLinkFromPost:self] substringToIndex:[[RMG getGifLinkFromPost:self] length] - 1]; // remove the v from .gifv
    if(imageL != nil)
      [RMG downloadGifFromURL:[NSURL URLWithString:imageL] downloadPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
    [RMG saveToPhotos:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]] view:self completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
      if(success)
      {
        [self dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
      } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
      }
    }];
  }
}
%end
```

## License

Distributed under the MIT License. See [LICENSE](https://github.com/ClarenceBain/Taikasauva/blob/main/LICENSE) for more information.
