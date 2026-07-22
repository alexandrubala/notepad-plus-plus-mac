#pragma once
#import <Cocoa/Cocoa.h>

@class DocumentTabBar;

@protocol DocumentTabBarDelegate <NSObject>
- (void)documentTabBar:(DocumentTabBar *)bar didSelectTabAtIndex:(NSInteger)index;
- (void)documentTabBarDidRequestNewTab:(DocumentTabBar *)bar;
- (void)documentTabBar:(DocumentTabBar *)bar didRequestCloseTabAtIndex:(NSInteger)index;
@end

@interface DocumentTabBar : NSView
@property (nonatomic, weak) id<DocumentTabBarDelegate> delegate;
- (void)reloadWithTitles:(NSArray<NSString *> *)titles selectedIndex:(NSInteger)selectedIndex;
@end
