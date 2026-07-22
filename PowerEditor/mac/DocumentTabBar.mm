#import "DocumentTabBar.h"

static const CGFloat kTabBarHeight = 36.0;
static const CGFloat kTabHeight = 24.0;
static const CGFloat kCloseSize = 14.0;

@interface DocumentTabButton : NSView
@property (nonatomic, assign) NSInteger tabIndex;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL showsCloseOnHover;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selectAction;
@property (nonatomic, assign) SEL closeAction;
@end

@interface DocumentTabButton ()
@property (nonatomic, strong) NSTextField *titleField;
@property (nonatomic, strong) NSButton *closeButton;
@property (nonatomic, strong) NSLayoutConstraint *titleTrailingConstraint;
@property (nonatomic, assign) BOOL hovered;
@end

@implementation DocumentTabButton

- (instancetype)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.wantsLayer = YES;
		self.layer.cornerRadius = 6.0;

		_titleField = [[NSTextField alloc] initWithFrame:NSZeroRect];
		_titleField.editable = NO;
		_titleField.bordered = NO;
		_titleField.drawsBackground = NO;
		_titleField.font = [NSFont systemFontOfSize:12 weight:NSFontWeightMedium];
		_titleField.alignment = NSTextAlignmentCenter;
		_titleField.lineBreakMode = NSLineBreakByTruncatingTail;
		_titleField.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_titleField];

		_closeButton = [NSButton buttonWithImage:[NSImage imageWithSystemSymbolName:@"xmark"
		                                                  accessibilityDescription:@"Close"]
		                                  target:self
		                                  action:@selector(closeClicked:)];
		_closeButton.bezelStyle = NSBezelStyleInline;
		_closeButton.bordered = NO;
		_closeButton.hidden = YES;
		_closeButton.toolTip = @"Close";
		_closeButton.translatesAutoresizingMaskIntoConstraints = NO;
		_closeButton.symbolConfiguration = [NSImageSymbolConfiguration configurationWithPointSize:9 weight:NSFontWeightBold];
		[self addSubview:_closeButton];

		_titleTrailingConstraint = [_titleField.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10];
		[NSLayoutConstraint activateConstraints:@[
			[_titleField.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
			_titleTrailingConstraint,
			[_titleField.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
			[_closeButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-4],
			[_closeButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
			[_closeButton.widthAnchor constraintEqualToConstant:kCloseSize],
			[_closeButton.heightAnchor constraintEqualToConstant:kCloseSize],
		]];
	}
	return self;
}

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	for (NSTrackingArea *area in [self.trackingAreas copy]) {
		[self removeTrackingArea:area];
	}
	NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:NSZeroRect
	                                                    options:(NSTrackingMouseEnteredAndExited |
	                                                             NSTrackingActiveInKeyWindow |
	                                                             NSTrackingInVisibleRect)
	                                                      owner:self
	                                                   userInfo:nil];
	[self addTrackingArea:area];
}

- (void)setTitle:(NSString *)title
{
	_title = [title copy];
	self.titleField.stringValue = title ?: @"";
}

- (void)setSelected:(BOOL)selected
{
	_selected = selected;
	[self refreshAppearance];
}

- (void)setShowsCloseOnHover:(BOOL)showsCloseOnHover
{
	_showsCloseOnHover = showsCloseOnHover;
	[self refreshCloseVisibility];
}

- (void)mouseEntered:(NSEvent *)event
{
	self.hovered = YES;
	[self refreshAppearance];
	[self refreshCloseVisibility];
}

- (void)mouseExited:(NSEvent *)event
{
	self.hovered = NO;
	[self refreshAppearance];
	[self refreshCloseVisibility];
}

- (void)mouseDown:(NSEvent *)event
{
	NSPoint local = [self convertPoint:event.locationInWindow fromView:nil];
	if (!self.closeButton.hidden && NSPointInRect(local, self.closeButton.frame)) {
		[self closeClicked:self.closeButton];
		return;
	}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[self.target performSelector:self.selectAction withObject:self];
#pragma clang diagnostic pop
}

- (void)closeClicked:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[self.target performSelector:self.closeAction withObject:self];
#pragma clang diagnostic pop
}

- (void)refreshCloseVisibility
{
	BOOL show = self.showsCloseOnHover && self.hovered;
	self.closeButton.hidden = !show;
	self.titleTrailingConstraint.constant = show ? -22 : -10;
}

- (void)refreshAppearance
{
	BOOL dark = [[self.effectiveAppearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]]
	             isEqualToString:NSAppearanceNameDarkAqua];
	if (self.selected) {
		self.layer.backgroundColor = [NSColor controlAccentColor].CGColor;
		self.titleField.textColor = [NSColor whiteColor];
		self.closeButton.contentTintColor = [NSColor whiteColor];
	} else if (self.hovered) {
		NSColor *hover = dark ? [NSColor colorWithWhite:1 alpha:0.12] : [NSColor colorWithWhite:0 alpha:0.08];
		self.layer.backgroundColor = hover.CGColor;
		self.titleField.textColor = [NSColor labelColor];
		self.closeButton.contentTintColor = [NSColor secondaryLabelColor];
	} else {
		self.layer.backgroundColor = [NSColor clearColor].CGColor;
		self.titleField.textColor = [NSColor secondaryLabelColor];
		self.closeButton.contentTintColor = [NSColor secondaryLabelColor];
	}
}

- (void)viewDidChangeEffectiveAppearance
{
	[super viewDidChangeEffectiveAppearance];
	[self refreshAppearance];
}

- (NSSize)intrinsicContentSize
{
	NSSize titleSize = [self.titleField.stringValue sizeWithAttributes:@{
		NSFontAttributeName: self.titleField.font
	}];
	CGFloat width = MAX(72.0, MIN(220.0, ceil(titleSize.width) + 28.0));
	if (self.showsCloseOnHover) {
		width += 8.0;
	}
	return NSMakeSize(width, kTabHeight);
}

@end

@interface DocumentTabBar ()
@property (nonatomic, strong) NSStackView *rowStack;
@property (nonatomic, strong) NSButton *addButton;
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation DocumentTabBar

- (instancetype)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.wantsLayer = YES;
		_selectedIndex = -1;

		_rowStack = [NSStackView stackViewWithViews:@[]];
		_rowStack.orientation = NSUserInterfaceLayoutOrientationHorizontal;
		_rowStack.alignment = NSLayoutAttributeCenterY;
		_rowStack.spacing = 4;
		_rowStack.edgeInsets = NSEdgeInsetsMake(0, 0, 0, 0);
		_rowStack.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_rowStack];

		_addButton = [NSButton buttonWithImage:[NSImage imageWithSystemSymbolName:@"plus"
		                                                 accessibilityDescription:@"New"]
		                                target:self
		                                action:@selector(addClicked:)];
		_addButton.bezelStyle = NSBezelStyleInline;
		_addButton.bordered = NO;
		_addButton.toolTip = @"New File";
		_addButton.symbolConfiguration = [NSImageSymbolConfiguration configurationWithPointSize:11 weight:NSFontWeightSemibold];
		_addButton.contentTintColor = [NSColor secondaryLabelColor];
		_addButton.translatesAutoresizingMaskIntoConstraints = NO;
		[_addButton.widthAnchor constraintEqualToConstant:22].active = YES;
		[_addButton.heightAnchor constraintEqualToConstant:22].active = YES;

		NSBox *separator = [[NSBox alloc] initWithFrame:NSZeroRect];
		separator.boxType = NSBoxSeparator;
		separator.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:separator];

		NSLayoutConstraint *centerX = [_rowStack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor];
		centerX.priority = NSLayoutPriorityDefaultHigh;
		[NSLayoutConstraint activateConstraints:@[
			[_rowStack.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
			centerX,
			[_rowStack.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:8],
			[_rowStack.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-8],
			[separator.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
			[separator.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
			[separator.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
			[separator.heightAnchor constraintEqualToConstant:1],
		]];
	}
	return self;
}

- (NSSize)intrinsicContentSize
{
	return NSMakeSize(NSViewNoIntrinsicMetric, kTabBarHeight);
}

- (void)clearRowStack
{
	NSArray<NSView *> *arranged = [self.rowStack.arrangedSubviews copy];
	for (NSView *view in arranged) {
		[self.rowStack removeArrangedSubview:view];
		[view removeFromSuperview];
	}
}

- (void)reloadWithTitles:(NSArray<NSString *> *)titles selectedIndex:(NSInteger)selectedIndex
{
	self.titles = [titles copy] ?: @[];
	self.selectedIndex = selectedIndex;
	BOOL allowClose = self.titles.count >= 2;

	[self clearRowStack];

	for (NSInteger i = 0; i < (NSInteger)self.titles.count; i++) {
		DocumentTabButton *tab = [[DocumentTabButton alloc] initWithFrame:NSZeroRect];
		tab.tabIndex = i;
		tab.title = self.titles[i];
		tab.selected = (i == selectedIndex);
		tab.showsCloseOnHover = allowClose;
		tab.target = self;
		tab.selectAction = @selector(tabSelected:);
		tab.closeAction = @selector(tabClosed:);
		tab.translatesAutoresizingMaskIntoConstraints = NO;
		[tab.heightAnchor constraintEqualToConstant:kTabHeight].active = YES;
		[tab.widthAnchor constraintEqualToConstant:tab.intrinsicContentSize.width].active = YES;
		[self.rowStack addArrangedSubview:tab];
	}

	[self.rowStack addArrangedSubview:self.addButton];
	[self refreshBackground];
}

- (void)refreshBackground
{
	self.layer.backgroundColor = [NSColor windowBackgroundColor].CGColor;
}

- (void)viewDidChangeEffectiveAppearance
{
	[super viewDidChangeEffectiveAppearance];
	[self refreshBackground];
}

- (void)tabSelected:(DocumentTabButton *)tab
{
	[self.delegate documentTabBar:self didSelectTabAtIndex:tab.tabIndex];
}

- (void)tabClosed:(DocumentTabButton *)tab
{
	[self.delegate documentTabBar:self didRequestCloseTabAtIndex:tab.tabIndex];
}

- (void)addClicked:(id)sender
{
	[self.delegate documentTabBarDidRequestNewTab:self];
}

@end
