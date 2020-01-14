//
//  Networking.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 12.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit
import Photos

enum Result<T> {
    case success(T)
    case error(String)
}

enum OperationState : Int {
    case ready
    case executing
    case finished
}

/*  class for creating a proper operation for url request
    helps managing concurrent requests
    thanks to it we can proceed requests one by one */
class DownloadOperation : Operation {
    private var task : URLSessionDataTask!
    private var state : OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
    
    init(session: URLSession, dataTaskURLRequest: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        super.init()
        task = session.dataTask(with: dataTaskURLRequest, completionHandler: { [weak self] (data, response, error) in
            if let completionHandler = completionHandler {
                completionHandler(data, response, error)
            }
            self?.state = .finished
        })
    }

    override func start() {
        if self.isCancelled {
            state = .finished
            return
        }
        state = .executing
        self.task.resume()
    }

    override func cancel() {
        super.cancel()
        self.task.cancel()
    }
}

class ImageUploader {
    private let queue = OperationQueue()
    private let urlString = "https://api.imgur.com/3/upload"
    private let clientID = "4c87f4335da16e5"
    
    init() {
        queue.maxConcurrentOperationCount = 1
    }

    public func uploadImage(_ image: UIImage, completion: @escaping (Result<String>) -> ()) {
        // formatting image to base64 string so we can pass it with the request
        guard let imageString = image.toBase64() else { return completion(.error("Error transforming image")) }

        guard let request = formRequest(imageString: imageString) else { return completion(.error("Error forming request")) }
        // creating operation for the queue
        let operation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: request) { (data, response, error) in
            DispatchQueue.main.async {
                // error check
                if let error = error {
                    return completion(.error(error.localizedDescription))
                }
                // response code check
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    return completion(.error("Server error"))
                }
                // serializing JSON and checking return data type
                guard let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
                    let result = json["data"] as? NSDictionary,
                    let link = result["link"] as? String else { return completion(.error("Error getting data from the response")) }
                completion(.success(link))
            }
        }
        queue.addOperation(operation)
    }
    
    // checking url, formatting body according to the requirements of the API
    private func formRequest(imageString: String) -> URLRequest? {
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        guard let postData = formBody(with: imageString, boundary) else { return nil }
        
        request.httpMethod = "POST"
        request.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        return request
    }
    
    private func formBody(with imageString: String, _ boundary: String) -> Data? {
        let parameters = [["key": "image", "value": imageString, "type": "text"]] as [[String : Any]]
        var body = ""
        for param in parameters {
            let paramName = param["key"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            let paramType = param["type"] as! String
            if paramType == "text" {
                let paramValue = param["value"] as! String
                body += "\r\n\r\n\(paramValue)\r\n"
            } else {
                let paramSrc = param["src"] as! String
                guard let fileData = try? NSData(contentsOfFile:paramSrc, options:[]) as Data else { return nil }
                let fileContent = String(data: fileData, encoding: .utf8)!
                body += "; filename=\"\(paramSrc)\"\r\n" + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)
        
        return postData
    }
}
