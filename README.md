## codec2-ios
### A lightweight swift wrapper for [Codec 2](http://www.rowetel.com/?page_id=452)

Codec 2 is a low bitrate speech codec with compression modes ranging from 700 bit/s to 3200 bit/s. It is useful for voice
compression in bandwidth constrained environments. The codec accepts 16 bit 8Khz PCM audio as input.

This framework is based on [a fork of the Codec 2 source code](https://github.com/Beartooth/codec2-ios).
The original source can be found on SVN [here](https://svn.code.sf.net/p/freetel/code/codec2-dev/) and
on GitHub [here.](https://github.com/freedv/codec2)
 
## Installing

### Carthage 
- Add this line to your `Cartfile`: `github "Beartooth/codec2-ios" "master"`
- Use the typical [carthage workflow](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add `Codec2.framework` to your project.

## Usage

Instantiating a codec using 1.2kbps compression:
```swift
import Codec2

let codec = Codec2(mode: ._1200)!
let nBitsPerFrame = codec.bitsPerEncFrame
let nBytesPerFrame = codec.bytesPerEncFrame
let nSamplesPerFrame = codec.samplesPerFrame
```

Encoding and Decoding:
```swift
import Codec2

let codec = Codec2(mode: ._1200)!

func encodeVoiceFrame(_ toEnc: inout [Int16]) -> [UInt8]? {
  guard toEnc.count == codec.samplesPerFrame else { return nil }
  return codec.encode(speech: toEnc)
}

func decodeVoiceFrame(_ toDec: inout [UInt8]) -> [Int16]? {
  guard toDec.count == codec.bytesPerEncFrame else { return nil }
  return codec.decode(frame: toDec) 
}
```

## Building

### Required tools
- [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) 
- [Homebrew](https://brew.sh/)
- Cmake (`brew install cmake`)
- git (`brew install git`)

### Build steps
- Clone the repository: `git clone --recursive https://github.com/Beartooth/codec2-ios.git && cd codec2-ios/codec2-ios`
- Build the Codec 2 dynamic libraries with `build_codec2.sh`
- Open the project in Xcode and build the `codec2_ios` scheme


## Contributors
[David Rowe](http://www.rowetel.com/) originally developed the codec, along with support from other researchers.  
[Jeff Jones](https://github.com/masterjefferson) developed the Swift port and cross compilation build script. 


  


