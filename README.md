## codec2-ios
### A lightweight swift wrapper for [Codec 2](http://www.rowetel.com/?page_id=452)
 This framework is based on [a fork of the Codec 2 source code](https://github.com/Beartooth/codec2-ios).
 The original source can be found on SVN [here](https://svn.code.sf.net/p/freetel/code/codec2-dev/) and
 on GitHub [here.](https://github.com/freedv/codec2)
 
## Installing

### Carthage 

TBD

## Building

### Required tools
- [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) 
- [Homebrew](https://brew.sh/)
- Cmake (`brew install cmake`)
- git (`brew install git`)

### Build steps
- Clone the repository: `git clone --recursive https://github.com/Beartooth/codec2-ios.git && cd codec2-ios`
- Build the Codec 2 dynamic libraries with `build_codec2.sh`
- Open the project in Xcode and build the `codec2_ios` scheme


## Contributors
[David Rowe](http://www.rowetel.com/) originally developed the codec, along with support from other researchers.  
[Jeff Jones](https://github.com/masterjefferson) developed the Swift port and cross compilation build script. 


  


