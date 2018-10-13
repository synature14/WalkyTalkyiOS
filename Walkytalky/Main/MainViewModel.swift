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
    
    var numberOfRecords: Int = 0
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    let walkyTalkyService = Pairing()
    let viewAction = PublishSubject<ViewAction>()
    
    let connectedDeviceNames = Variable<[String]>([])
    let isAbleToRecord = Variable<Bool>(false)
    let audioData = Variable<Data?>(nil)
    
    override init() {
        super.init()
        walkyTalkyService.delegate = self
        setupAudio()
    }
    
    func requestShowTuneinChannel() {
        viewAction.onNext(.showTuneInChannel)
    }
    
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
    
    func directoryOfRecording() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

extension MainViewModel {
    public func startToRecord() {
        if audioRecorder == nil {
            numberOfRecords = 1
            let filename = directoryOfRecording().appendingPathComponent("\(numberOfRecords).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey : 1,
                            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue]
            // Start Audio Recording
            do {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
            } catch {
                print("error..!")
            }
        }
    }
    
    public func finishRecord() {
        // Stop audio recording
        audioRecorder.stop()
        audioRecorder = nil
        
        UserDefaults.standard.set(numberOfRecords, forKey: "walkyTalky")
        let fileURL = directoryOfRecording().appendingPathComponent("1.m4a")
        sendingRecord(path: fileURL)
    }
    
    private func sendingRecord(path: URL) {
        do {
            let recordedData = try Data(contentsOf: path)
            walkyTalkyService.sendData(data: recordedData)
            UserDefaults.standard.removeObject(forKey: "walkyTalky")
        } catch {
            print("Cannot Finish Record...! \n")
        }
    }
    
    public func playReceivedData(_ receivedData: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: receivedData)
            audioPlayer.play()
        } catch {
            print("cannot Play received Data")
        }
        
    }
}

extension MainViewModel: PairingDelegate {
    func connectedDevicesChanged(manager: Pairing, connectedDevices: [String]) {
        self.connectedDeviceNames.value = connectedDevices
    }
    
    func isAbleToConnect(bool: Bool) {
        self.isAbleToRecord.value = bool
    }
    
    func playRecord(manager: Pairing, audioData: Data) {
        self.audioData.value = audioData
    }
}
