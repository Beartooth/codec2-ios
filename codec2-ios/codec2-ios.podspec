Pod::Spec.new do |spec|

  spec.name         = "codec2-ios"
  spec.version      = "2.0.0"
  spec.summary      = "A lightweight Swift wrapper for Codec 2, a low bitrate speech codec."
  spec.description  = "Codec2 for iOS."

  spec.homepage     = "https://github.com/Beartooth/codec2-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "Patel, Alisha" => "alisha@beartooth.com" }

  spec.platform     = :ios, "12.0"

  spec.source       = { :git => "https://github.com/Beartooth/codec2-ios.git", :tag => "2.0.0" }

  spec.source_files  = "codec2-ios/**/*.{h,swift}"
  spec.swift_versions = '5.0'

  spec.module_map    = "codec2-ios/codec2_ios.modulemap"
end