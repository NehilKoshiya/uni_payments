#import "UniPaymentsPlugin.h"
#if __has_include(<uni_payments/uni_payments-Swift.h>)
#import <uni_payments/uni_payments-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "uni_payments-Swift.h"
#endif

@implementation UniPaymentsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUniPaymentsPlugin registerWithRegistrar:registrar];
}
@end
