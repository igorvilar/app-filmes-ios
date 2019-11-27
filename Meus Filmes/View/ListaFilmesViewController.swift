//
//  ListaFilmesViewController.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 26/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

class ListaFilmesViewController: UIViewController {

    @IBOutlet weak var filmesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ListaFilmesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmeTableViewCell", for: indexPath) as? FilmeTableViewCell
        
        return cell ?? UITableViewCell()
    }
    
    
}
