//
//  SettingsView.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 20.12.2020.
//

import UIKit

class SettingsView: UIViewController {
    
    weak var delegate: ViewController?
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var notificationsEnabled: Bool = true
    var hapticsEnabled: Bool = true
    
    @IBOutlet weak var slideIndicator: UIView!
    @IBOutlet weak var AppIconLight: UIButton!
    @IBOutlet weak var AppIconDark: UIButton!
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var hapticsSwitch: UISwitch!
    
    @IBOutlet weak var interfaceSwitch: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeView()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        

        if (UserDefaults.standard.object(forKey: "FINALE_DEV_APP_haptics") == nil) {
            hapticsEnabled = true
            UserDefaults.standard.set(hapticsEnabled, forKey: "FINALE_DEV_APP_haptics")
        } else {
            hapticsEnabled = UserDefaults.standard.bool(forKey: "FINALE_DEV_APP_haptics")
        }
        if (UserDefaults.standard.object(forKey: "FINALE_DEV_APP_notifications") == nil) {
            notificationsEnabled = true
            UserDefaults.standard.set(notificationsEnabled, forKey: "FINALE_DEV_APP_notifications")
        } else {
            notificationsEnabled = UserDefaults.standard.bool(forKey: "FINALE_DEV_APP_notifications")
        }
        notificationsSwitch.setOn(notificationsEnabled, animated: false)
        hapticsSwitch.setOn(hapticsEnabled, animated: false)
        
        loadInterface()
    }
    
    func initializeView () {
        slideIndicator.roundCorners(.allCorners, radius: 10)
        
        AppIconDark.imageView?.layer.cornerRadius = 15
        AppIconDark.imageView?.layer.borderWidth = 2
        AppIconDark.imageView?.layer.borderColor = UIColor.systemGray.cgColor
        AppIconDark.layer.shadowColor = UIColor.black.cgColor
        AppIconDark.layer.shadowRadius = 4
        AppIconDark.layer.shadowOpacity = 0.3
        AppIconDark.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        AppIconLight.imageView?.layer.cornerRadius = 15
        AppIconLight.imageView?.layer.borderWidth = 2
        AppIconLight.imageView?.layer.borderColor = UIColor.systemGray.cgColor
        AppIconLight.layer.shadowColor = UIColor.black.cgColor
        AppIconLight.layer.shadowRadius = 4
        AppIconLight.layer.shadowOpacity = 0.3
        AppIconLight.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        hapticsSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        notificationsSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        AppIconDark.addTarget(self, action: #selector(changeIcon), for: .touchUpInside)
        AppIconLight.addTarget(self, action: #selector(changeIcon), for: .touchUpInside)
        interfaceSwitch.addTarget(self, action: #selector(changeInterface), for: .valueChanged)
        
        interfaceSwitch.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "FINALE_DEV_APP_interface")
    }
    
    @objc func changeInterface () {
        UserDefaults.standard.set(interfaceSwitch.selectedSegmentIndex, forKey: "FINALE_DEV_APP_interface")
        loadInterface()
    }
    
    func loadInterface () {
        let i = UserDefaults.standard.integer(forKey: "FINALE_DEV_APP_interface")
        switch i {
        case 0:
            overrideUserInterfaceStyle = .unspecified
            delegate?.overrideUserInterfaceStyle = .unspecified
        case 1:
            overrideUserInterfaceStyle = .light
            delegate?.overrideUserInterfaceStyle = .light
        case 2:
            overrideUserInterfaceStyle = .dark
            delegate?.overrideUserInterfaceStyle = .dark
        default:
            overrideUserInterfaceStyle = .unspecified
            delegate?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    @objc func changeIcon(sender: UIButton) {
        //Check if the app supports alternating icons
        guard UIApplication.shared.supportsAlternateIcons else {
            return;
        }
        
        if (sender == AppIconDark) {
            setIcon(name: "AppIcon-2")
        } else if (sender == AppIconLight) {
            setIcon(name: "")
        }
    }
    
    func setIcon (name: String) {
        if (name != "") {
            UIApplication.shared.setAlternateIconName(name) { (error) in
                //After app icon changed, print our error or success message
                if let error = error {
                    print("App icon failed to due to \(error)")
                } else {
                    print("App icon changed successfully.")
                }
            }
        } else {
            UIApplication.shared.setAlternateIconName(nil)
        }
    }
    
    @objc func switchValueChanged (sender: UISwitch) {
        if (sender == hapticsSwitch) {
            hapticsEnabled = sender.isOn
            UserDefaults.standard.set(hapticsEnabled, forKey: "FINALE_DEV_APP_haptics")
        } else if (sender == notificationsSwitch) {
            notificationsEnabled = sender.isOn
            UserDefaults.standard.set(notificationsEnabled, forKey: "FINALE_DEV_APP_notifications")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            if (sender.isOn == true) {
                scheduleAllNotifications()
            }
        }
    }
    
    func scheduleAllNotifications () {
        for i in 0..<(delegate?.habits.count)! {
            scheduleNotification(habit: (delegate?.habits[i])!)
        }
    }
    
    func scheduleNotification (habit: Habit) {
        var dateComponents = DateComponents()
        let time = habit.notificationTime
        dateComponents.hour = Int(time.components(separatedBy: ":")[0])
        dateComponents.minute = Int(time.components(separatedBy: ":")[1])
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.body = "Did you complete \"" + habit.name + "\" today?"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: habit.name, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
