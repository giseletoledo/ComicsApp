//
//  Comic.swift
//  ComicsApp
//
//  Created by GISELE TOLEDO on 20/07/24.
//

import Foundation

struct ComicDataWrapper: Codable {
    let data: ComicData
}

struct ComicData: Codable {
    let results: [Comic]
}

struct Comic: Codable {
    let id: Int
    let title: String
    let description: String?
    let isbn: String?
    let thumbnail: Thumbnail?
}

struct Thumbnail: Codable {
    let path: String
    let `extension`: String
}

