#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'razorpay_web'
  s.version          = '1.1.10'
  s.summary          = 'Flutter plugin for Razorpay SDK.'
  s.description      = 'Flutter plugin for Razorpay SDK.'
  s.homepage         = 'https://github.com/razorpay/razorpay-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Gaurav Yadav' => '269mehta@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  # Pinned to 1.3.2 - versions 1.4.0+ require displayController parameter in open() method
  # which breaks compatibility with current implementation. Update requires view controller
  # management changes in SwiftRazorpayFlutterPlugin.
  s.dependency 'razorpay-pod', '1.3.2'

  s.ios.deployment_target = '10.0'
end
