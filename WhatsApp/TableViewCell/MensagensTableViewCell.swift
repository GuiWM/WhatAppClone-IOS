//
//  MensagensTableViewCell.swift
//  WhatsApp
//
//  Created by Guilherme Magnabosco on 02/04/20.
//  Copyright © 2020 Guilherme Magnabosco. All rights reserved.
//

import UIKit

class MensagensTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var ImagemDireita: UIImageView!
    @IBOutlet weak var imagemEsquerda: UIImageView!
    @IBOutlet weak var mensagemDireitaLabel: UILabel!
    @IBOutlet weak var mensagemEsquerdaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
