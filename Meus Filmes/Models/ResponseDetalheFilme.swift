//
//  ResponseDetalheFilme.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 28/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit
class ResponseDetalheFilme: Codable {
    
    var id: Int64?
    var title: String?
    var overview: String?
    var poster_path: String?
    var genres: [Genres]?
    var runtime: Int?

    

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case poster_path
        case genres
        case runtime
    }
    
}
