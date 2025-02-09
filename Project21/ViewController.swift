//
//  ViewController.swift
//  Project21
//
//  Created by Aleksei Ivanov on 7/2/25.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleWithTimeInterval))
    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }

    // прослойка между селектором и scheduleLocal для передачи параметра timeInterval
    @objc func scheduleWithTimeInterval() {
        scheduleLocal(timeInterval: 5)
    }
    
    func scheduleLocal(timeInterval: TimeInterval) {
        registerCategories()
        
        // The combination of content and trigger is enough to be combined into a request
        // each notification also has a unique identifier
        
        let center = UNUserNotificationCenter.current()
        // cancel pending notifications
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        // To attach custom data to the notification, e.g. an internal ID
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        // let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        //  meaning that any alert-based messages that get sent will be routed to our view controller to be handled
        center.delegate = self
        
        // creates an individual button for the user to tap
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        
        let remind = UNNotificationAction(identifier: "remind", title: "Remind me later", options: [])
        
        // groups multiple buttons together under a single identifier
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remind], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            // When the user acts on a notification you can read its actionIdentifier property to see what they did
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                let ac = UIAlertController(title: "You swiped to unlock", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                present(ac, animated: true)
                
            case "show":
                // the user tapped our "show more info…" button
                let ac = UIAlertController(title: "You tapped the notification to show more info", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                present(ac, animated: true)
                
            case "remind":
                scheduleLocal(timeInterval: 10)

            default:
                break
            }
        }
        
        // You must call the completion handler when you're done
        // This might be much later on, so it’s marked with the @escaping keyword.
        completionHandler()
    }
}

// Our project now creates notifications, attaches them to categories so you can create action buttons, then responds to whichever button was tapped by the user
