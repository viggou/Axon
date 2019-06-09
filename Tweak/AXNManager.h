#import "AXNView.h"

@interface AXNManager : NSObject

@property (nonatomic, retain) NSMutableDictionary *notificationRequests;
@property (nonatomic, retain) NSMutableDictionary *names;
@property (nonatomic, retain) NSMutableDictionary *iconStore;
@property (nonatomic, retain) NSMutableDictionary *backgroundColorCache;
@property (nonatomic, retain) NSMutableDictionary *textColorCache;
@property (nonatomic, retain) UIColor *fallbackColor;
@property (nonatomic, weak) AXNView *view;
+(instancetype)sharedInstance;
-(id)init;
-(void)insertNotificationRequest:(id)req;
-(void)removeNotificationRequest:(id)req;
-(void)modifyNotificationRequest:(id)req;
-(UIImage *)getIcon:(NSString *)bundleIdentifier;
-(void)clearAll:(NSString *)bundleIdentifier;
@end