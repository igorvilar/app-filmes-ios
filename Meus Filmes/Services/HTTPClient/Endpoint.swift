//
//  Endpoint.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 27/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

func EndpointApi(_ keyPath: String) -> URL {
    return URL(string: "http://api.themoviedb.org/3" + keyPath)!
}

func EndPointImagem(_ keyPath: String) -> URL {
    return URL(string: "http://image.tmdb.org/t/p/w185/" + keyPath)!
}
