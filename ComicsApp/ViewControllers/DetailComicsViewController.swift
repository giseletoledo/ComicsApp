//
//  DetailComicsViewController.swift
//  ComicsApp
//
//  Created by GISELE TOLEDO on 20/07/24.
//

import UIKit

class DetailComicsViewController: UIViewController {
    
    var comic: Comic?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        guard let comic = comic else { return }
        
        titleLabel.text = comic.title
        descriptionLabel.text = comic.description ?? "No description available"
        isbnLabel.text = comic.isbn ?? "No ISBN available"
        
        if let thumbnail = comic.thumbnail {
            let urlString = "\(thumbnail.path).\(thumbnail.extension)"
            if let url = URL(string: urlString) {
                thumbnailImageView.load(url: url)
            } else {
                thumbnailImageView.image = UIImage(named: "placeholder")
            }
        } else {
            thumbnailImageView.image = UIImage(named: "placeholder")
        }
        
        updateFavoriteButton()
    }
    
    @IBAction func toggleFavorite(_ sender: UIButton) {
        if isFavorite() {
            removeFavorite()
        } else {
            addFavorite()
        }
        updateFavoriteButton()
    }

    private func updateFavoriteButton() {
        let heartImage = isFavorite() ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favoriteButton.setImage(heartImage, for: .normal)
    }
    
    private func isFavorite() -> Bool {
        guard let comicID = comic?.id else { return false }
        let favorites = UserDefaults.standard.array(forKey: "favoriteComics") as? [Int] ?? []
        return favorites.contains(comicID)
    }
    
    private func addFavorite() {
        guard let comicID = comic?.id else { return }
        var favorites = UserDefaults.standard.array(forKey: "favoriteComics") as? [Int] ?? []
        if !favorites.contains(comicID) {
            favorites.append(comicID)
            UserDefaults.standard.set(favorites, forKey: "favoriteComics")
        }
    }
    
    private func removeFavorite() {
        guard let comicID = comic?.id else { return }
        var favorites = UserDefaults.standard.array(forKey: "favoriteComics") as? [Int] ?? []
        if let index = favorites.firstIndex(of: comicID) {
            favorites.remove(at: index)
            UserDefaults.standard.set(favorites, forKey: "favoriteComics")
        }
    }
}

