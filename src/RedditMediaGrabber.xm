#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RedditHeaders.h"
#import "RedditMediaGrabber.h"

@implementation RMG
+ (bool)isMp3Playable:(NSURL*)arg1 {
  AVURLAsset *theMp3 = [[AVURLAsset alloc] initWithURL:arg1 options:nil];
  if(theMp3.playable)
  {
    return TRUE;
  } else {
    return FALSE;
  }
}

+ (NSString*)getAudioLinkFromURL:(NSString *)arg1 {
  NSString *httpsP = @"https://";
  NSRange http = [arg1 rangeOfString:@"https://"];
  NSRange dash = [arg1 rangeOfString:@"DASH"];
  NSString *prelink = [arg1 substringWithRange:NSMakeRange(NSMaxRange(http),dash.location - http.location - 8)];

  return [httpsP stringByAppendingString:[prelink stringByAppendingString:@"DASH_audio.mp4"]];
}

+ (NSString*)getGifLinkFromPost:(TheatreViewController*)arg1 {
  TheatreBottomBarView *bbHook = MSHookIvar<TheatreBottomBarView*>(arg1, "_bottomBar");
  TheatreMediaItem *miHook;
  Post *pHook;
  NSString *image_url;

  if(bbHook != nil)
    miHook = MSHookIvar<TheatreMediaItem*>(bbHook, "_mediaItem");
  if(miHook != nil)
    pHook = MSHookIvar<Post*>(miHook, "_originalPost");
  if(pHook != nil)
  {
    if(MSHookIvar<BOOL>(miHook, "_isGif") == 1)
    {
      image_url = MSHookIvar<NSURL*>(pHook, "_linkURL").absoluteString;
    }
  }

  return image_url;
}

+ (NSString*)getVideoLinkFromJson:(TheatreViewController*)arg1 {
  TheatreBottomBarView *bbHook = MSHookIvar<TheatreBottomBarView*>(arg1, "_bottomBar");
  TheatreMediaItem *miHook;
  Post *pHook;
  NSString *reddit = @"https://reddit.com/";
  NSString *jsonExt = @".json";
  NSString *finalLink;
  NSString *fallback_url;

  if(bbHook != nil)
    miHook = MSHookIvar<TheatreMediaItem*>(bbHook, "_mediaItem");
  if(miHook != nil)
    pHook = MSHookIvar<Post*>(miHook, "_originalPost");
  if(pHook != nil)
  {
    finalLink = [[reddit stringByAppendingString:MSHookIvar<NSString*>(pHook, "_permalink")] stringByAppendingString:jsonExt];

    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalLink]];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange fallback = [json rangeOfString:@"\"fallback_url\": \""];
    NSRange endfallback = [json rangeOfString:@"?source=fallback"];

    fallback_url = [json substringWithRange:NSMakeRange(NSMaxRange(fallback),endfallback.location - fallback.location - 1)];
  }

  return fallback_url;
}

+ (void)deleteFileAtPath:(NSString*)arg1 {
  if(arg1 != nil)
    [[NSFileManager defaultManager] removeItemAtPath:arg1 error:nil];
}

+ (void)downloadGifFromURL:(NSString*)arg1 {
  FBApplicationInfo *redditApp = [%c(LSApplicationProxy) applicationProxyForIdentifier: @"com.reddit.Reddit"];
  NSData *image = [NSData dataWithContentsOfURL:[NSURL URLWithString:arg1]];
  NSString *dlPath;
  if([arg1 rangeOfString:@".gif"].location != NSNotFound)
    dlPath = [redditApp.dataContainerURL.path stringByAppendingPathComponent:@"/Documents/temp.gif"];
  [image writeToFile:dlPath atomically:YES];
}

+ (void)downloadMp4FromURL:(NSString*)arg1 isMp3:(bool)arg2 {
  FBApplicationInfo *redditApp = [%c(LSApplicationProxy) applicationProxyForIdentifier: @"com.reddit.Reddit"];
  if(arg2)
  {
    NSData *sound = [NSData dataWithContentsOfURL:[NSURL URLWithString:arg1]];
    if(sound != nil)
    {
      NSString *dlPath = [redditApp.dataContainerURL.path stringByAppendingPathComponent:@"/Documents/tempaudio.mp3"];
      [sound writeToFile:dlPath atomically:YES];
    }
  }
  else
  {
    NSData *other = [NSData dataWithContentsOfURL:[NSURL URLWithString:arg1]];
    NSString *dlPath = [redditApp.dataContainerURL.path stringByAppendingPathComponent:@"/Documents/temp.mp4"];
    [other writeToFile:dlPath atomically:YES];
  }
}

+ (void)mergeMp3WithMp4:(NSString*)arg1 mp4:(NSString*)arg2 {
  AVMutableComposition *mergeComp = [AVMutableComposition composition];

  NSURL *audio_url = [NSURL fileURLWithPath:arg1];
  if([RMG isMp3Playable:audio_url])
  {
    AVURLAsset  *audioAsset = [[AVURLAsset alloc] initWithURL:audio_url options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);

    AVMutableCompositionTrack *compAudioTrack = [mergeComp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];

    AVURLAsset  *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:arg2] options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);

    AVMutableCompositionTrack *compVideoTrack = [mergeComp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

    AVAssetExportSession *exportV = [[AVAssetExportSession alloc] initWithAsset:mergeComp presetName:AVAssetExportPresetHighestQuality];
    exportV.outputFileType = AVFileTypeQuickTimeMovie;
    exportV.outputURL = [NSURL fileURLWithPath:[redditApp.dataContainerURL.path stringByAppendingString:@"/Documents/final.mov"]];
    [exportV exportAsynchronouslyWithCompletionHandler:^(void ) {}];
  }
}

+ (void)saveToPhotos:(NSString*)arg1 view:(TheatreViewController*)arg2 isVideo:(bool)arg3 {
  FBApplicationInfo *redditApp = [%c(LSApplicationProxy) applicationProxyForIdentifier: @"com.reddit.Reddit"];
  NSURL *toShare = [NSURL fileURLWithPath:arg1];
  NSArray *data = @[toShare];
  if(arg3)
  {
    [RMG showShareView:data view:arg2 completetion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
      if(success)
      {
        [arg2 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[redditApp.dataContainerURL.path stringByAppendingString:@"/Documents/tempaudio.mp3"]];
        [RMG deleteFileAtPath:[redditApp.dataContainerURL.path stringByAppendingString:@"/Documents/temp.mp4"]];
        [RMG deleteFileAtPath:[redditApp.dataContainerURL.path stringByAppendingString:@"/Documents/final.mov"]];
      }
    }];
  } else
  {
    NSURL *toShare = [NSURL fileURLWithPath:arg1];
    NSArray *data = @[toShare];
    [RMG showShareView:data view:arg2 completetion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
      if(success)
      {
        [arg2 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:toShare.absoluteString];
      }
    }];
  }
}

+ (void)showShareView:(NSArray*)arg1 view:(TheatreViewController*)arg2 completetion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))arg3 {
  UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:arg1 applicationActivities:nil];
  shareController.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact];
  shareController.completionWithItemsHandler = arg3;
  [arg2 presentViewController:shareController animated:YES completion:nil];
}
@end
