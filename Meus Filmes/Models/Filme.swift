//
//  Filme.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 27/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

class Filme: Codable {
    
    var popularity: Float64?
    var vote_count: Int64?
    var video: Bool?
    var poster_path: String?
    var id: Int64?
    var adult: Bool?
    var backdrop_path: String?
    var original_language: String?
    var original_title: String?
    var genre_ids: [Int]
    var title: String
    var vote_average: Float
    var overview: String
    var release_date: String
    
    enum CodingKeys: String, CodingKey {
        case popularity
        case vote_count
        case video
        case poster_path
        case id
        case adult
        case backdrop_path
        case original_language
        case original_title
        case genre_ids
        case title
        case vote_average
        case overview
        case release_date
    }
    
}
