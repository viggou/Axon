#import <AudioToolbox/AudioToolbox.h>
#import "AXNView.h"
#import "AXNAppCell.h"
#import "AXNManager.h"

@implementation AXNView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.badgesEnabled = YES;
    self.badgesShowBackground = YES;
    self.list = [NSMutableArray new];

    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:self.collectionViewLayout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[AXNAppCell class] forCellWithReuseIdentifier:@"AppCell"];

    [self addSubview:self.collectionView];
        
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];

    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) return [self.list count];
    else return 0;
}

- (void)reset {
    self.selectedBundleIdentifier = nil;
    self.clvc.axnAllowChanges = YES;
    for (id req in [self.clvc allNotificationRequests]) {
        [[AXNManager sharedInstance] insertNotificationRequest:req];
        [self.clvc removeNotificationRequest:req forCoalescedNotification:nil];
    }
    self.clvc.axnAllowChanges = NO;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];

    [self.clvc forceNotificationHistoryRevealed:NO animated:NO];
    [self.clvc setNotificationHistorySectionNeedsReload:YES];
    [self.clvc _reloadNotificationHistorySectionIfNecessary];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AXNAppCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AppCell" forIndexPath:indexPath] ?: [[AXNAppCell alloc] initWithFrame:CGRectMake(0,0,64,64)];
    NSDictionary *dict = self.list[indexPath.row];
    cell.darkMode = self.darkMode;
    cell.badgesShowBackground = self.badgesShowBackground;
    cell.bundleIdentifier = dict[@"bundleIdentifier"];
    cell.notificationCount = [dict[@"notificationCount"] intValue];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = self.selectionStyle;
    cell.selected = [self.selectedBundleIdentifier isEqualToString:cell.bundleIdentifier];
    cell.badgeLabel.hidden = !self.badgesEnabled;
    cell.style = self.style;
    
    if (cell.selected) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }

    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hapticFeedback) AudioServicesPlaySystemSound(1519);
    AXNAppCell *cell = (AXNAppCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.selected) {
        self.selectedBundleIdentifier = nil;
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
        return NO;
    } else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AXNAppCell *cell = (AXNAppCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.selectedBundleIdentifier = cell.bundleIdentifier;
    
    self.clvc.axnAllowChanges = YES;
    for (id req in [AXNManager sharedInstance].notificationRequests[cell.bundleIdentifier]) {
        [self.clvc insertNotificationRequest:req forCoalescedNotification:nil];
    }
    self.clvc.axnAllowChanges = NO;
    
    [self.clvc setDidPlayRevealHaptic:YES];
    [self.clvc forceNotificationHistoryRevealed:YES animated:NO];
    [self.clvc setNotificationHistorySectionNeedsReload:YES];
    [self.clvc _reloadNotificationHistorySectionIfNecessary];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.clvc.axnAllowChanges = YES;
    for (id req in [self.clvc allNotificationRequests]) {
        [self.clvc removeNotificationRequest:req forCoalescedNotification:nil];
    }
    self.clvc.axnAllowChanges = NO;

    [self.clvc forceNotificationHistoryRevealed:NO animated:NO];
    [self.clvc setNotificationHistorySectionNeedsReload:YES];
    [self.clvc _reloadNotificationHistorySectionIfNecessary];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.style) {
        case 1: return CGSizeMake(64, 64);
        case 2: return CGSizeMake(48, 48);
        default: return CGSizeMake(64, 90); 
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat spacing = [(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacing];
    CGFloat width = 64;

    if (self.style == 2) width = 48;

    NSInteger count = [self collectionView:collectionView numberOfItemsInSection:section];
    CGFloat totalCellWidth = width * count;
    CGFloat totalSpacingWidth = spacing * (count - 1);
    if (totalSpacingWidth < 0) totalSpacingWidth = 0;

    CGFloat leftInset = (self.bounds.size.width - (totalCellWidth + totalSpacingWidth)) / 2;
    if (leftInset < 0) {
        UIEdgeInsets inset = [(UICollectionViewFlowLayout *)collectionViewLayout sectionInset];
        return inset;
    }
    CGFloat rightInset = leftInset;
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    return sectionInset;
}

- (void)refresh {
    [self.list removeAllObjects];
    NSArray *sortedKeys = @[];

    for (NSString *key in [AXNManager sharedInstance].names) {
        NSString *val = [AXNManager sharedInstance].names[key];
        NSLog(@"[Axon] names, %@ = %@", key, val);
    }

    switch (self.sortingMode) {
        case 1:
            sortedKeys = [[[AXNManager sharedInstance].notificationRequests allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSInteger first = [[AXNManager sharedInstance].notificationRequests[a] count];
                NSInteger second = [[AXNManager sharedInstance].notificationRequests[b] count];
                if (first < second) return (NSComparisonResult)NSOrderedDescending;
                if (first > second) return (NSComparisonResult)NSOrderedAscending;
                return (NSComparisonResult)NSOrderedSame;
            }];
            break;
        default:
            sortedKeys = [[[AXNManager sharedInstance].notificationRequests allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSString *first = [[AXNManager sharedInstance].names objectForKey:a];
                NSString *second = [[AXNManager sharedInstance].names objectForKey:b];
                return [first compare:second];
            }];
    }

    for (NSString *key in sortedKeys) {
        NSInteger count = [[AXNManager sharedInstance].notificationRequests[key] count];
        if (count == 0) continue;
        [self.list addObject:@{
            @"bundleIdentifier": key,
            @"notificationCount": @(count)
        }];
    }

    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [self.sbclvc _setListHasContent:([self.list count] > 0)];
}

/* Compatibility stuff to keep it from safe moding. */

-(void)setContentHost:(id)arg1 {}
-(void)setSizeToMimic:(CGSize)arg1 {}
-(void)_layoutContentHost {}
-(CGSize)sizeToMimic { return self.frame.size; }
-(id)contentHost { return nil; }
-(void)_updateSizeToMimic {}
-(unsigned long long)_optionsForMainOverlay { return 0; }

@end