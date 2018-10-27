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
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        return audioEngine
    }()
    private let playerNode = AVAudioPlayerNode()
    
    init() {
        bindReceivedData()
    }
    
    private func bindReceivedData() {
        receivedData
            .map { $0.convertToPCMBuffer(format: AVAudioFormat()) }
            .filterOptional()
            .subscribe(onNext: { [weak self] pcmBuffer in
                self?.playerNode.scheduleBuffer(pcmBuffer, completionHandler: nil)
            }).disposed(by: disposeBag)
    }
}
