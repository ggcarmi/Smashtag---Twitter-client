//
//  ImageTableViewCell.swift
//  Smashtag1
//
//  Created by Gai Carmi on 10/1/17.
//  Copyright © 2017 Gai Carmi. All rights reserved.
//

import UIKit
import Twitter

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    var mediaItem: MediaItem?  { didSet{ updateUI() } }
    
    func updateUI(){
        // image
        if let imageURL = mediaItem?.url {
            // FIXME: blocks main thread
            if let imageData = try? Data(contentsOf: imageURL) {
                imageViewOutlet?.image = UIImage(data: imageData)
            }
        } else {
            imageViewOutlet?.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
