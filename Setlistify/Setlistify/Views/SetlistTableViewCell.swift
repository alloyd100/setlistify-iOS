//
//  SetlistTableViewCell.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 01/12/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import UIKit

class SetlistTableViewCell: UITableViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var songCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func populateCell(with artist: String, venue: String, songCount: Int, dateString: String) {
        artistLabel.text = artist
        venueLabel.text = venue
        songCountLabel.text = "\(songCount) Songs"

        let dateArray:[String] = dateString.components(separatedBy: "-")
        dayLabel.text = dateArray[0]
        monthLabel.text = monthNameForCount(monthAsNumber: dateArray[1])
        yearLabel.text = dateArray[2]
    }
    
    func monthNameForCount(monthAsNumber: String) -> String {
        switch monthAsNumber {
        case "01":
            return "JAN"
        case "02":
            return "FEB"
        case "03":
            return "MAR"
        case "04":
            return "APR"
        case "05":
            return "MAY"
        case "06":
            return "JUN"
        case "07":
            return "JUL"
        case "08":
            return "AUG"
        case "09":
            return "SEP"
        case "10":
            return "OCT"
        case "11":
            return "NOV"
        case "12":
            return "DEC"
        default:
            return "-"
        }
    }
}
