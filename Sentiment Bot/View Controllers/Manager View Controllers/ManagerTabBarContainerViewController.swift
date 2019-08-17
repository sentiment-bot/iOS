//
//  ManagerTabBarContainerViewController.swift
//  Sentiment Bot
//
//  Created by Moin Uddin on 1/30/19.
//  Copyright © 2019 Scott Bennett. All rights reserved.
//

import UIKit

class ManagerTabBarContainerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for childVC in children {
            
            if let childVC = childVC as? UserContainerViewController {
                childVC.privilege = Privilege.admin
            }
        }
    }
    
    
    func getUserData() {
        
        APIController.shared.getManagingTeam(userId: UserDefaults.standard.userId) { (team, errorMessage) in
            if let errorMessage = errorMessage {
                print(errorMessage)
            } else {
                self.team = team
                guard let team = team else {
                    NSLog("Problem unwrapping team in ManagerTabBarViewController")
                    return
                }
                
                APIController.shared.getTeamResponses(teamId: team.id, completion: { (responses, error) in
                    if let error = error {
                        NSLog("There was error retreiving User's Team Responses: \(error)")
                    } else if let responses = responses {
                        APIController.shared.getUser(userId: 1, completion: { (user, errorMessage) in
                            self.user = user
                            self.teamResponses = responses
                        })
                    }
                })
            }
        }
        
    }
    
    var user: User? {
        didSet {
            
        }
    }
    var team: Team?
    
    var teamResponses: [Response]? {
        didSet {
            //passToVCs()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
