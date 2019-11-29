//
//  DetalheFilmeViewController.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 28/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

class DetalheFilmeViewController: UIViewController {
    
    var filme: Filme?
    var filmeDetalhe: ResponseDetalheFilme?
    
    @IBOutlet weak var detalheFilmeTableView: UITableView!
    @IBOutlet weak var loadActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setup()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setup() {
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        if let idFilme: Int64 = filme?.id {
            loadActivityIndicator.startLoad(start: true)
            FilmesRepository
                .detalharFilme(idFilme: idFilme)
                .onComplete { [weak self] (response) in
                    if let object = response.object {
                        DispatchQueue.main.async {
                            self?.filmeDetalhe = object
                            self?.detalheFilmeTableView.reloadData()
                        }
                    }
                    self?.loadActivityIndicator.startLoad(start: false)
            }.catchError { [weak self] (response) in
                self?.loadActivityIndicator.startLoad(start: false)
                self?.simpleAlert(title: "Alerta", message: response.error?.localizedDescription ?? "erro ao conectar", dismiss: false)
            }
        }
        
    }

}

extension DetalheFilmeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetalheFilmeTableViewCell", for: indexPath) as? DetalheFilmeTableViewCell
            cell?.nomeFilmeLabel.text = filmeDetalhe?.title
            if let duracao: Int = filmeDetalhe?.runtime {
                cell?.duracaoLabel.text = "Duração: \(duracao) min"
            }
            if let generos: [Genres] = filmeDetalhe?.genres {
                if generos.count > 0 {
                    var genero = "Gêneros: "
                    for item in generos {
                        genero = "\(genero)\(item.name ?? "") - "
                    }
                    cell?.generoLabel.text = genero
                }
            }
            
            cell?.sinopseLabel.text = "Sinopse: \(filmeDetalhe?.overview ?? "")"
            if let imagePath: String = filmeDetalhe?.poster_path {
               let placeholder = UIImage(named: "imageplaceholder")
               let imageUrl = EndPointImagem(imagePath)
               cell?.posterImageView.setImage(url: imageUrl, placeholder: placeholder)
            }
            return cell ?? UITableViewCell()
        case 1:
             let cell = tableView.dequeueReusableCell(withIdentifier: "TituloComentarioTableViewCell", for: indexPath) as? TituloComentarioTableViewCell
             return cell ?? UITableViewCell()
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComentarioTableViewCell", for: indexPath) as? ComentarioTableViewCell
            cell?.comentarioLabel.text = "sem comentários"
            cell?.comentarioLabel.textAlignment = .center
            return cell ?? UITableViewCell()
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BotaoComentarioTableViewCell", for: indexPath) as? BotaoComentarioTableViewCell
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    
}
