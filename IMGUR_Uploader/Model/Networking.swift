//
//  Networking.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 12.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

func uploadImage(_ image: UIImage) {

    let urlString = "https://api.imgur.com/3/upload"
    let url = URL(string: urlString)
    var request = URLRequest(url: url!)
    guard let imageString = image.toBase64() else { return }
    let parameters = [
      [
        "key": "image",
        "value": imageString,
        "type": "text"
      ]] as [[String : Any]]

    let boundary = "Boundary-\(UUID().uuidString)"
    var body = ""
    for param in parameters {
        if param["disabled"] == nil {
            let paramName = param["key"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            let paramType = param["type"] as! String
            if paramType == "text" {
                let paramValue = param["value"] as! String
                body += "\r\n\r\n\(paramValue)\r\n"
            } else {
                let paramSrc = param["src"] as! String
                guard let fileData = try? NSData(contentsOfFile:paramSrc, options:[]) as Data else { return }
                let fileContent = String(data: fileData, encoding: .utf8)!
                body += "; filename=\"\(paramSrc)\"\r\n" + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
            }
        }
    }
    body += "--\(boundary)--\r\n";
    let postData = body.data(using: .utf8)
    
    request.httpMethod = "POST"
    request.setValue("Client-ID 4c87f4335da16e5", forHTTPHeaderField: "Authorization")
    request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpBody = postData
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            print ("server error")
            return
        }
        if let mimeType = response.mimeType,
            mimeType == "application/json",
            let data = data,
            let dataString = String(data: data, encoding: .utf8) {
            print ("got data: \(dataString)")
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(json)
            }
        }
    }.resume()
}

extension UIImage {
    func toBase64() -> String? {
        return self.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
}
