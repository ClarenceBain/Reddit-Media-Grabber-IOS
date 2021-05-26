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
+ (NSString*)getAudioLinkFromURL:(NSString *)arg1;
+ (NSString*)getGifLinkFromPost:(TheatreViewController*)arg1;
+ (NSString*)getVideoLinkFromJson:(TheatreViewController*)arg1;
+ (void)deleteFileAtPath:(NSString*)arg1;
+ (void)downloadGifFromURL:(NSString*)arg1;
+ (void)downloadMp4FromURL:(NSString*)arg1 isMp3:(bool)arg2;
+ (void)mergeMp3WithMp4:(NSString*)arg1 mp4:(NSString*)arg2;
+ (void)saveToPhotos:(NSString*)arg1 view:(TheatreViewController*)arg2 isVideo:(bool)arg3;
+ (void)showShareView:(NSArray*)arg1 view:(TheatreViewController*)arg2 completetion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))arg3;
@end
