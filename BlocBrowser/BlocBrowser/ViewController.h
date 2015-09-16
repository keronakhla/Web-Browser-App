//
//  ViewController.h
//  BlocBrowser
//
//  Created by Kerolos Nakhla on 9/14/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/**
 Replaces the web view with a fresh one, erasing all history. Also updates the toolbar and buttons appropriately.
 */
-(void) resetWebView;

@end

