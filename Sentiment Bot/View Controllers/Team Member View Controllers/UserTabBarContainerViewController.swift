//
//  UserTabBarContainerViewController.swift
//  Sentiment Bot
//
//  Created by Moin Uddin on 1/30/19.
//  Copyright © 2019 Scott Bennett. All rights reserved.
//

import UIKit

class UserTabBarContainerViewController: UIViewController {
    
    var responses: [Response] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        APIController.shared.getUserResponses(userId: UserDefaults.standard.userId) { (responses, errorMessage) in
            if let errorMessage = errorMessage {
                NSLog(errorMessage.message.joined(separator: "\n"))
            } else {
                guard let responses = responses else {
                    NSLog("Responses wasn't set in UserTabBarContainerVC")
                    return
                }
                self.responses = responses
                self.passToChildViewControllers()
            }
        }
        
    }
    
    func passToChildViewControllers() {
        for child in children {
            if let child = child as? UserContainerViewController {
                child.privilege = Privilege.teamMember
            }
            if var child = child as? UserProtocol {
                child.userResponses = responses
                child.user = APIController.shared.currentUser
            }
            
            if var child = child as? UserImageProtocol {
                child.userImage = APIController.shared.userImage
            }
        }
    }

}
