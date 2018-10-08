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
    var numberOfRecords: Int = 0
    
    @IBOutlet weak var recordBackColoredView: UIView!
    @IBOutlet weak var recordBtnBackView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    
    let viewModel = MainViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        setUI()
        
        recordButton.rx
            .longPressGesture()
            .when(UIGestureRecognizer.State.changed)
            .subscribe({ _ in
                self.recordBackColoredView.backgroundColor = UIColor.red
                self.startToRecord()
            })
            .disposed(by: disposeBag)
        
        recordButton.rx
            .longPressGesture()
            .when(UIGestureRecognizer.State.cancelled)
            .subscribe({ _ in
                self.cancelRecord()
                self.recordBtnBackView.backgroundColor = UIColor.white
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
    
    private func cancelRecord() {
        // Stop audio recording
        audioRecorder.stop()
        audioRecorder = nil
        UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
        recordButton.setTitle("Start Recording", for: .normal)
    }
    
//
//    private func bindViewModel() {
//        viewModel.count.asObservable()
//            .subscribe(onNext: { [weak self] num in
//                self?.countLabel.text = String(num)
//            })
//    }
//
//    @IBAction func tapButtonTapped(_ sender: Any) {
//        viewModel.count.value += 1
//    }
}

