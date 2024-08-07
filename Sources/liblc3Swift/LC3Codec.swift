//
//  File.swift
//  
//
//  Created by Rishabh Kumar on 7/30/24.
//

import Foundation
import liblc3C

public class LC3Codec {
    public enum PCMFormat {
        case s16
        case s24
        case s24_3le
        case float
        
        var cValue: lc3_pcm_format {
            switch self {
            case .s16: return LC3_PCM_FORMAT_S16
            case .s24: return LC3_PCM_FORMAT_S24
            case .s24_3le: return LC3_PCM_FORMAT_S24_3LE
            case .float: return LC3_PCM_FORMAT_FLOAT
            }
        }
    }
    
    public class Encoder {
        private var encoder: lc3_encoder_t?
        private var encoderMemory: UnsafeMutableRawPointer
        
        public init?(hrmode: Bool = false, dtUs: Int32, srHz: Int32, srPcmHz: Int32 = 0) {
            let encoderSize = lc3_hr_encoder_size(hrmode, dtUs, srHz)
            encoderMemory = UnsafeMutableRawPointer.allocate(byteCount: Int(encoderSize), alignment: MemoryLayout<Int>.alignment)
            
            encoder = lc3_hr_setup_encoder(hrmode, dtUs, srHz, srPcmHz, encoderMemory)
            
            if encoder == nil {
                encoderMemory.deallocate()
                return nil
            }
        }
        
        deinit {
            encoderMemory.deallocate()
        }
        
        public func encode(pcm: UnsafeRawPointer, stride: Int32, format: PCMFormat, bytes: Int32) -> [UInt8]? {
            var output = [UInt8](repeating: 0, count: Int(bytes))
            
            let result = output.withUnsafeMutableBufferPointer { outputBuffer in
                lc3_encode(encoder, format.cValue, pcm, stride, bytes, outputBuffer.baseAddress)
            }
            
            return result == 0 ? output : nil
        }
    }
    
    public class Decoder {
        private var decoder: lc3_decoder_t?
        private var decoderMemory: UnsafeMutableRawPointer
        
        public init?(hrmode: Bool = false, dtUs: Int32, srHz: Int32, srPcmHz: Int32 = 0) {
            let decoderSize = lc3_hr_decoder_size(hrmode, dtUs, srHz)
            decoderMemory = UnsafeMutableRawPointer.allocate(byteCount: Int(decoderSize), alignment: MemoryLayout<Int>.alignment)
            
            decoder = lc3_hr_setup_decoder(hrmode, dtUs, srHz, srPcmHz, decoderMemory)
            
            if decoder == nil {
                decoderMemory.deallocate()
                return nil
            }
        }
        
        deinit {
            decoderMemory.deallocate()
        }
        
        public func decode(input: UnsafeRawPointer?, bytes: Int32, format: PCMFormat, pcm: UnsafeMutableRawPointer, stride: Int32) -> Int32 {
            return lc3_decode(decoder, input, bytes, format.cValue, pcm, stride)
        }
    }
    
    public static func frameSamples(hrmode: Bool, dtUs: Int32, srHz: Int32) -> Int32 {
        return lc3_hr_frame_samples(hrmode, dtUs, srHz)
    }
    
    public static func frameBytes(hrmode: Bool, dtUs: Int32, srHz: Int32, bitrate: Int32) -> Int32 {
            return lc3_hr_frame_bytes(hrmode, dtUs, srHz, bitrate)
        }
        
    public static func frameBlockBytes(hrmode: Bool, dtUs: Int32, srHz: Int32, nchannels: Int32, bitrate: Int32) -> Int32 {
        return lc3_hr_frame_block_bytes(hrmode, dtUs, srHz, nchannels, bitrate)
    }
    
    public static func resolveBitrate(hrmode: Bool, dtUs: Int32, srHz: Int32, nbytes: Int32) -> Int32 {
        return lc3_hr_resolve_bitrate(hrmode, dtUs, srHz, nbytes)
    }
    
    public static func delaySamples(hrmode: Bool, dtUs: Int32, srHz: Int32) -> Int32 {
        return lc3_hr_delay_samples(hrmode, dtUs, srHz)
    }
}

