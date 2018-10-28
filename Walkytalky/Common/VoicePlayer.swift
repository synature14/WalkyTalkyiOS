//
//  VoicePlayer.swift
//  Walkytalky
//
//  Created by thekan on 24/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import AVFoundation
import RxCocoa
import RxSwift

class VoicePlayer {
    
    let receivedData = PublishSubject<AudioBlock>()
    let disposeBag = DisposeBag()
    
    private lazy var audioEngine: AVAudioEngine = {
        let audioEngine = AVAudioEngine()
        audioEngine.attach(playerNode)
//        do {
//            try audioEngine.start()
//        } catch {
//            print(error.localizedDescription)
//        }
        return audioEngine
    }()
    private let playerNode = AVAudioPlayerNode()
    
    init() {
        bindReceivedData()
    }
    
    private func bindReceivedData() {
        receivedData
            .do(onNext: { audioBlock in
                self.audioEngine.connect(
                    self.playerNode,
                    to: self.audioEngine.mainMixerNode,
                    format: AVAudioFormat(settings: audioBlock.format))
            })
            .map { $0.audioData.toPCMBuffer() }
            .filterOptional()
            .do(onNext: {
                if !self.playerNode.isPlaying {
                    self.audioEngine.prepare()
                    try? self.audioEngine.start()
                    self.playerNode.play()
                }
                print($0)
            })
            .subscribe(onNext: { [weak self] pcmBuffer in
                self?.playerNode.scheduleBuffer(pcmBuffer, at: nil, options: .interruptsAtLoop, completionHandler: nil)
            }).disposed(by: disposeBag)
    }
}
