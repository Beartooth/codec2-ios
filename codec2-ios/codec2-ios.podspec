
Pod::Spec.new do |spec|



  spec.name         = "codec2-ios"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of codec2-ios."
  spec.description  = " Codec2 for IOS"

  spec.homepage     = "https://github.com/Beartooth/codec2-ios"
 

  spec.license      = "MIT"

  spec.author             = { "Patel, Alisha" => "alisha@beartooth.com" }

   spec.platform     = :ios
   spec.ios.deployment_target = "12.0"
   spec.osx.deployment_target = "10.7"
   spec.watchos.deployment_target = "2.0"
   spec.tvos.deployment_target = "9.0"

  spec.source       = { :git => "https://github.com/Beartooth/codec2-ios", :tag => "1.0" }


 

  spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"

  spec.public_header_files = "Classes/**/*.h"


end
