//
//  UIImageView+Extensions.swift
//  ComicsApp
//
//  Created by GISELE TOLEDO on 20/07/24.
//

import UIKit

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
    
    // Nova função para carregar imagem assincronamente com URLSession
    func loadImage(from url: URL, completion: ((UIImage?) -> Void)? = nil) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        completion?(nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.image = image
                    completion?(image)
                }
            }
            task.resume()
        }
}

