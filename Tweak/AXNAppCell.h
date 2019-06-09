@interface AXNAppCell : UICollectionViewCell {
    NSArray *_styleConstraintsDefault;
    NSArray *_styleConstraintsPacked;
    NSArray *_styleConstraintsCompact;
}

@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UILabel *badgeLabel;
@property (nonatomic, retain) NSString *bundleIdentifier;
@property (nonatomic, assign) NSInteger notificationCount;
@property (nonatomic, assign) NSInteger selectionStyle;
@property (nonatomic, assign) NSInteger style;
@property (nonatomic, assign) BOOL badgesShowBackground;

@end