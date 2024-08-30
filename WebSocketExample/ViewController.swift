//
//  ViewController.swift
//  WebSocketExample
//
//  Created by Egemen TÜRK on 30.08.2024.
//

import UIKit

class ViewController: UIViewController {
    
    private let closeButton: UIButton = {
       let button = UIButton()
        button.setTitle("Close Connection", for: .normal)
        button.setTitleColor(.magenta, for: .normal)
        return button
    }()
    
    private var webSocket: URLSessionWebSocketTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .darkGray
        addCloseButton()
        configureWebSocket()
    }
}

// MARK: - UILayout
private extension ViewController {
    
    func addCloseButton() {
        closeButton.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        view.addSubview(closeButton)
        closeButton.center = view.center
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc
    private func closeButtonTapped() {
        close()
    }
}

// MARK: - WebSocket
extension ViewController: URLSessionWebSocketDelegate {
    private func configureWebSocket() {
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue())
        let url = URL(string: "wss://echo.websocket.org")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
    }
    
    func ping(){
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error {
                print("Ping error: \(error)")
            }
        })
    }
    
    func close(){
        webSocket?.cancel(with: .goingAway, reason: "ThEnd".data(using: .utf8))
    }
    
    func send(){
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.send()
            self.webSocket?.send(.string("Test send Function"), completionHandler: { error in
                if let error {
                    print("Send error \(error)")
                }
            })
        }
    }
    
    func receive(){
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Data: \(data)")
                case .string(let message):
                    print("String: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Recive Error: \(error)")
            }
            self?.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason: \(reason)")
    }
}
