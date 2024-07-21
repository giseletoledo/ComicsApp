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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        service.fetchAllComics { comics, error in
            guard let comics = comics else { return }
            self.comics = comics
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toDetails", sender: indexPath)
    }
}

extension ComicsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") else { return UITableViewCell() }
            
        let comic = comics[indexPath.row]
        cell.textLabel?.text = comic.title
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        if let thumbnail = comic.thumbnail {
            let urlString = "\(thumbnail.path).\(thumbnail.extension)"
            if let url = URL(string: urlString) {
                cell.imageView?.load(url: url)
            }
        }
        
        return cell
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


