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
+ (bool)checkMP3:(NSURL*)filePath;
+ (NSInteger)checkMediaTypeOfPost:(Post*)post;
+ (NSString*)documentsPath;
+ (void)downloadMediaFromPost:(Post*)post;
+ (void)deleteFileAtPath:(NSString*)filePath;
+ (void)savePostMediaToPhotos:(Post*)post view:(UIViewController*)view;
+ (void)mergeMP3WithMP4:(NSURL*)mp3 mp4:(NSURL*)mp4 outputMovPath:(NSString*)movOutput;
+ (void)save:(NSURL*)fileToSave view:(UIViewController*)view completion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))complete;
+ (void)share:(NSArray*)dataToShare view:(UIViewController*)view completion:(void (^)(NSString *activity, BOOL success, NSArray *returned, NSError *error))complete;
@end
