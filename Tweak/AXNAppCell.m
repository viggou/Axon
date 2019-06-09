#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MPArtworkColorAnalyzer.h>
#import <MediaPlayer/MPArtworkColorAnalysis.h>
#import "AXNAppCell.h"
#import "AXNManager.h"

@implementation AXNAppCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    [self addGestureRecognizer:recognizer];

    self.layer.cornerRadius = 13;
    self.layer.continuousCorners = YES;
    self.layer.masksToBounds = YES;

    self.iconView = [[UIImageView alloc] initWithFrame:frame];
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.iconView];

    self.badgeLabel = [[UILabel alloc] initWithFrame:frame];
    self.badgeLabel.font = [UIFont boldSystemFontOfSize:14];
    self.badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.badgeLabel.text = @"0";
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.backgroundColor = [UIColor blackColor];
    self.badgeLabel.layer.cornerRadius = 10;
    self.badgeLabel.layer.masksToBounds = YES;
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.badgeLabel];

    _styleConstraintsDefault = @[
        [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-30],
        [self.badgeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.badgeLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
        [self.badgeLabel.heightAnchor constraintEqualToConstant:20],
        [self.badgeLabel.widthAnchor constraintEqualToConstant:30],
    ];

    _styleConstraintsPacked = @[
        [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
        [self.badgeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
        [self.badgeLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
        [self.badgeLabel.heightAnchor constraintEqualToConstant:20],
        [self.badgeLabel.widthAnchor constraintEqualToConstant:30],
    ];

    _styleConstraintsCompact = @[
        [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5],
        [self.iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
        [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
        [self.badgeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.badgeLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
        [self.badgeLabel.heightAnchor constraintEqualToConstant:20],
        [self.badgeLabel.widthAnchor constraintEqualToConstant:30],
    ];

    return self;
}

-(void)axnClearAll {
    [[AXNManager sharedInstance] clearAll:self.bundleIdentifier];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(axnClearAll));
}

-(void)showMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        AudioServicesPlaySystemSound(1519);

        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.menuItems = @[
            [[UIMenuItem alloc] initWithTitle:@"Clear All" action:@selector(axnClearAll)],
        ];
        [menu setTargetRect:self.bounds inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

-(void)setBundleIdentifier:(NSString *)value {
    _bundleIdentifier = value;
    self.iconView.image = [[AXNManager sharedInstance] getIcon:value];

    self.badgeLabel.backgroundColor = [UIColor clearColor];
    self.badgeLabel.textColor = [[AXNManager sharedInstance] fallbackColor];

    if (self.badgesShowBackground && self.iconView.image) {
        if ([AXNManager sharedInstance].backgroundColorCache[value] && [AXNManager sharedInstance].textColorCache[value]) {
            self.badgeLabel.backgroundColor = [[AXNManager sharedInstance].backgroundColorCache[value] copy];
            self.badgeLabel.textColor = [[AXNManager sharedInstance].textColorCache[value] copy];
        } else {
            MPArtworkColorAnalyzer *colorAnalyzer = [[MPArtworkColorAnalyzer alloc] initWithImage:self.iconView.image algorithm:0];
            [colorAnalyzer analyzeWithCompletionHandler:^(MPArtworkColorAnalyzer *analyzer, MPArtworkColorAnalysis *analysis) {
                [AXNManager sharedInstance].backgroundColorCache[value] = [analysis.backgroundColor copy];
                [AXNManager sharedInstance].textColorCache[value] = [analysis.primaryTextColor copy];
                self.badgeLabel.backgroundColor = [analysis.backgroundColor copy];
                self.badgeLabel.textColor = [analysis.primaryTextColor copy];
            }];
        }
    }
}

-(void)setNotificationCount:(NSInteger)value {
    _notificationCount = value;

    if (value <= 99) {
        self.badgeLabel.text = [NSString stringWithFormat:@"%ld", value];
    } else {
        self.badgeLabel.text = @"99+";
    }
}

-(void)setSelectionStyle:(NSInteger)style {
    _selectionStyle = style;

    self.iconView.alpha = 1.0;
    self.badgeLabel.alpha = 1.0;
    self.backgroundColor = [UIColor clearColor];
}

-(void)setStyle:(NSInteger)style {
    _style = style;
    [NSLayoutConstraint deactivateConstraints:_styleConstraintsDefault];
    [NSLayoutConstraint deactivateConstraints:_styleConstraintsPacked];
    [NSLayoutConstraint deactivateConstraints:_styleConstraintsCompact];

    switch (style) {
        case 1:
            [NSLayoutConstraint activateConstraints:_styleConstraintsPacked];
            break;
        case 2:
            [NSLayoutConstraint activateConstraints:_styleConstraintsCompact];
            break;
        default:
            [NSLayoutConstraint activateConstraints:_styleConstraintsDefault];
    }

    [self setNeedsLayout];
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if (selected) {
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            switch (self.selectionStyle) {
                case 1:
                    self.iconView.alpha = 1.0;
                    self.badgeLabel.alpha = 1.0;
                    break;
                default:
                    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            }
        } completion:NULL];
    } else {
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            switch (self.selectionStyle) {
                case 1:
                    self.iconView.alpha = 0.5;
                    self.badgeLabel.alpha = 0.5;
                    break;
                default:
                    self.backgroundColor = [UIColor clearColor];
            }
        } completion:NULL];
    }
}

@end