//
//  Genres.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 28/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

class Genres: Codable {
    var id: Int?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }

}
