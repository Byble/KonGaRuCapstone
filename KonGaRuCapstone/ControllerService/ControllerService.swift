import Cocoa
import MultipeerConnectivity

protocol ControllerServiceDelegate {
    func connectedDevicesChanged(manager : ControllerService, connectedDevices : [String])
    func buttonChanged(manager : ControllerService, changedBtn: String)
}

class ControllerService: NSObject {
    private let ControllerServiceType = "Controller"
    
    private let myPeerID = MCPeerID(displayName: Host.current().localizedName!)
    
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    var delegate : ControllerServiceDelegate?
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: ControllerServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: ControllerServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    func send(buttonName : String){
        if session.connectedPeers.count > 0{
            do {
                try self.session.send(buttonName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
}

extension ControllerService: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 5)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        NSLog("%@", "lostPeer : \(peerID)")
    }
}

extension ControllerService: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
//        NSLog("%@", "didNotStartAdvertisingPeer : \(error)")
    }
    
}

extension ControllerService: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:
            self.delegate?.connectedDevicesChanged(manager: self, connectedDevices: ["연결중..."])
        case .connected:
            self.delegate?.connectedDevicesChanged(manager: self, connectedDevices: session.connectedPeers.map{$0.displayName})
            self.serviceAdvertiser.stopAdvertisingPeer()
            self.serviceBrowser.stopBrowsingForPeers()
        case .notConnected:
            self.delegate?.connectedDevicesChanged(manager: self, connectedDevices: ["다시 연결해주세요..."])
            self.serviceAdvertiser.startAdvertisingPeer()
            self.serviceBrowser.startBrowsingForPeers()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.buttonChanged(manager: self, changedBtn: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
//        NSLog("%@", "didFinishReceivingResourceWithNAme")
    }
    
    
}
