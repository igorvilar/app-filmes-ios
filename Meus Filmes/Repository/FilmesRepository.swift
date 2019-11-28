//
//  FilmesRepository.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 27/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

struct FilmesRepository{
    
    static let apiKey = "083a68c27ce0872e96bd304ee76e827a"
    
    static func listarFilmes() -> Response<ResponseFilme> {
        let url = EndpointApi("/movie/popular")
        return Response<ResponseFilme>(url)
        .setQueryParams(["api_key": "\(apiKey)"]).get()

    }
}
