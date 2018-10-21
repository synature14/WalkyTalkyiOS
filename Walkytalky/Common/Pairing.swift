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

protocol PairingDelegate {
    func connectedDevicesChanged(manager: Pairing, connectedDevices: [String])
    func isAbleToConnect(bool: Bool)
    func playRecord(manager: Pairing, audioData: Data)
}


class Pairing: NSObject, StreamDelegate {
    private let WalkyTalkyServiceType = "walky-talky"
    
    var delegate: PairingDelegate?
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    var outputStream: OutputStream?
    
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
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        // OutputStream 초기화
        outputStream?.schedule(in: RunLoop.main, forMode: .default)
        outputStream?.delegate = self
        outputStream?.open()
    }
    
    public func startCaptureOutput() {
//        captureSession.startRunning()
    }
    
    public func endCaptureOutput() {
//        captureSession.stopRunning()
    }
    
//    private func sendAvailableBytes(sampleBuffer: CMSampleBuffer) {
//
//        if session.connectedPeers.count > 0 {
//            CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
//                sampleBuffer,
//                bufferListSizeNeededOut: nil,
//                bufferListOut: &audioBufferList,
//                bufferListSize: MemoryLayout<AudioBufferList>.size,
//                blockBufferAllocator: nil,
//                blockBufferMemoryAllocator: nil,
//                flags: 0,
//                blockBufferOut: &blockBuffer)
//
//            let buffers = UnsafeBufferPointer<AudioBuffer>(
//                start: &audioBufferList.mBuffers,
//                count: Int(audioBufferList.mNumberBuffers))
//
//            for buffer in buffers {
//                guard let framedBuffer = buffer.mData?.assumingMemoryBound(to: UInt8.self) else {
//                    print("buffer nil")
//                    return
//                }
//                do {
//                    try session.send(Data(bytes: framedBuffer, count: Int(buffer.mDataByteSize)), toPeers: session.connectedPeers, with: .reliable)
//                } catch {
//                    print("Fail to send")
//                }
//            }
//            self.delegate?.isAbleToConnect(bool: true)
//        }
//    }

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
        print("Found peer! : \(peerID)")
        print("invitePeer: \(peerID)")
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
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("\n- didReceiveData")
        self.delegate?.playRecord(manager: self, audioData: data)
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
