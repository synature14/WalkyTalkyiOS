//
//  MainViewModel.swift
//  Walkytalky
//
//  Created by sutie on 2018. 9. 26..
//  Copyright © 2018년 sutie. All rights reserved.
//

import Foundation
import RxSwift
import AVFoundation
import RxCocoa

class MainViewModel: NSObject, AVAudioRecorderDelegate {
    
    enum ViewAction {
        case recordStarted
        case recordFinished
        case showTuneInChannel
        case back
    }
    
    let viewAction = PublishSubject<ViewAction>()
    
    let walkyTalkyService = Pairing()
    let voiceRecorder = VoiceRecorder()
    let voicePlayer = VoicePlayer()
    
    let connectedDeviceNames = Variable<[String]>([])
    let otherDeviceConnected = Variable<Bool>(false)
    let voiceReceived = BehaviorRelay(value: false)
    let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        walkyTalkyService.delegate = self
        setupAudio()
        bindRecordedVoiceToPairing()
        bindReceivedVoiceFromPairing()
        bindVoicePlayer()
    }
    
    func requestShowTuneinChannel() {
        viewAction.onNext(.showTuneInChannel)
    }
}

extension MainViewModel: PairingDelegate {
    func connectedDevicesChanged(manager: Pairing, connectedDevices: [String]) {
        self.connectedDeviceNames.value = connectedDevices
    }
    
    func isAbleToConnect(bool: Bool) {
        self.otherDeviceConnected.value = bool
    }
}

extension MainViewModel {
    public func startToRecord() {
        voiceRecorder.startRecording()
    }
    
    public func finishRecord() {
        voiceRecorder.stopRecording()
    }
    
    public func playReceivedData(_ receivedData: Data) {

    }
}

extension MainViewModel {
    private func setupAudio() {
        AVAudioSession.sharedInstance().requestRecordPermission({ hasPermission in
            if hasPermission { print("Accepted!") }
        })
    }
}

extension MainViewModel {
    private func bindRecordedVoiceToPairing() {
        voiceRecorder.onVoiceCaptured
            .bind(to: walkyTalkyService.dataToTransfer)
            .disposed(by: disposeBag)
    }
    
    private func bindReceivedVoiceFromPairing() {
        walkyTalkyService.receivedData
            .do(onNext: {
                print("recorded voice catched \($0.count)")
            })
            .map { _ in true }
            .bind(to: voiceReceived)
            .disposed(by: disposeBag)
    }
    
    private func bindVoicePlayer() {
        walkyTalkyService.receivedData
            .do(onNext: {
                print("play voice \($0.count)")
            })
            .bind(to: self.voicePlayer.receivedData)
            .disposed(by: disposeBag)
    }
}
