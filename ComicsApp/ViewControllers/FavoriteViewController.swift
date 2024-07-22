//
//  FavoriteViewController.swift
//  ComicsApp
//
//  Created by GISELE TOLEDO on 21/07/24.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var favoriteComics: [Comic] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        tableView.delegate = self
        tableView.dataSource = self
        fetchFavoriteComics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavoriteComics()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
    }
    
    private func fetchFavoriteComics() {
        activityIndicator.startAnimating() // Start the loading indicator
        
        if let favoriteIDs = UserDefaults.standard.array(forKey: "favoriteComics") as? [Int] {
            print("Favorite comic IDs: \(favoriteIDs)") // Log favorite comic IDs
            
            let dispatchGroup = DispatchGroup()
            var comics: [Comic] = []
            
            for id in favoriteIDs {
                dispatchGroup.enter()
                MarvelAPIService().fetchComic(byID: id) { comic, error in
                    if let comic = comic {
                        print("Fetched comic: \(comic)") // Log the fetched comic details
                        comics.append(comic)
                    } else if let error = error {
                        print("Error fetching comic with ID \(id): \(error.localizedDescription)")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.favoriteComics = comics
                print("Comics loaded: \(self.favoriteComics)") // Log the final list of comics
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating() // Stop the loading indicator
            }
        } else {
            print("No favorite comics found in UserDefaults.")
            activityIndicator.stopAnimating() // Stop the loading indicator if no favorites are found
        }
    }
    
    private func removeFavorite(comic: Comic) {
        let comicID = comic.id
        var favorites = UserDefaults.standard.array(forKey: "favoriteComics") as? [Int] ?? []
        if let index = favorites.firstIndex(of: comicID) {
            favorites.remove(at: index)
            UserDefaults.standard.set(favorites, forKey: "favoriteComics")
            fetchFavoriteComics() // Reload comics after removal
        }
    }
    
    @objc private func removeFavoriteAction(_ sender: UIButton) {
        let comicID = sender.tag
        if let index = favoriteComics.firstIndex(where: { $0.id == comicID }) {
            let comic = favoriteComics[index]
            removeFavorite(comic: comic)
            favoriteComics.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Ajuste a altura conforme necessário
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteComics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "favoritecell", for: indexPath) as? FavoriteTableViewCell else {
            return UITableViewCell()
        }
        
        let comic = favoriteComics[indexPath.row]
        
        // Configura o conteúdo da célula
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = comic.title
        contentConfig.secondaryText = (comic.description?.isEmpty ?? true) ? "No description available" : comic.description
        
        // Define o URL padrão para imagem não disponível
        let placeholderURL = URL(string: "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg")!
        
        // Função para atualizar a célula com a imagem
        func updateCell(with image: UIImage?) {
            var updatedContentConfig = cell.defaultContentConfiguration()
            updatedContentConfig.text = comic.title
            updatedContentConfig.secondaryText = (comic.description?.isEmpty ?? true) ? "No description available" : comic.description
            updatedContentConfig.image = image ?? UIImage(named: "placeholderImage")
            updatedContentConfig.imageProperties.maximumSize = CGSize(width: 55, height: 75)
            updatedContentConfig.imageProperties.reservedLayoutSize = CGSize(width: 55, height: 75)
            cell.contentConfiguration = updatedContentConfig
        }
        
        // Definir a URL da imagem e carregar
        if let thumbnail = comic.thumbnail {
            let urlString = "\(thumbnail.path).\(thumbnail.extension)"
            let url = URL(string: urlString) ?? placeholderURL
            
            let imageView = UIImageView()

            imageView.loadImage(from: url) { image in
                DispatchQueue.main.async {
                    updateCell(with: image)
                }
            }
        } else {
            // Imagem padrão se não houver thumbnail
            updateCell(with: UIImage(named: "placeholderImage"))
        }
        
        // Configura o botão de remover como accessory view
        let removeButton = UIButton(type: .custom)
        removeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        removeButton.tag = comic.id
        removeButton.addTarget(self, action: #selector(removeFavoriteAction(_:)), for: .touchUpInside)
        removeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        cell.accessoryView = removeButton

        return cell
    }
}

