//
//  ResponseFilme.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 27/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

class ResponseFilme: Codable {
    
    var page: Int?
    var total_results: Int?
    var total_pages: Int?
    var results: [Filme]?

    enum CodingKeys: String, CodingKey {
        case page
        case total_results
        case total_pages
        case results

    }
    
}
