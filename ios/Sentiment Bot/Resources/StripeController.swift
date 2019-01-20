//
//  StripeController.swift
//  Sentiment Bot
//
//  Created by Moin Uddin on 1/19/19.
//  Copyright © 2019 Scott Bennett. All rights reserved.
//

import Foundation


class StripeController {
    
    
    static let shared = StripeController()
    
    
    
    //Charge Customer for Subscription
    func subscribeToPremium(token: String, completion: @escaping (Error?) -> Void = {_ in }) {
        let url = baseUrl.appendingPathComponent("subscriptions")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.post.rawValue
        let stripeParams = ["card_token": token] as [String: Any]
        do {
            let json = try JSONSerialization.data(withJSONObject: stripeParams, options: .prettyPrinted)
            request.httpBody = json
        } catch {
            NSLog("Error encoding JSON")
            completion(error)
        }
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            if let error = error {
                NSLog("There was an error sending stripe token credentials to server: \(error)")
                completion(error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                NSLog("Error code(createCustomerKey) from the http request: \(httpResponse.statusCode)")
                completion(error)
                return
            }
            
            NSLog("User subscribed to unlimited premium service")
            
            }.resume()
    }
    
    //let baseUrl = URL(string: "https://sentimentbot-1.herokuapp.com/api")!
    let baseUrl = URL(string: "http://localhost:3000/api")!
}
