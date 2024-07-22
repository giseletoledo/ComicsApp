//
//  ViewController.swift
//  ComicsApp
//
//  Created by GISELE TOLEDO on 20/07/24.
//

import UIKit

class ViewController: UIViewController {
    
    private var service: MarvelAPIService = MarvelAPIService()
    private var comics: [Comic] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    @IBOutlet weak var tableView: UITableView!
    
    private func fetchComics() {
            activityIndicator.startAnimating()
            print("Fetching comics...")
            service.fetchAllComics { comics, error in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if let error = error {
                        print("Fetch Error: \(error.localizedDescription)")
                        return
                    }

                    guard let comics = comics else {
                        print("No comics returned")
                        return
                    }

                    print("Comics fetched: \(comics.count)")
                    self.comics = comics
                    self.tableView.reloadData()
                }
            }
        }
    
    private func setupActivityIndicator() {
            activityIndicator.center = view.center
            view.addSubview(activityIndicator)
            activityIndicator.hidesWhenStopped = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        setupActivityIndicator()
        fetchComics()
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Ajuste a altura da cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toDetails", sender: indexPath)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comics.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") else {
            print("Failed to dequeue cell")
            return UITableViewCell()
        }
        
        let comic = comics[indexPath.row]
        
        // Configura o conteúdo da célula
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = comic.title
        contentConfig.secondaryText = comic.description

        // Define o URL padrão para imagem não disponível
        let placeholderURL = "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg"
        
        if let thumbnail = comic.thumbnail {
            let urlString = "\(thumbnail.path).\(thumbnail.extension)"
            let url = URL(string: urlString) ?? URL(string: placeholderURL)!
            loadImage(from: url) { image in
                DispatchQueue.main.async {
                    var updatedContentConfig = cell.defaultContentConfiguration()
                    updatedContentConfig.text = comic.title
                    updatedContentConfig.secondaryText = comic.description
                    updatedContentConfig.image = image ?? UIImage(named: "placeholderImage")
                    updatedContentConfig.imageProperties.maximumSize = CGSize(width: 55, height: 75)
                    updatedContentConfig.imageProperties.reservedLayoutSize = CGSize(width: 55, height: 75)
                    cell.contentConfiguration = updatedContentConfig
                }
            }
        } else {
            contentConfig.image = UIImage(named: "placeholderImage")
            contentConfig.imageProperties.maximumSize = CGSize(width: 55, height: 75)
            contentConfig.imageProperties.reservedLayoutSize = CGSize(width: 55, height: 75)
            cell.contentConfiguration = contentConfig
        }

        print("Configured cell for row \(indexPath.row)")
        return cell
    }

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }

}

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails" {
            if let indexPath = sender as? IndexPath {
                let selectedComic = comics[indexPath.row]
                if let detailVC = segue.destination as? DetailComicsViewController {
                    detailVC.comic = selectedComic
                }
            }
        }
    }
}
