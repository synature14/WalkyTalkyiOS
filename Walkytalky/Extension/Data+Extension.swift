//
//  Data+Extension.swift
//  Walkytalky
//
//  Created by 안덕환 on 21/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import AVFoundation

extension Data {
    init(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        self.init(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
    }
    
    func convertToPCMBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let streamDesc = format.streamDescription.pointee
        let frameCapacity = UInt32(count) / streamDesc.mBytesPerFrame
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }
        
        buffer.frameLength = buffer.frameCapacity
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        
        withUnsafeBytes { addr in
            audioBuffer.mData?.copyMemory(from: addr, byteCount: Int(audioBuffer.mDataByteSize))
        }
        
        return buffer
    }
    
    func toPCMBuffer() -> AVAudioPCMBuffer? {
        guard
            let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 8000, channels: 1, interleaved: false),
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(self.count) / 2) else {
                return nil
        }
        audioBuffer.frameLength = audioBuffer.frameCapacity
        for i in 0 ..< self.count / 2 {
            // transform two bytes into a float (-1.0 - 1.0), required by the audio buffer
            audioBuffer.floatChannelData?.pointee[i] = Float(Int16(self[i*2+1]) << 8 | Int16(self[i*2]))/Float(INT16_MAX)
        }
        
        return audioBuffer
    }
}
