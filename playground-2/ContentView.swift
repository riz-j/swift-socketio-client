//
//  ContentView.swift
//  playground-2
//
//  Created by Rizki Judojono on 14/3/2023.
//

import SwiftUI
import SocketIO

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
    private var socket: SocketIOClient { return service.manager.defaultSocket }
    private var roomName: String = "room2"
    @State private var messageInput: String = ""
    
    var body: some View {
        VStack {
            
            Text("Received")
                .font(.largeTitle)
            List {
                ForEach(service.messages, id: \.self) { msg in
                    Text(msg).padding()
                }
            }
            
            Button("Join Room") {
                socket.emit("join", ["room": roomName])
            }
            
            HStack {
                TextField("Send Message", text: $messageInput)
                
                Button("Send ") {
                    socket.emit("room_event", ["data": messageInput, "room": roomName])
                }
            }
            .padding()
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
