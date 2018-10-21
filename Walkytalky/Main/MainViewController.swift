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
import NVActivityIndicatorView

class MainViewController: UIViewController, Bindable {
    typealias ViewModelType = MainViewModel
    
    @IBOutlet weak var indicatorBackView: NVActivityIndicatorView!
    @IBOutlet weak var recordButtonIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var receivedAlarmLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var viewModel: MainViewModel!
    var receivedData: Data?
    let disposeBag = DisposeBag()
    
    func bindViewModel() {
        bindButtons()
        bindProperties()
        bindViewAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setGestures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setGestures() {
        let swipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleScreenEdgeRecognizer(_:)))
        swipeGestureRecognizer.edges = .left
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc private func handleScreenEdgeRecognizer(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        viewModel.requestShowTuneinChannel()
    }
    
    private func setUI() {
        indicatorBackView.type = .circleStrokeSpin
        indicatorBackView.color = .red
        recordButtonIndicatorView.type = .ballScaleMultiple
        recordButtonIndicatorView.color = #colorLiteral(red: 0.0862745098, green: 0.5294117647, blue: 0.5058823529, alpha: 1)
        recordButton.isEnabled = false
        recordButton.setTitle("No one to talk", for: .disabled)
    }
    
    @IBAction func playMessage(_ sender: Any) {
       
    }
    
    private func bindViewAction() {
        viewModel.viewAction
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .recordStarted:
                    self?.playButton.isEnabled = false
                    self?.recordButton.setTitle("Recording..", for: .normal)
                case .recordFinished:
                    self?.indicatorBackView.stopAnimating()
                    self?.recordButton.setTitle("Tap To Record", for: .normal)
                case .showTuneInChannel:
                    self?.showTuneinChannelController()
                case .back:
                    break
                }
            }).disposed(by: disposeBag)
    }
    
    private func showTuneinChannelController() {
        let vc = TuneInChannelViewController.create()
        vc.bindViewModel(to: TuneInChannelViewModel())
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
}

extension MainViewController {
    private func bindButtons() {
        recordButton.rx
            .longPressGesture()
            .when(UIGestureRecognizer.State.began)
            .subscribe({ _ in
                self.recordButtonIndicatorView.stopAnimating()
                self.indicatorBackView.startAnimating()
                self.viewModel.startToRecord()
            })
            .disposed(by: disposeBag)
        
        recordButton.rx
            .longPressGesture()
            .when(UIGestureRecognizer.State.ended)
            .subscribe({ _ in
                self.indicatorBackView.stopAnimating()
                self.viewModel.finishRecord()
            })
            .disposed(by: disposeBag)
        
        viewModel.otherDeviceConnected.asDriver()
            .do(onNext: { [weak self] isEnable in
                if isEnable {
                    self?.recordButtonIndicatorView.startAnimating()
                } else {
                    print("\n** Unable to Connect other devices")
                }
            })
            .drive(self.recordButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // For Test
        viewModel.voiceReceived.asDriver()
            .drive(onNext: { [weak self] voiceReceived in
                if voiceReceived {
                    self?.receivedAlarmLabel.text = "You got a message.\nPress the play button."
                }
            }).disposed(by: disposeBag)
    }
    
    private func bindProperties() {
        viewModel.connectedDeviceNames.asObservable()
            .map {      // map은 타입 변환하기 위해 쓰였음 ([String] -> String)
                $0.reduce("") { results, deviceName in
                    return "\(results), \(deviceName)"
                }
            }
            .map { $0.dropFirst() }
            .map { String($0) }
            .bind(to: connectionLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionAnimator = CoverPartTransitionAnimator(transitionMode: .present)
        return transitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionAnimator = CoverPartTransitionAnimator(transitionMode: .dismiss)
        return transitionAnimator
    }
}
