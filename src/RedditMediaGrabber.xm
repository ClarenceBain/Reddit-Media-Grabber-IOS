#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RedditHeaders.h"
#import "RedditMediaGrabber.h"

@implementation RMG
+ (bool)checkMP3:(NSURL*)filePath {
  if([[AVURLAsset alloc] initWithURL:filePath options:nil].playable)
  {
    return TRUE;
  } else {
    return FALSE;
  }
}
+ (NSInteger)checkMediaTypeOfPost:(Post*)post {
  if(post != nil)
  {
    if([MSHookIvar<NSURL*>(post, "_linkURL").absoluteString rangeOfString:@".gif"].location != NSNotFound && [MSHookIvar<NSURL*>(post, "_linkURL").absoluteString rangeOfString:@".gifv"].location == NSNotFound)
    {
      return 0;  // this is a .gif
    }
    else if([MSHookIvar<NSURL*>(post, "_linkURL").absoluteString rangeOfString:@".gif"].location != NSNotFound && [MSHookIvar<NSURL*>(post, "_linkURL").absoluteString rangeOfString:@".gifv"].location != NSNotFound)
    {
      return 1;  // this is a .gifv
    }
    else if([MSHookIvar<NSURL*>(post, "_linkURL").absoluteString rangeOfString:@"v.redd.it"].location != NSNotFound)
    {
      return 2;  // this is a .mp4
    }
    else if([MSHookIvar<NSURL*>(post, "_linkURL").absoluteString rangeOfString:@".jpg"].location != NSNotFound || [MSHookIvar<NSURL*>(post, "_linkURL").absoluteString rangeOfString:@".png"].location != NSNotFound || [MSHookIvar<NSURL*>(post, "_linkURL").absoluteString rangeOfString:@".jpeg"].location != NSNotFound)
    {
      return 3;  // this is a .mp4
    }
  }
  return -1; // error or nil
}
+ (NSString*)documentsPath {
  FBApplicationInfo *redditApp = [%c(LSApplicationProxy) applicationProxyForIdentifier: @"com.reddit.Reddit"];
  return [redditApp.dataContainerURL.path stringByAppendingPathComponent:@"/Documents"];
}
+ (void)downloadMediaFromPost:(Post*)post {
  if(post != nil)
  {
    switch([RMG checkMediaTypeOfPost:post])
    {
      case 0: {
        NSString *gif_url = MSHookIvar<NSURL*>(post, "_linkURL").absoluteString;
        NSData *gifData = [NSData dataWithContentsOfURL:[NSURL URLWithString:gif_url]];

        [gifData writeToFile:[[RMG documentsPath] stringByAppendingString:@"/tempgif.gif"] atomically:YES];
      break;
    }
      case 1: {
        NSString *gifv_url = [MSHookIvar<NSURL*>(post, "_linkURL").absoluteString substringToIndex:[MSHookIvar<NSURL*>(post, "_linkURL").absoluteString length] - 1];
        NSData *gifvData = [NSData dataWithContentsOfURL:[NSURL URLWithString:gifv_url]];

        [gifvData writeToFile:[[RMG documentsPath] stringByAppendingString:@"/tempgif.gif"] atomically:YES];
      break;
    }
      case 2: {
        NSString *reddit = @"https://reddit.com/";
        NSString *jsonExt = @".json";
        NSString *jsonLink = [[reddit stringByAppendingString:MSHookIvar<NSString*>(post, "_permalink")] stringByAppendingString:jsonExt];
        NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:jsonLink]];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSRange fallback = [jsonString rangeOfString:@"\"fallback_url\": \""];
        NSRange endFallback = [jsonString rangeOfString:@"?source=fallback"];
        NSString *videoLink = [jsonString substringWithRange:NSMakeRange(NSMaxRange(fallback),endFallback.location - fallback.location - 1)];
        NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoLink]];
        NSString *https = @"https://";
        NSRange http = [videoLink rangeOfString:https];
        NSRange dash = [videoLink rangeOfString:@"DASH"];
        NSString *audioLink = [https stringByAppendingString:[[videoLink substringWithRange:NSMakeRange(NSMaxRange(http),dash.location - http.location - 8)] stringByAppendingString:@"DASH_audio.mp4"]];
        NSData *audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioLink]];

        [videoData writeToFile:[[RMG documentsPath] stringByAppendingString:@"/tempvideo.mp4"] atomically:YES];
        [audioData writeToFile:[[RMG documentsPath] stringByAppendingString:@"/tempaudio.mp3"] atomically:YES];
      break;
      }
      case 3: {
        NSString *image_url = MSHookIvar<NSURL*>(post, "_linkURL").absoluteString;
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:image_url]];
        UIImage *image = [UIImage imageWithData:imageData];

        [UIImagePNGRepresentation(image) writeToFile:[[RMG documentsPath] stringByAppendingString:@"/tempimage.png"] atomically:YES];
        break;
      }
    }
  }
}
+ (void)deleteFileAtPath:(NSString*)filePath {
  if(filePath != nil)
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}
+ (void)savePostMediaToPhotos:(Post*)post view:(UIViewController*)view {
  if(post != nil)
  {
    [RMG downloadMediaFromPost:post];
    switch([RMG checkMediaTypeOfPost:post])
    {
      case 0: {
      [RMG save:[NSURL fileURLWithPath:[[RMG documentsPath] stringByAppendingString:@"/tempgif.gif"]] view:view completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
        if(success)
        {
          [view dismissViewControllerAnimated:YES completion:nil];
          [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempgif.gif"]];
        } else {
          [view dismissViewControllerAnimated:YES completion:nil];
          [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempgif.gif"]];
        }
      }];
      break;
    }
      case 1: {
      [RMG save:[NSURL fileURLWithPath:[[RMG documentsPath] stringByAppendingString:@"/tempgif.gif"]] view:view completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
        if(success)
        {
          [view dismissViewControllerAnimated:YES completion:nil];
          [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempgif.gif"]];
        } else {
          [view dismissViewControllerAnimated:YES completion:nil];
          [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempgif.gif"]];
        }
      }];
      break;
    }
      case 2: {
        if(![RMG checkMP3:[NSURL fileURLWithPath:[[RMG documentsPath] stringByAppendingString:@"/tempaudio.mp3"]]])
        {
          [RMG save:[NSURL fileURLWithPath:[[RMG documentsPath] stringByAppendingString:@"/tempvideo.mp4"]] view:view completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
            if(success)
            {
              [view dismissViewControllerAnimated:YES completion:nil];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
            } else {
              [view dismissViewControllerAnimated:YES completion:nil];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
            }
          }];
        }
        else {
          [RMG mergeMP3WithMP4:[NSURL fileURLWithPath:[[RMG documentsPath] stringByAppendingString:@"/tempaudio.mp3"]] mp4:[NSURL fileURLWithPath:[[RMG documentsPath] stringByAppendingString:@"/tempvideo.mp4"]] outputMovPath:[[RMG documentsPath] stringByAppendingString:@"/final.mov"]];
          [RMG save:[NSURL fileURLWithPath:[[RMG documentsPath] stringByAppendingString:@"/final.mov"]] view:view completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
            if(success)
            {
              [view dismissViewControllerAnimated:YES completion:nil];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/final.mov"]];
            } else {
              [view dismissViewControllerAnimated:YES completion:nil];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
              [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/final.mov"]];
            }
          }];
        }
      break;
      }
      case 3: {
        [RMG save:[NSURL fileURLWithPath:[[RMG documentsPath] stringByAppendingString:@"/tempimage.png"]] view:view completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
          if(success)
          {
            [view dismissViewControllerAnimated:YES completion:nil];
            [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempimage.gif"]];
          } else {
            [view dismissViewControllerAnimated:YES completion:nil];
            [RMG deleteFileAtPath:[[RMG documentsPath] stringByAppendingString:@"/tempimage.gif"]];
          }
        }];
        break;
      }
    }
  }
}
+ (void)mergeMP3WithMP4:(NSURL*)mp3 mp4:(NSURL*)mp4 outputMovPath:(NSString*)movOutput {
  AVMutableComposition *mergeComp = [AVMutableComposition composition];

  NSURL *audio_url = mp3;
  AVURLAsset  *audioAsset = [[AVURLAsset alloc] initWithURL:audio_url options:nil];
  CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);

  AVMutableCompositionTrack *compAudioTrack = [mergeComp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
  [compAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];

  AVURLAsset  *videoAsset = [[AVURLAsset alloc] initWithURL:mp4 options:nil];
  CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);

  AVMutableCompositionTrack *compVideoTrack = [mergeComp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
  [compVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

  AVAssetExportSession *exportV = [[AVAssetExportSession alloc] initWithAsset:mergeComp presetName:AVAssetExportPresetHighestQuality];
  exportV.outputFileType = AVFileTypeQuickTimeMovie;
  exportV.outputURL = [NSURL fileURLWithPath:movOutput];
  [exportV exportAsynchronouslyWithCompletionHandler:^(void ) {}];
}
+ (void)save:(NSURL*)fileToSave view:(UIViewController*)view completion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))complete {
  NSArray *data = [NSArray arrayWithObjects:fileToSave, nil];
  [RMG share:data view:view completion:complete];
  [view dismissViewControllerAnimated:NO completion:^{
      [RMG share:data view:view completion:complete]; // why & how the hell does this fix the problem?
  }];
}
+ (void)share:(NSArray*)dataToShare view:(UIViewController*)view completion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))complete {
  UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
  shareController.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact];
  shareController.completionWithItemsHandler = complete;
  [view presentViewController:shareController animated:YES completion:nil];
}
@end
