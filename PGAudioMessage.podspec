#
# Be sure to run `pod lib lint PGAudioMessage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PGAudioMessage'
  s.version          = '0.1.0'
  s.summary          = 'A short description of PGAudioMessage.'
  s.description      = "Do something"

  s.homepage         = 'https://github.com/ipagong/PGAudioMessage'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ipagong' => 'ipagong.dev@gmail.com' }
  s.source           = { :git => 'https://github.com/ipagong/PGAudioMessage.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'

  s.source_files = 'PGAudioMessage/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PGAudioMessage' => ['PGAudioMessage/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
