//
//  ListaFilmesViewController.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 26/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit
import Imaginary

class ListaFilmesViewController: UIViewController {

    @IBOutlet weak var filmesTableView: UITableView!
    @IBOutlet weak var loadActivityIndicator:
    
    UIActivityIndicatorView!
    
    var filmes: [Filme] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "filmesToDetalhesSegue" {
            if let destino = segue.destination as? DetalheFilmeViewController {
                let indexPath = sender as! IndexPath
                destino.filme = filmes[indexPath.row]
            }
        }
    }
    
    func setup() {
        self.navigationController?.navigationBar.barTintColor = UIColor.black

        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        loadActivityIndicator.startLoad(start: true)
        FilmesRepository
            .listarFilmes()
            .onComplete { [weak self] (response) in
                if let object = response.object {
                    if let result: [Filme] = object.results {
                        DispatchQueue.main.async {
                            self?.filmes = result
                            self?.filmesTableView.reloadData()
                        }
                    }
                }
                self?.loadActivityIndicator.startLoad(start: false)
        }.catchError { [weak self] (response) in
            self?.loadActivityIndicator.startLoad(start: false)
            self?.simpleAlert(title: "Alerta", message: response.error?.localizedDescription ?? "erro ao conectar", dismiss: false)
        }
    }

}

extension ListaFilmesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filmes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmeTableViewCell", for: indexPath) as? FilmeTableViewCell
        cell?.tituloFilmeLabel.text = filmes[indexPath.row].title
        if let imagePath: String = filmes[indexPath.row].poster_path {
            let placeholder = UIImage(named: "imageplaceholder")
            let imageUrl = EndPointImagem(imagePath)
            cell?.imageFilmeImageView.setImage(url: imageUrl, placeholder: placeholder)
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "filmesToDetalhesSegue", sender: indexPath)
    }
}
