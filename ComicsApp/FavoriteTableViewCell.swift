//
//  FavoriteTableViewCell.swift
//  ComicsApp
//
//  Created by GISELE TOLEDO on 21/07/24.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Configure the appearance of the thumbnailImageView
                thumbnailImageView.contentMode = .scaleAspectFill
                thumbnailImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
