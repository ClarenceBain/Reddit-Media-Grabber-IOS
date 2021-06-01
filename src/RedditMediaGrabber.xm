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

+ (NSString*)getAudioLinkFromURLString:(NSString *)arg1 {
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

+ (void)downloadAndSaveVideoToPhotos:(TheatreViewController*)arg1 {
  NSString *video = [RMG getVideoLinkFromJson:arg1];
  NSString *audio = [RMG getAudioLinkFromURLString:video];
  [RMG downloadMp4FromURL:[NSURL URLWithString:video] downloadPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
  [RMG downloadMp4FromURL:[NSURL URLWithString:audio] downloadPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
  if(![RMG isMp3Playable:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]]])
  {
    [RMG saveToPhotos:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]] view:arg1 completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
      if(success)
      {
        [arg1 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
      } else {
        [arg1 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
      }
    }];
  } else {
    [RMG mergeMp3WithMp4:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]] mp4:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]] outputMovPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/final.mov"]];
    [RMG saveToPhotos:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/final.mov"]] view:arg1 completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
      if(success)
      {
        [arg1 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/final.mov"]];
      } else {
        [arg1 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempvideo.mp4"]];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/tempaudio.mp3"]];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/final.mov"]];
      }
    }];
  }
}

+ (void)downloadAndSaveGifToPhotos:(TheatreViewController*)arg1 {
  if([RMG returnMediaTypeFromView:arg1] == 0) // check if the media is a gif
  {
    NSString *imageL = [RMG getGifLinkFromPost:arg1];
    if(imageL != nil)
      [RMG downloadGifFromURL:[NSURL URLWithString:imageL] downloadPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
    [RMG saveToPhotos:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]] view:arg1 completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
      if(success)
      {
        [arg1 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
      } else {
        [arg1 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
      }
    }];
  }
  else if ([RMG returnMediaTypeFromView:arg1] == 1) // check if the media is a gifv
  {
    NSString *imageL = [[RMG getGifLinkFromPost:arg1] substringToIndex:[[RMG getGifLinkFromPost:arg1] length] - 1]; // remove the v from .gifv
    if(imageL != nil)
      [RMG downloadGifFromURL:[NSURL URLWithString:imageL] downloadPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
    [RMG saveToPhotos:[NSURL fileURLWithPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]] view:arg1 completion:^(NSString *activity, BOOL success, NSArray *returned, NSError *error) {
      if(success)
      {
        [arg1 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
      } else {
        [arg1 dismissViewControllerAnimated:YES completion:nil];
        [RMG deleteFileAtPath:[[RMG getRedditDocumentsPath] stringByAppendingString:@"/temp.gif"]];
      }
    }];
  }
}

+ (void)downloadGifFromURL:(NSURL*)arg1 downloadPath:(NSString*)arg2 {
  NSData *image = [NSData dataWithContentsOfURL:arg1];
  NSString *dlPath = arg2;
  [image writeToFile:dlPath atomically:YES];
}

+ (NSString*)getRedditDocumentsPath {
  FBApplicationInfo *redditApp = [%c(LSApplicationProxy) applicationProxyForIdentifier: @"com.reddit.Reddit"];
  return [redditApp.dataContainerURL.path stringByAppendingPathComponent:@"/Documents"];
}

+ (void)downloadMp4FromURL:(NSURL*)arg1 downloadPath:(NSString*)arg2 {
  NSData *other = [NSData dataWithContentsOfURL:arg1];
  NSString *dlPath = arg2;
  [other writeToFile:dlPath atomically:YES];
}

+ (void)mergeMp3WithMp4:(NSURL*)arg1 mp4:(NSURL*)arg2 outputMovPath:(NSString*)arg3 {
  AVMutableComposition *mergeComp = [AVMutableComposition composition];

  NSURL *audio_url = arg1;
  if([RMG isMp3Playable:audio_url])
  {
    AVURLAsset  *audioAsset = [[AVURLAsset alloc] initWithURL:audio_url options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);

    AVMutableCompositionTrack *compAudioTrack = [mergeComp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];

    AVURLAsset  *videoAsset = [[AVURLAsset alloc] initWithURL:arg2 options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);

    AVMutableCompositionTrack *compVideoTrack = [mergeComp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

    AVAssetExportSession *exportV = [[AVAssetExportSession alloc] initWithAsset:mergeComp presetName:AVAssetExportPresetHighestQuality];
    exportV.outputFileType = AVFileTypeQuickTimeMovie;
    exportV.outputURL = [NSURL fileURLWithPath:arg3];
    [exportV exportAsynchronouslyWithCompletionHandler:^(void ) {}];
  }
}


+ (NSInteger)returnMediaTypeFromView:(TheatreViewController*)arg1 {
  TheatreBottomBarView *bbHook = MSHookIvar<TheatreBottomBarView*>(arg1, "_bottomBar");
  TheatreMediaItem *miHook;
  Post *pHook;

  if(bbHook != nil)
    miHook = MSHookIvar<TheatreMediaItem*>(bbHook, "_mediaItem");
  if(miHook != nil)
    pHook = MSHookIvar<Post*>(miHook, "_originalPost");
  if(pHook != nil)
  {
    if([MSHookIvar<NSURL*>(pHook, "_linkURL").absoluteString rangeOfString:@".gif"].location != NSNotFound && [MSHookIvar<NSURL*>(pHook, "_linkURL").absoluteString rangeOfString:@".gifv"].location == NSNotFound)
    {
      return 0;  // this is a .gif
    } else if([MSHookIvar<NSURL*>(pHook, "_linkURL").absoluteString rangeOfString:@".gif"].location != NSNotFound && [MSHookIvar<NSURL*>(pHook, "_linkURL").absoluteString rangeOfString:@".gifv"].location != NSNotFound)
    {
      return 1;  // this is a .gifv
    } else if([MSHookIvar<NSURL*>(pHook, "_linkURL").absoluteString rangeOfString:@"v.redd.it"].location != NSNotFound)
    {
      return 2;  // this is a .mp4
    }
  }
  return -1; // error or nil
}

+ (NSInteger)returnMediaType:(NSString*)arg1 {
  if([arg1 rangeOfString:@".gif"].location != NSNotFound && [arg1 rangeOfString:@".gifv"].location == NSNotFound)
  {
    return 0;  // this is a .gif
  } else if([arg1 rangeOfString:@".gif"].location != NSNotFound && [arg1 rangeOfString:@".gifv"].location != NSNotFound)
  {
    return 1;  // this is a .gifv
  } else if([arg1 rangeOfString:@"v.redd.it"].location != NSNotFound)
  {
    return 2;  // this is a .mp4
  }
  return -1; // error or nil
}

+ (void)saveToPhotos:(NSURL*)arg1 view:(TheatreViewController*)arg2 completion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))arg4 {
  NSURL *toShare = arg1;
  NSArray *data = @[toShare];
  [RMG showShareView:data view:arg2 completion:arg4];
}

+ (void)showShareView:(NSArray*)arg1 view:(TheatreViewController*)arg2 completion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))arg3 {
  UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:arg1 applicationActivities:nil];
  shareController.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact];
  shareController.completionWithItemsHandler = arg3;
  [arg2 presentViewController:shareController animated:YES completion:nil];
}
@end
