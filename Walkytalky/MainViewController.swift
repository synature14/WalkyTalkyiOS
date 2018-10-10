//
//  ViewController.swift
//  Walkytalky
//
//  Created by sutie on 2018. 9. 26..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture
import AVFoundation
import NVActivityIndicatorView

class MainViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords: Int = 0
    var receivedData: Data?
    
    let walkyTalkyService = Pairing()
    
    @IBOutlet weak var recordBackColoredView: UIView!
    @IBOutlet weak var recordBtnBackView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    var circleView: CircleView!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var receivedAlarmLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    let viewModel = MainViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        setUI()
        walkyTalkyService.delegate = self

        recordButton.rx
            .longPressGesture()
            .when(UIGestureRecognizer.State.began)
            .subscribe({ _ in
                self.addCircleView()
                self.startToRecord()
            })
            .disposed(by: disposeBag)

        recordButton.rx
            .longPressGesture()
            .when(UIGestureRecognizer.State.ended)
            .subscribe({ _ in
                self.circleView.removeFromSuperview()
                self.finishRecord()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setUI() {
        recordBackColoredView.cornerRadius = recordBackColoredView.frame.height * 0.5
        recordBtnBackView.cornerRadius = recordBtnBackView.frame.height * 0.5
        recordButton.cornerRadius = recordButton.frame.height * 0.5
        recordButton.setTitle("No one to talk", for: .disabled)
    }
    
    private func addCircleView() {
        let circleWidth = CGFloat(recordBackColoredView.frame.width)
        let circleHeight = circleWidth
        
        // Create a new CircleView
        circleView = CircleView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: circleWidth,
                                                  height: circleHeight))
        
        recordBackColoredView.addSubview(circleView)
        
        // Animate the drawing of the circle over the course of 1 second
        circleView.animateCircle(duration: 0.5)
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
    
    private func startToRecord() {
        if audioRecorder == nil {
            playButton.isEnabled = false
            
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
                
                recordButton.setTitle("Recording..", for: .normal)
            } catch {
                print("error..!")
            }
        }
    }
    
    private func finishRecord() {
        // Stop audio recording
        audioRecorder.stop()
        audioRecorder = nil
        UserDefaults.standard.set(numberOfRecords, forKey: "walkyTalky")
        recordButton.setTitle("Tap To Record", for: .normal)
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
    
    @IBAction func playMessage(_ sender: Any) {
        guard let message = receivedData else { return }
        do {
            audioPlayer = try AVAudioPlayer(data: message)
            audioPlayer.play()
        } catch {
            print("Cannot play...\n")
        }
    }
}

extension MainViewController: PairingDelegate {
    func connectedDevicesChanged(manager: Pairing, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionLabel.text = "\(connectedDevices)"
        }
    }
    
    func isAbleToConnect(bool: Bool) {
        if bool {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
    
    func playRecord(manager: Pairing, audioData: Data) {
        OperationQueue.main.addOperation {
            self.receivedAlarmLabel.text = "You got a message.\nPress the play button."
            self.playButton.isEnabled = true
            self.receivedData = audioData
        }
    }
}
