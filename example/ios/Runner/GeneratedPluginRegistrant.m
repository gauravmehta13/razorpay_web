//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<fluttertoast/FluttertoastPlugin.h>)
#import <fluttertoast/FluttertoastPlugin.h>
#else
@import fluttertoast;
#endif

#if __has_include(<razorpay_web/RazorpayFlutterPlugin.h>)
#import <razorpay_web/RazorpayFlutterPlugin.h>
#else
@import razorpay_web;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FluttertoastPlugin registerWithRegistrar:[registry registrarForPlugin:@"FluttertoastPlugin"]];
  [RazorpayFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"RazorpayFlutterPlugin"]];
}

@end
