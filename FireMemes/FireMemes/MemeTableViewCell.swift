//
//  MemeTableViewCell.swift
//  FireMemes
//
//  Created by Jose Melendez on 6/7/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {
    
    //MARK: - Outlets and Actions
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    //each cell will have a meme,

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //actions for each button here
    
    
}

//MARK: - UpdateViews Method

extension MemeTableViewCell {
    
    func updateViews(meme: Meme) {
        memeImageView.image = meme.image
    }
}
