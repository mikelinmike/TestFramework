Pod::Spec.new do |spec|

  spec.name         = 'TestFramework'
  spec.version      = '1.0.0'
  spec.summary      = 'Test of TestFramework.'


  spec.description  = <<-DESC
  TODO: Add long description of the pod here!.
                   DESC

  spec.homepage     = 'http://github.com/mikelinmike/TestFramework'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'mikelin' => 'mikelin@wondercore.com' }
 

  spec.source       = { :git => 'https://github.com/mikelinmike/TestFramework.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '10.0'

  spec.source_files  = 'TestFramework/TestFramework/**/*'

  spec.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }


  # spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"
   # spec.dependency 'RxSwift', '5.1.1'
   # spec.dependency 'PhysData'
   # spec.dependency 'FitnessDevice'


end
