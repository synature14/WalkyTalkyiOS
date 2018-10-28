//
//  VoiceRecorder.swift
//  Walkytalky
//
//  Created by 안덕환 on 21/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift

class VoiceRecorder {
    let onVoiceCaptured = PublishSubject<AudioBlock>()
    
    private lazy var audioEngine: AVAudioEngine = {
        let audioEngine = AVAudioEngine()
        let format = audioEngine.inputNode.inputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] (buffer, time) in
            let data = Data(buffer: buffer, time: time)
            let audioBlock = AudioBlock(format: buffer.format.settings, audioData: data)
            self?.onVoiceCaptured.onNext(audioBlock)
        }
        return audioEngine
    }()
    
    func startRecording() {
        do {
            try audioEngine.start()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
    }
}

