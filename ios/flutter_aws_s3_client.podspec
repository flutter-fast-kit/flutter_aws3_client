#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_aws_s3_client.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_aws_s3_client'
  s.version          = '1.0.0'
  s.summary          = 'Amazon S3 plugin for Flutter.'
  s.description      = <<-DESC
Amazon S3 plugin for Flutter.
                       DESC
  s.homepage         = 'https://github.com/flutter-fast-kit/flutter_aws3_client'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SimMan' => 'lunnnnul@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'AWSS3'
  s.dependency 'AWSCore'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
