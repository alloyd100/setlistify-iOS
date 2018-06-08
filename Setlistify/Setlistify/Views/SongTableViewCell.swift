//
//  SongTableViewCell.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 01/12/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import UIKit
import Kingfisher

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCell(with songName: String, albumName: String, imageURL: URL?, info: String, spotifySupport: Bool, playing: Bool) {
        songNameLabel.text = songName
        albumNameLabel.text = albumName
        if let url = imageURL {
            albumCoverImageView.kf.setImage(with: url, placeholder: UIImage(named: "AlbumPlaceholder"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            albumCoverImageView.image = #imageLiteral(resourceName: "AlbumPlaceholder")
        }
        infoLabel.text = info
        
        playButton.isHidden = !spotifySupport
        setPlayingIcon(playing: playing)
    }
    
    func setPlayingIcon(playing: Bool) {
        playButton.setImage(playing ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "play"), for: .normal)
    }
}
