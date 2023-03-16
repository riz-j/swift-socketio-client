//
//  ContentView.swift
//  playground-2
//
//  Created by Rizki Judojono on 14/3/2023.
//

import SwiftUI
import SocketIO

struct joinRequest {
    var room: String
}

final class Service: ObservableObject {
    public var manager = SocketManager(socketURL: URL(string: "ws://172.104.46.87:8080")!, config: [.log(true), .compress])
        
    @Published var messages = [String]()
    
    init() {
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { (data, ack) in
            print("Connected!")
            socket.emit("my_event", "Hey this is iPhone! Nanana!")
        }
        
        socket.on("my_response") { [weak self] (data, ack) in
            if let data = data[0] as? [String: String],
               let rawMessage = data["response"] {
                DispatchQueue.main.async {
                    self?.messages.append(rawMessage)
                }
            }
        }
        
        
        
        socket.connect()
        
        
    }
}


struct ContentView: View {
    @ObservedObject var service = Service()
    
    var body: some View {
        VStack {
            
            Text("Received")
                .font(.largeTitle)
            ForEach(service.messages, id: \.self) { msg in
                Text(msg).padding()
            }
            
            Button("Join Room") {
                let socket = service.manager.defaultSocket
                socket.emit("join", ["room": "room2"])
            }
            
            Spacer()
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            Text("Hello, world!")
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
