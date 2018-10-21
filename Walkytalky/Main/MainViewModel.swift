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
    
    let connectedDeviceNames = Variable<[String]>([])
    let otherDeviceConnected = Variable<Bool>(false)
    let disposeBag = DisposeBag()
    
    // 지워질 프로퍼티
    let audioData = Variable<Data?>(nil)
    var chunkData: Data = Data()
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords: Int = 0
    
    override init() {
        super.init()
        walkyTalkyService.delegate = self
        setupAudio()
        bindRecordedVoiceToPairing()
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
    
    func playRecord(manager: Pairing, audioData: Data) {
        if chunkData.count > 1024 {
            print("\n\n PlayRecord : chunkData.count = \(chunkData.count)")
            self.audioData.value = audioData
            self.chunkData.removeAll()
        } else {
            self.chunkData.append(audioData)
        }
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
        do {
            audioPlayer = try AVAudioPlayer(data: receivedData)
            audioPlayer.play()
        } catch {
            print("- PlayReceivedData Fail: \(error.localizedDescription)")
        }
    }
}

extension MainViewModel {
    private func setupAudio() {
        recordingSession = AVAudioSession.sharedInstance()
        
        // 녹음 기록 불러와서 저장할 제목
        if let number: Int = UserDefaults.standard.object(forKey: "walkyTalky") as? Int {
            numberOfRecords = number
        }
        AVAudioSession.sharedInstance().requestRecordPermission({ hasPermission in
            if hasPermission { print("Accepted!") }
        })
    }
}

extension MainViewModel {
    private func bindRecordedVoiceToPairing() {
        voiceRecorder.onVoiceCaptured
            .bind(to: walkyTalkyService.receivedData)
            .disposed(by: disposeBag)
    }
}
