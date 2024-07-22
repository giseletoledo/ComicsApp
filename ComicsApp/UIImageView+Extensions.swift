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
    func loadImage(from url: URL, placeholder: UIImage? = nil, completion: @escaping (UIImage?) -> Void) {
           // Set the placeholder image
           self.image = placeholder

           // Create a data task to load the image
           let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
               guard let self = self else { return }

               if let data = data, let image = UIImage(data: data) {
                   // Update the image on the main thread
                   DispatchQueue.main.async {
                       self.image = image
                       completion(image)
                   }
               } else {
                   // Handle image loading error (optional)
                   DispatchQueue.main.async {
                       completion(nil)
                   }
               }
           }

           // Start the data task
           task.resume()
       }
}

