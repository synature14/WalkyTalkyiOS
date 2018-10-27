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
    
    let receivedData = PublishSubject<Data>()
    let disposeBag = DisposeBag()
    
    private lazy var audioEngine: AVAudioEngine = {
        let audioEngine = AVAudioEngine()
//        audioEngine.attach(playerNode)
//        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
//        audioEngine.prepare()
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
            .map { $0.toPCMBuffer() }
            .filterOptional()
            .do(onNext: {
                if !self.playerNode.isPlaying {
                    self.audioEngine.attach(self.playerNode)
                    self.audioEngine.connect(self.playerNode, to: self.audioEngine.mainMixerNode, format: $0.format)
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
