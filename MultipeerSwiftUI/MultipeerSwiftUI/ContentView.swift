//
//  ContentView.swift
//  MultipeerSwiftUI
//
//  Created by Barbara Argolo on 07/10/23.
//

import SwiftUI

struct ContentView: View {
    @State private var buttonStateImg = false
    @ObservedObject var connectionManager: ConnManager
    
    init(buttonStateImg: Bool = false, connectionManager: ConnManager) {
        self.buttonStateImg = buttonStateImg
        self.connectionManager = connectionManager
    }
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            VStack {
                Button {
                    buttonStateImg.toggle()
                    connectionManager.sendDataButton(buttonState: buttonStateImg)
                } label: {
                    Image(buttonStateImg ? "darkblue" : "blue")
                }.padding(.top, 130)
                Text("Clique no botão abaixo para notificar outros dispositivos")
                    .foregroundStyle(.white)
                    .font(.title3)
                    .padding(.top, 80)
                Button {
                    //inserir a função para notificar os aparelhos
                    connectionManager.advertise()
                } label: {
                    Image("Notificar")
                        .resizable()
                        .frame(width: 198,height: 65)
                }.font(.largeTitle)
                Text("Clique no botão abaixo para conectar com outros dispostivos")
                    .foregroundStyle(.white)
                    .font(.title3)
                    .padding(.top, 30)
                Button {
                    //inserir a função para conectar os aparelhos
                    connectionManager.invite()
                } label: {
                    Image("Conectar").resizable()
                        .resizable()
                        .frame(width: 198,height: 65)
                }
            }
            .padding()
        }.onReceive(connectionManager.$buttonStateManager, perform: { newButtonState in
            if let receivedButtonStateValue = newButtonState.first {
                buttonStateImg = receivedButtonStateValue
            }
        })
    }
}

