//
//  ComentarioTableViewCell.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 29/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

class ComentarioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var comentarioLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
