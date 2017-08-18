//
//  CommunityGroupTabCell.swift
//  Cru
//
//  Cell class for the users' joined/leading community groups on 
//  the main Get Involved screen. Used in the CommunityGroupsTabVC 
//  and GetInvolvedTabVC classes.
//
//  Created by Erica Solum on 8/5/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CommunityGroupTabCell: UITableViewCell {

    @IBOutlet weak var leaderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var ministryLabel: UILabel!
    @IBOutlet weak var leaderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}