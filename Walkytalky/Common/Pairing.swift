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
    
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    // To create a MCSession on demand
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        Stream.getStreamsToHost(withName: "record", port: 1,
                                inputStream: &inputStream, outputStream: &outputStream)
        session.delegate = self
        return session
    }()
    
    let captureSession = AVCaptureSession()
    let settings = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey : 1,
        AVSampleRateKey : 44100
    ]
    let queue = DispatchQueue(label: "AudioSessionQueue", attributes: [])
    let captureDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    var audioInput: AVCaptureDeviceInput?
    var audioOutput: AVCaptureAudioDataOutput?
    
    var audioBufferList = AudioBufferList()
    var blockBuffer: CMBlockBuffer?

    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: WalkyTalkyServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: WalkyTalkyServiceType)
       
        super.init()

        do {
            try captureDevice?.lockForConfiguration()
            audioInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureDevice?.unlockForConfiguration()
            audioOutput = AVCaptureAudioDataOutput()
            audioOutput?.setSampleBufferDelegate(self, queue: queue)
//            audioOutput?.audioSettings = settings
        } catch {
            print("Capture devices could not be set")
            print(error.localizedDescription)
        }
        
        guard let audioInput = audioInput, let audioOutput = audioOutput else { return }
       
        captureSession.beginConfiguration()
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        } else {
            print("** cannot add input")
        }
        
        if captureSession.canAddOutput(audioOutput) {
            captureSession.addOutput(audioOutput)
        } else {
            print("** cannot add output")
        }
        captureSession.commitConfiguration()
        
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        
        inputStream?.schedule(in: RunLoop.main, forMode: .default)
        inputStream?.delegate = self
        inputStream?.open()

        outputStream?.schedule(in: RunLoop.main, forMode: .default)
        outputStream?.delegate = self
    }
    
    public func startCaptureOutput() {
        captureSession.startRunning()
    }
    
    public func endCaptureOutput() {
        captureSession.stopRunning()
    }
    
    /* Sender & Receiver side */
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("**** New data has arrived")
            receiveAvailableBytes()
        case .hasSpaceAvailable:
            print("*** The stream can accept bytes for writing")
        default:
            break
        }
    }
    
    private func receiveAvailableBytes() {
        var buffer = [UInt8](repeating: 0, count: 4096)
        if let inputStream = inputStream {
            let numberOfBytesRead = inputStream.read(&buffer, maxLength: buffer.count)
            if numberOfBytesRead < 0 {
                print("\n*** Read Bytes Error... -->\(inputStream.streamError)\n")
            } else {
                let receivedData = Data(bytes: buffer, count: buffer.count)      // flatMap의 용도 : map 적용한뒤 nil값들을 삭제
                self.delegate?.playRecord(manager: self, audioData: receivedData)
            }
        }
    }
    
    private func sendAvailableBytes(sampleBuffer: CMSampleBuffer) {
        if session.connectedPeers.count > 0 {
            CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
                sampleBuffer,
                bufferListSizeNeededOut: nil,
                bufferListOut: &audioBufferList,
                bufferListSize: MemoryLayout<AudioBufferList>.size,
                blockBufferAllocator: nil,
                blockBufferMemoryAllocator: nil,
                flags: 0,
                blockBufferOut: &blockBuffer)
            
            let buffers = UnsafeBufferPointer<AudioBuffer>(
                start: &audioBufferList.mBuffers,
                count: Int(audioBufferList.mNumberBuffers))
            
            if let outputStream = outputStream {
                for buffer in buffers {
                    guard let framedBuffer = buffer.mData?.assumingMemoryBound(to: UInt8.self) else { return }
                    outputStream.write(framedBuffer, maxLength: Int(buffer.mDataByteSize))
//                    data.append(frame!, count: Int(buffer.mDataByteSize))
                }
            }
            self.delegate?.isAbleToConnect(bool: true)
        }
    }

    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        inputStream?.close()
        outputStream?.close()
    }
}


extension Pairing: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("** Audio data RECEIVED..!!")
        sendAvailableBytes(sampleBuffer: sampleBuffer)
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
        print("- didReceiveData")
        self.delegate?.playRecord(manager: self, audioData: data)
    }
    
    /* Receiver side */
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("- didReceiveStream")
        stream.delegate = self
        stream.schedule(in: RunLoop.main, forMode: .default)        // Stream should be executed in "asynchronous"
        stream.open()
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("- didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("- didFinishReceivingResourceWithName")
    }
}
