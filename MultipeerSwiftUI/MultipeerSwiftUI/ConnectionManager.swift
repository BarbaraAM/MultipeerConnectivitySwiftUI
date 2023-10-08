//
//  ConnectionManager.swift
//  MultipeerSwiftUI
//
//  Created by Barbara Argolo on 07/10/23.
//

import MultipeerConnectivity

class ConnManager: NSObject, ObservableObject {
    //atualizar de forma automática na view
    @Published var buttonStateManager: [Bool] = []
    
    //MARK: 1 - Primeiras Configurações
    //nome do dispositivo como identificador
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    //notificadora
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    
    var advertiserAssistantObject: MCAdvertiserAssistant?
    
    //navegador de serviço
    var serviceBrowser: MCNearbyServiceBrowser
    //para comunicação do pares
    lazy var session: MCSession = {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    //identificador de serviço para comunicação
    let serviceTypeNSA = "uniqServType"
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    //inicializa as classes
    override init() {
        self.nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceTypeNSA)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceTypeNSA)
        super .init()
        self.nearbyServiceAdvertiser?.delegate = self
        self.nearbyServiceAdvertiser?.startAdvertisingPeer()
    }
    
    
    //MARK: 2 - Funções
    
    //função para notificar disponibilidade aos dispositivos em volta
    func advertise() {
        advertiserAssistantObject = MCAdvertiserAssistant(serviceType: serviceTypeNSA, discoveryInfo: nil, session: session)
        advertiserAssistantObject?.start()
    }
    //função para convidar dispositivos
    func invite() {
        let browser = MCBrowserViewController(serviceType: serviceTypeNSA, session: session)
        browser.delegate = self
        rootViewController?.present(browser, animated: true)
    }
    
    //envio de dados
    func sendDataButton(buttonState: Bool) {
        if session.connectedPeers.isEmpty {
            print("Sem dispositivos conectados")
            return
        }
        
        buttonStateManager = [buttonState]
        print("estado do botão: \(buttonStateManager)")
        
        do {
            //encodando o dado
            let data = try JSONEncoder().encode(buttonStateManager)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch let error {
            print("Erro ao enviar dado do estado do botão, \(error.localizedDescription)")
        }
    }
}


//MARK: 3 - Protocolos
//lidando com eventos da conexão peer-to-peer
extension ConnManager: MCSessionDelegate {
    
    //chamado quando o estado de um par muda
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state {
        case .connecting:
            print("\(peerID) estado: conectando")
        case .connected:
            print("\(peerID) estado: conectado")
        case .notConnected:
            print("\(peerID) estado: não conectado")
        @unknown default:
            print("\(peerID) estado: não disponível")
        }
    }
    
    
    //chamado quando dados são recebidos de um outro par
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //decodificar
        do {
            let receivedButtonState = try JSONDecoder().decode([Bool].self, from: data)
            buttonStateManager = receivedButtonState
            print("O estado do botão recebido é: \(buttonStateManager)")
        } catch {
            print("Erro ao decodificar os dados recebidos: \(error.localizedDescription)")
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}


extension ConnManager: MCNearbyServiceAdvertiserDelegate {
    //chamado quando o dispositivo recebe um convite de um par
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
extension ConnManager: MCBrowserViewControllerDelegate {
    //chamado quando o usuário termina de usar o navegador de serviço
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    //chamado quando o usuário cancela o navegador de serviço
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}




