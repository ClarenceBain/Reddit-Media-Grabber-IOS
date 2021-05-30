#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RedditHeaders.h"

@interface LSApplicationProxy
- (id)_initWithBundleUnit:(NSUInteger)arg1 applicationIdentifier:(NSString *)arg2;
+ (id)applicationProxyForIdentifier:(NSString *)arg1;
+ (id)applicationProxyForBundleURL:(NSURL *)arg1;
@end

@interface FBApplicationInfo : NSObject
- (NSURL *)dataContainerURL;
- (NSURL *)bundleURL;
- (NSString *)bundleIdentifier;
- (NSString *)bundleType;
- (NSString *)bundleVersion;
- (NSString *)displayName;
- (id)initWithApplicationProxy:(id)arg1;
@end

@interface RMG : NSObject
+ (bool)isMp3Playable:(NSURL*)arg1;
+ (NSString*)getAudioLinkFromURLString:(NSString *)arg1;
+ (NSString*)getGifLinkFromPost:(TheatreViewController*)arg1;
+ (NSString*)getRedditDocumentsPath;
+ (NSString*)getVideoLinkFromJson:(TheatreViewController*)arg1;
+ (void)deleteFileAtPath:(NSString*)arg1;
+ (void)downloadAndSaveVideoToPhotos:(TheatreViewController*)arg1;
+ (void)downloadAndSaveGifToPhotos:(TheatreViewController*)arg1;
+ (void)downloadGifFromURL:(NSURL*)arg1 downloadPath:(NSString*)arg2;
+ (void)downloadMp4FromURL:(NSURL*)arg1 downloadPath:(NSString*)arg2;
+ (void)mergeMp3WithMp4:(NSURL*)arg1 mp4:(NSURL*)arg2 outputMovPath:(NSString*)arg3;
+ (NSInteger)returnMediaTypeFromView:(TheatreViewController*)arg1;
+ (NSInteger)returnMediaType:(NSString*)arg1;
+ (void)saveToPhotos:(NSURL*)arg1 view:(TheatreViewController*)arg2 completion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))arg3;
+ (void)showShareView:(NSArray*)arg1 view:(TheatreViewController*)arg2 completion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))arg3;
@end
