#
# Be sure to run `pod lib lint XJUtil.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XJUtil'
  s.version          = '0.1.84'
  s.summary          = 'A short description of XJUtil.'
  s.homepage         = 'https://github.com/xjimi/XJUtil'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xjimi' => 'fn5128@gmail.com' }
  s.source           = { :git => 'https://github.com/xjimi/XJUtil.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'XJUtil/Classes/**/*'
  s.frameworks = 'UIKit', 'Foundation'
  
  s.dependency 'Reachability'
  s.dependency 'PINRemoteImage', '<= 3.0.0-beta.13'

  # s.resource_bundles = {
  #   'XJUtil' => ['XJUtil/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'

end
