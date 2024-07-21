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
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        setupActivityIndicator()
        fetchComics()
    }
}

extension ViewController: UITableViewDelegate {
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
        cell.textLabel?.text = comic.title
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        
        if let thumbnail = comic.thumbnail {
            let urlString = "\(thumbnail.path).\(thumbnail.extension)"
            if let url = URL(string: urlString) {
                cell.imageView?.load(url: url)
            }
        }
        
        print("Configured cell for row \(indexPath.row)")
        return cell
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
