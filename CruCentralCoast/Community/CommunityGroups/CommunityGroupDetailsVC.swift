//
//  CommunityGroupDetailsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 7/5/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import MessageUI

class CommunityGroupDetailsVC: UIViewController, MFMessageComposeViewControllerDelegate {

    

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var dayTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearGenderLabel: UILabel!
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var joinCommunityGroupButton: CruButton!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    var leaderPhoneNumbers : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        
    }
    
    @IBAction func didTapContactLeader() {
        if MFMessageComposeViewController.canSendText() {
            if self.leaderPhoneNumbers.isEmpty {
                self.presentAlert(title: "Can't Contact Leader", message: "Sorry, there is no phone number listed for this group")
            }
            
            else {
                let controller = MFMessageComposeViewController()
                controller.body = "Hey I'm interested in joining your community group!"
                controller.recipients = self.leaderPhoneNumbers
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
            
        }
        else {
            print("error cant send text")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func configure(with communityGroup: CommunityGroup) {
        DispatchQueue.main.async {
            
            var leaderArray : [String] = []
            for leader in communityGroup.leaders {
                leaderArray.append(leader.name)
            }
            self.nameLabel.text = leaderArray.joined(separator: ", ")
            
            self.movementLabel.text = communityGroup.movement?.name
            
            let gender = communityGroup.gender.rawValue.localizedCapitalized
            let day = communityGroup.weekDay.rawValue.localizedCapitalized
            let time = communityGroup.time ?? "N/A"
            let year = communityGroup.year.rawValue.localizedCapitalized 
            
            if day == "" || time == "" {
                self.dayTimeLabel.text = "No meeting time listed"
            }
            else {
                self.dayTimeLabel.text = "Meets on " + day + " at " + time
            }
            
            self.yearGenderLabel.text = year + " | " + gender
            
            //self.leaderNamesLabel.text = "Leaders: \(communityGroup.leaderNames ?? "N/A")"
            
            for leader in communityGroup.leaders {
                if let phoneNumber = leader.phone{
                    self.leaderPhoneNumbers.append(phoneNumber)
                }
            }

            self.bannerImageView.downloadedFrom(link: communityGroup.imageLink, contentMode: .scaleAspectFill)
            // If no image link exists, remove the image's size constraint
            self.imageViewAspectRatioConstraint.isActive = (communityGroup.imageLink != nil && !communityGroup.imageLink!.isEmpty)
        }
    }
}
