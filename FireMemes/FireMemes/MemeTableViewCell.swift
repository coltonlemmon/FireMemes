//
//  MemeTableViewCell.swift
//  FireMemes
//
//  Created by Jose Melendez on 6/7/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit
import Social

class MemeTableViewCell: UITableViewCell {
    
    //MARK: - Outlets and Actions
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    @IBOutlet weak var numberOfComments: UILabel!
    
    @IBOutlet weak var numberOfUpvotes: UILabel!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    
    
    //each cell will have a meme,

    //Delegates
    var delegate: MemeTableViewCellDelegate?
    
    
    //actions for each button here

    @IBAction func facebookButtonTapped(_ sender: Any) {
        
        delegate?.facebookClicked(self, image: memeImageView.image!)
    
    }
    @IBAction func twitterButtonTapped(_ sender: Any) {
        
        delegate?.twitterClicked(self, image: memeImageView.image!)
    
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        
        delegate?.messageClicked(self, image: memeImageView.image!)

    }
    @IBAction func commentButtonTapped(_ sender: Any) {
        
    }
    @IBAction func upvoteButtonTapped(_ sender: Any) {
        
    }
    
}

//MARK: - UpdateViews Method

extension MemeTableViewCell {
    
    func updateViews(meme: Meme) {
        memeImageView.image = meme.image
        
        facebookButton.layer.cornerRadius = 15
        twitterButton.layer.cornerRadius = 15
        
        facebookButton.layer.borderColor = UIColor.black.cgColor
        twitterButton.layer.borderColor = UIColor.black.cgColor
        
        facebookButton.layer.borderWidth = 0.5
        twitterButton.layer.borderWidth = 0.5
        
    }
}

//Protocols
protocol MemeTableViewCellDelegate: class{
    
    func facebookClicked(_ sender: MemeTableViewCell, image: UIImage)
    
    func twitterClicked(_ sender: MemeTableViewCell, image: UIImage)
    
    func messageClicked(_ sender: MemeTableViewCell, image: UIImage)
}
