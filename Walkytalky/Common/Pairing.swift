//
//  Pairing.swift
//  Walkytalky
//
//  Created by sutie on 08/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import AVFoundation
import MultipeerConnectivity
import RxSwift
import RxCocoa

protocol PairingDelegate {
    func connectedDevicesChanged(manager: Pairing, connectedDevices: [String])
    func isAbleToConnect(bool: Bool)
}


class Pairing: NSObject, StreamDelegate {
    private let WalkyTalkyServiceType = "walky-talky"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    let dataToTransfer = PublishSubject<Data>()
    let receivedData = PublishSubject<Data>()
    
    let disposeBag = DisposeBag()
    
    var outputStream: OutputStream?
    var delegate: PairingDelegate?
    
    // To create a MCSession on demand
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()

    override init() {
        // MCService 초기화
        serviceAdvertiser = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: nil,
            serviceType: WalkyTalkyServiceType)
        serviceBrowser = MCNearbyServiceBrowser(
            peer: myPeerId,
            serviceType: WalkyTalkyServiceType)
        super.init()
        setupMCService()
        setupOutstream()
        bindDataToTransfer()
    }
    
    private func sendReceivedDataToConnectedDevices(_ data: Data) {
        guard session.connectedPeers.count > 0 else {
            return
        }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        outputStream?.close()
    }
}

extension Pairing: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("did Receive InvitationFromPeer  \(peerID)")
        invitationHandler(true, self.session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("did Not Start AdvertisingPeer.. error : \(error)")
    }
}

extension Pairing: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("did Not Start BrowsingForPeers : \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer and invite peer : \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        self.delegate?.isAbleToConnect(bool: true)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("*** Lost peer.. : \(peerID)")
        self.delegate?.isAbleToConnect(bool: false)
    }
}

extension Pairing: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("** peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    // 다른 디바이스에서 데이터를 전송받은 경우 아래 호출 됨
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receivedData.onNext(data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("- didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("- didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("- didFinishReceivingResourceWithName")
    }
}

extension Pairing {
    private func bindDataToTransfer() {
        dataToTransfer.asObservable()
            .subscribe(onNext: { [weak self] receivedData in
                self?.sendReceivedDataToConnectedDevices(receivedData)
            }).disposed(by: disposeBag)
    }
}

extension Pairing {
    private func setupOutstream() {
        outputStream?.schedule(in: RunLoop.main, forMode: .default)
        outputStream?.delegate = self
        outputStream?.open()
    }
    
    private func setupMCService() {
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
}
