//
//  DetalheFilmeTableViewCell.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 28/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

class DetalheFilmeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var nomeFilmeLabel: UILabel!
    @IBOutlet weak var duracaoLabel: UILabel!
    @IBOutlet weak var generoLabel: UILabel!
    @IBOutlet weak var sinopseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
