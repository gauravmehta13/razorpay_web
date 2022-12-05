#import "RazorpayFlutterPlugin.h"
#import <razorpay_web/razorpay_web-Swift.h>

@implementation RazorpayFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRazorpayFlutterPlugin registerWithRegistrar:registrar];
}
@end
