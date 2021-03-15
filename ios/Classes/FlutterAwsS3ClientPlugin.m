#import "FlutterAwsS3ClientPlugin.h"
#if __has_include(<flutter_aws_s3_client/flutter_aws_s3_client-Swift.h>)
#import <flutter_aws_s3_client/flutter_aws_s3_client-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_aws_s3_client-Swift.h"
#endif

@implementation FlutterAwsS3ClientPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAwsS3ClientPlugin registerWithRegistrar:registrar];
}
@end
