//
//  FilmeTableViewCell.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 26/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

class FilmeTableViewCell: UITableViewCell {

    @IBOutlet weak var tituloFilmeLabel: UILabel!
    @IBOutlet weak var imageFilmeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
