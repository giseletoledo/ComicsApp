//
//  Comic.swift
//  ComicsApp
//
//  Created by GISELE TOLEDO on 20/07/24.
//

import Foundation

struct Comic: Codable {
    let id: Int
    let title: String
    let isbn: String?
    let thumbnail: Thumbnail?
    
    struct Thumbnail: Codable {
        let path: String
        let `extension`: String
    }
}

class MarvelAPIService {
    private let baseURL = "https://gateway.marvel.com:443/v1/public/comics"
    private let apiKey = "YOUR_API_KEY"
    private let privateKey = "YOUR_PRIVATE_KEY"
    
    func fetchAllComics(completion: @escaping ([Comic]?, Error?) -> Void) {
        let urlString = "\(baseURL)?apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
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
                completion(response.data.results, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}

struct ComicDataWrapper: Codable {
    let data: ComicDataContainer
}

struct ComicDataContainer: Codable {
    let results: [Comic]
}

