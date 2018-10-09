//
//  ViewController.swift
//  Walkytalky
//
//  Created by sutie on 2018. 9. 26..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import AVFoundation

class MainViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords: Int = 0
    // 임시
    let dataString: String = "Touched..!"
    
    let walkyTalkyService = Pairing()
    
    @IBOutlet weak var recordBackColoredView: UIView!
    @IBOutlet weak var recordBtnBackView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    var circleView: CircleView!
    @IBOutlet weak var connectionLabel: UILabel!
    
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
        
//        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        viewModel.count.asObservable().subscribe().disposed(by: disposeBag)
    }
    
    private func setUI() {
        recordBackColoredView.cornerRadius = recordBackColoredView.frame.height * 0.5
        recordBtnBackView.cornerRadius = recordBtnBackView.frame.height * 0.5
        recordButton.cornerRadius = recordButton.frame.height * 0.5
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
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
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
            numberOfRecords += 1
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
                
                recordButton.setTitle("Recordiing..", for: .normal)
            } catch {
                print("error..!")
            }
        }
    }
    
    private func finishRecord() {
        // Stop audio recording
        audioRecorder.stop()
        audioRecorder = nil
        UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
        recordButton.setTitle("Start Recording", for: .normal)
    }
    
    @IBAction func playRecord(_ sender: Any) {
        let path = directoryOfRecording().appendingPathComponent("\(numberOfRecords).m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
            print("cannot play")
        }
    }

    private func playRecordFile() {
        let path = directoryOfRecording().appendingPathComponent("\(numberOfRecords).m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
            print("cannot play")
        }
    }
    
    
    @IBAction func sendStringData(_ sender: Any) {
        walkyTalkyService.sendString()
    }
    
}

extension MainViewController: PairingDelegate {
    func connectedDevicesChanged(manager: Pairing, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionLabel.text = "\(connectedDevices)"
        }
    }
    
    func playRecord(manager: Pairing, audioFile: AVAudioFile) {
        OperationQueue.main.addOperation {
            self.playRecordFile()
        }
    }
    
    func showText() {
        DispatchQueue.main.async {
            self.connectionLabel.text?.append(contentsOf: self.dataString)
        }
    }
}
