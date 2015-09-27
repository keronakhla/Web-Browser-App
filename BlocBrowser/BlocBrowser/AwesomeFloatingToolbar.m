//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Kerolos Nakhla on 9/15/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
/*****************************/
@property (nonatomic, strong) NSArray *buttons;
/*****************************/
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
/*****************************/
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
/*****************************/
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
/*****************************/


@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            [button setTitle:titleForThisButton forState:normal];
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitleColor:[UIColor whiteColor] forState:normal];
            button.backgroundColor = colorForThisButton;
            
            [button addTarget:self action:@selector(tapFired:) forControlEvents:UIControlEventTouchUpInside];
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        // #1
        //self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        //[self addGestureRecognizer:self.tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        /*****************************/
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        /*****************************/
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:self.longPressGesture];
        /*****************************/

    }
    
    return self;
}

- (void) tapFired:(UIButton *)button {
    NSString *buttonTitle = button.titleLabel.text;
    
    if ([self.buttons containsObject:button]){
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:buttonTitle];
        }
    }
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

/*****************************************/
- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:recognizer.scale];
        }
    }
}
/*****************************************/
- (void) longPress: (UILongPressGestureRecognizer *) recognizer{
    NSArray *newColors = @[self.colors[1], self.colors[2], self.colors[3], self.colors[0]];
    self.colors = newColors;
    NSUInteger i = 0;
    for (UIButton *button in self.buttons) {
        UIColor *colorForButton = [self.colors objectAtIndex:i];
        button.backgroundColor = colorForButton; i++;
    }
}
/*****************************/

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust labelX and labelY for each label
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            buttonX = 0;
        } else {
            // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
}

#pragma mark - Touch Handling

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UILabel class]]) {
        return (UILabel *)subview;
    } else {
        return nil;
    }
}


#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}


@end
