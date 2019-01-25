//
//  LocalNotificationHelper.swift
//  Sentiment Bot
//
//  Created by Moin Uddin on 1/11/19.
//  Copyright © 2019 Scott Bennett. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotificationHelper: NSObject, UNUserNotificationCenterDelegate {
    
    override init() {
        super.init()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            
            if let error = error { NSLog("Error requesting authorization status for local notifications: \(error)") }
            
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //This is called right before the notifcation gets shown to the user.
        //Calling this will show the alert in the app.
        completionHandler([.alert, .sound])
    }
    
    //Repond to selected emoji from survey
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response.actionIdentifier)
        var mood = response.actionIdentifier
        let emoji = String(mood.remove(at: mood.startIndex))
        currentSurveyId = Int(response.notification.request.identifier)
        guard let currentSurveyId = currentSurveyId else {
            NSLog("surveyId wasn't set when user responsed to survey through remote push notifcations")
            return
        }
        
        APIController.shared.createFeelzyResponse(userId: UserDefaults.standard.userId, surveyId: currentSurveyId, mood: mood, emoji: emoji) { (respone, errorMessage) in
            
        }
       
        
        completionHandler()
    }
    
    func printNextTriggerDate() {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            (requests) in
            var nextTriggerDates: [Date] = []
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                    let triggerDate = trigger.nextTriggerDate(){
                    nextTriggerDates.append(triggerDate)
                    print("TRIGGER DATES: \(nextTriggerDates)")
                }
            }
            if let nextTriggerDate = nextTriggerDates.min() {
                print("NEXT TRIGGER DATE: \(nextTriggerDate)")
            }
        }
    }
    
    var currentSurveyId: Int?
    
    func sendSurveyNotification(feelingsDictionaryArray: [[String: Any]], schedule: String, surveyId: Int, time: String) {
        currentSurveyId = surveyId
        let emojis = feelingsDictionaryArray.compactMap { "\($0["emoji"] as! String) \($0["mood"] as! String)" }
        
        let emojiActions = emojis.map({UNNotificationAction(identifier: $0, title: $0, options: [])})
        
        let category = UNNotificationCategory(identifier: "emojiCategory", actions: emojiActions, intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let content = UNMutableNotificationContent()
        content.title = "How do you feel?"
        //content.sound = UNNotificationSound.default
        content.categoryIdentifier = "emojiCategory"
        var trigger: DateComponents?
        var triggerNow: UNTimeIntervalNotificationTrigger?
        
        let hourMinutesArr = time.components(separatedBy: ":")
        
        let hour = Int(hourMinutesArr.first!)
        
        let minute = Int(hourMinutesArr.last!)
        
        switch schedule {
        case Trigger.daily.rawValue:
            trigger = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            trigger?.hour = hour
            trigger?.minute = minute
        case Trigger.monthly.rawValue:
            trigger = Calendar.current.dateComponents([.day], from: Date())
            trigger?.hour = hour
            trigger?.minute = minute
        case Trigger.weekly.rawValue:
            trigger = Calendar.current.dateComponents([.weekday,.hour,.minute,.second,], from: Date())
            trigger?.hour = hour
            trigger?.minute = minute
        case Trigger.now.rawValue:
            triggerNow = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        default:
            NSLog("Schedule wasn't set to change Triggers of Push Notifcation")
        }
        
        var request: UNNotificationRequest?
        
        if let trigger = trigger {
            let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
            request = UNNotificationRequest(identifier: String(surveyId), content: content, trigger: calendarTrigger)
        } else if let triggerNow = triggerNow {
            request = UNNotificationRequest(identifier: String(surveyId), content: content, trigger: triggerNow)
        }
        
        
        guard let theRequest = request else {
            NSLog("UNNotifcationRequest wasn't set to send survey to user through push notifcations")
            return
        }
        
        
        
        UNUserNotificationCenter.current().add(theRequest) {error in
            if let error = error {
                NSLog("There was an error scheduling a notification: \(error)")
                return
            }
            
        }
        
    }
}
