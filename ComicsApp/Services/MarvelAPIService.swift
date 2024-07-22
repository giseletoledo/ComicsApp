//
//  MarvelAPIService.swift
//  ComicsApp
//
//  Created by GISELE TOLEDO on 20/07/24.
//

import Foundation
import CommonCrypto

class MarvelAPIService {
    private let baseURL = "https://gateway.marvel.com/v1/public/comics"
    private let publicKey = ""
    private let privateKey = ""
    
    private func currentTimestamp() -> String {
        return "\(Int(Date().timeIntervalSince1970))"
    }
    
    private func generateHash(timestamp: String) -> String {
        return md5("\(timestamp)\(privateKey)\(publicKey)")
    }
    
    private func md5(_ string: String) -> String {
        let data = string.data(using: .utf8)!
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_MD5($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    func fetchAllComics(completion: @escaping ([Comic]?, Error?) -> Void) {
        let timestamp = currentTimestamp()
        let hash = generateHash(timestamp: timestamp)
        let urlString = "\(baseURL)?ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)"
        print("URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120 // Aumentar o tempo limite para 120 segundos
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"]))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ComicDataWrapper.self, from: data)
                print("Response Data: \(response)") // Log da resposta para depuração
                completion(response.data.results, nil)
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func fetchComic(byID id: Int, completion: @escaping (Comic?, Error?) -> Void) {
        let timestamp = currentTimestamp()
        let hash = generateHash(timestamp: timestamp)
        let urlString = "\(baseURL)/\(id)?ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)"
        print("URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: 0, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ComicDataWrapper.self, from: data)
                if let comic = response.data.results.first {
                    completion(comic, nil)
                } else {
                    completion(nil, NSError(domain: "No comic found", code: 0, userInfo: nil))
                }
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}
