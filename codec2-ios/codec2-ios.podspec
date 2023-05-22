
Pod::Spec.new do |spec|



  spec.name         = "codec2-ios"
  spec.version      = "0.0.1"
  spec.summary      = "A lightweight swift wrapper for Codec 2.Codec 2 is a low bitrate speech codec with compression modes ranging from 700 bit/s to 3200 bit/s. It is useful for voice compression in bandwidth constrained environments. The codec accepts 16 bit 8Khz PCM audio as input."
  spec.description  = " Codec2 for IOS"

  spec.homepage     = "https://github.com/Beartooth/codec2-ios"
 

  spec.license      = "MIT"

  spec.author             = { "Patel, Alisha" => "alisha@beartooth.com" }

   spec.platform     = :ios
   spec.ios.deployment_target = "12.0"
   spec.osx.deployment_target = "10.7"
   spec.watchos.deployment_target = "2.0"
   spec.tvos.deployment_target = "9.0"
 spec.swift_versions = '5.0'

  spec.source       = { :git => "https://github.com/Beartooth/codec2-ios.git", :tag => "1.0" }


 

  spec.source_files  = "codec2-ios", "codec2-ios/**/*.{h,swift}"

 


end
