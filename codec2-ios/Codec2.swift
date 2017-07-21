/*
 
 Copyright © 2017 Jefferson Jones. All rights reserved.
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License version 2.1, as
 published by the Free Software Foundation.  This program is
 distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or
 FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
 License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with this program; if not, see <http://www.gnu.org/licenses/>.
 */

import Foundation


/**
 Codec2 - A swift wrapper for the open source speech codec.
 
 [David Rowe](http://www.rowetel.com/) originally developed the codec, along with support from other researchers.
 
 This framework is based on [a fork of the Codec 2 source code](https://github.com/Beartooth/codec2-ios).
 The original source can be found on SVN [here](https://svn.code.sf.net/p/freetel/code/codec2-dev/) and
 on GitHub [here](https://github.com/freedv/codec2)
 
 Codec 2 has 7 compression modes ranging from 700 bits/s to 3200 bits/s.
 
 Currently this wrapper only exposes the standard encode and decode functions.
 
 */
public class Codec2 {
  
  /**
   Codec 2 Bitrate settings (mode).
   */
  public enum Bitrate: Int32 {
    /// 700 bps
    case _700  = 7
    /// 700 bps (improved)
    case _700b = 6
    /// 1.2 kbps
    case _1200 = 5
    /// 1.3 kbps
    case _1300 = 4
    /// 1.4 kbps
    case _1400 = 3
    /// 1.6 kbps
    case _1600 = 2
    /// 2.4 kbps
    case _2400 = 1
    /// 3.2 kbps
    case _3200 = 0
  }
  
  /// The number of audio samples per voice frame (decoded).
  public var samplesPerFrame: Int {
    get {
      return Int(codec2_samples_per_frame(cPtr))
    }
  }
  
  /// The number of bits per voice frame (encoded).
  public var bitsPerEncFrame: Int {
    get {
      return Int(codec2_bits_per_frame(cPtr))
    }
  }
  /// The number of bytes per voice frame (encoded).
  public var bytesPerEncFrame: Int {
    return (bitsPerEncFrame + 7) / 8
  }
  
  /// Duration of a voice frame, in milliseconds.
  public var frameDurationMs: Int {
    get {
      switch bitrate {
      case ._2400, ._3200:
        return 20
      default:
        return 40
      }
    }
  }
  
  private let bitrate: Bitrate
  private let cPtr: OpaquePointer
  
  init?(mode: Bitrate) {
    guard let instance = codec2_create(mode.rawValue) else {return nil}
    self.cPtr = instance
    self.bitrate = mode
  }
  
  deinit {
    codec2_destroy(cPtr)
  }
  
  /**
   Encodes one voice frame
   
   - parameter speech:  Speech audio to encode. The length of the buffer should match
   `samplesPerFrame`.
   
   - returns: An an encoded voice frame, packed into a byte array.
   */
  public func encode(speech: inout [Int16]) -> [UInt8] {
    var encoded = [UInt8](repeating: 0, count: bitsPerEncFrame)
    codec2_encode(cPtr, &encoded, &speech)
    return encoded
  }
  
  /**
   Decodes one voice frame.
   
   - parameter frame: The frame to decode.
   
   - returns: A decoded voice frame (audio buffer).
   */
  public func decode(frame: inout [UInt8]) -> [Int16] {
    var decoded = [Int16](repeating: 0, count: samplesPerFrame)
    codec2_decode(cPtr, &decoded, &frame)
    return decoded
  }
  
  
  
  
  
}
