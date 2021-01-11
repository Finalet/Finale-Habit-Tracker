//
//  SettingsView.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 20.12.2020.
//

import Firebase
import UIKit

class SettingsView: UIViewController {
    
    weak var delegate: ViewController?
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var notificationsEnabled: Bool = true
    var soundsEnabled: Bool = true
    var hapticsEnabled: Bool = true
    
    @IBOutlet weak var slideIndicator: UIView!
    @IBOutlet weak var AppIconLight: UIButton!
    @IBOutlet weak var AppIconDark: UIButton!
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var soundsSwitch: UISwitch!
    @IBOutlet weak var hapticsSwitch: UISwitch!
    
    @IBOutlet weak var startNewDayLabel: UILabel!
    var timeOffset = 0
    let timeOptions24 = ["Midnight", "01:00", "02:00", "03:00", "04:00", "05:00"]
    let timeOptions12 = ["Midnight", "1:00 am", "2:00 am", "3:00 am", "4:00 am", "5:00 am"]
    
    @IBOutlet weak var interfaceSwitch: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.loadInterface()
        
        initializeView()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        

        if (UserDefaults.standard.object(forKey: "FINALE_DEV_APP_haptics") == nil) {
            hapticsEnabled = true
            UserDefaults.standard.set(hapticsEnabled, forKey: "FINALE_DEV_APP_haptics")
        } else {
            hapticsEnabled = UserDefaults.standard.bool(forKey: "FINALE_DEV_APP_haptics")
        }
        if (UserDefaults.standard.object(forKey: "FINALE_DEV_APP_sounds") == nil) {
            soundsEnabled = true
            UserDefaults.standard.set(soundsEnabled, forKey: "FINALE_DEV_APP_sounds")
        } else {
            soundsEnabled = UserDefaults.standard.bool(forKey: "FINALE_DEV_APP_sounds")
        }
        if (UserDefaults.standard.object(forKey: "FINALE_DEV_APP_notifications") == nil) {
            notificationsEnabled = true
            UserDefaults.standard.set(notificationsEnabled, forKey: "FINALE_DEV_APP_notifications")
        } else {
            notificationsEnabled = UserDefaults.standard.bool(forKey: "FINALE_DEV_APP_notifications")
        }
        notificationsSwitch.setOn(notificationsEnabled, animated: false)
        soundsSwitch.setOn(soundsEnabled, animated: false)
        hapticsSwitch.setOn(hapticsEnabled, animated: false)
        
        if (UserDefaults.standard.object(forKey: "FINALE_DEV_APP_timeOffset") == nil) {
            timeOffset = 0
            UserDefaults.standard.set(timeOffset, forKey: "FINALE_DEV_APP_timeOffset")
        } else {
            timeOffset = UserDefaults.standard.integer(forKey: "FINALE_DEV_APP_timeOffset")
        }
        changeStartNewDay()
        
        Analytics.logEvent("settings_open", parameters: nil)
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
        soundsSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        notificationsSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        AppIconDark.addTarget(self, action: #selector(changeIcon), for: .touchUpInside)
        AppIconLight.addTarget(self, action: #selector(changeIcon), for: .touchUpInside)
        interfaceSwitch.addTarget(self, action: #selector(changeInterface), for: .valueChanged)
        
        interfaceSwitch.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "FINALE_DEV_APP_interface")
    }
    
    @objc func changeInterface () {
        UserDefaults.standard.set(interfaceSwitch.selectedSegmentIndex, forKey: "FINALE_DEV_APP_interface")
        delegate?.loadInterface()
        
        var i = ""
        switch interfaceSwitch.selectedSegmentIndex {
        case 0:
            i = "unspecified"
        case 1:
            i = "dark"
        case 2:
            i = "light"
        default:
            i = "unspecified"
        }
        
        Analytics.logEvent("app_interface_changed", parameters: ["interface" : i])
    }
    
    @objc func changeIcon(sender: UIButton) {
        //Check if the app supports alternating icons
        guard UIApplication.shared.supportsAlternateIcons else {
            return;
        }
        
        if (sender == AppIconDark) {
            setIcon(name: "AppIcon-2")
            Analytics.logEvent("app_icon_changed", parameters: ["icon_style" : "dark"])
        } else if (sender == AppIconLight) {
            setIcon(name: "")
            Analytics.logEvent("app_icon_changed", parameters: ["icon_style" : "standard"])
        }
    }
    
    @IBAction func tutorialButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.presentTutorial()
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
            
            Analytics.logEvent("app_haptics_switched", parameters: ["state" : sender.isOn ? "true" : "false"])
        } else if (sender == notificationsSwitch) {
            notificationsEnabled = sender.isOn
            UserDefaults.standard.set(notificationsEnabled, forKey: "FINALE_DEV_APP_notifications")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            if (sender.isOn == true) {
                scheduleAllNotifications()
            }
            
            Analytics.logEvent("app_notification_switched", parameters: ["state" : sender.isOn ? "true" : "false"])
        } else if (sender == soundsSwitch) {
            soundsEnabled = sender.isOn
            UserDefaults.standard.set(soundsEnabled, forKey: "FINALE_DEV_APP_sounds")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            Analytics.logEvent("app_sounds_switched", parameters: ["state" : sender.isOn ? "true" : "false"])
        }
    }
    
    func scheduleAllNotifications () {
        for i in 0..<(delegate?.habits.count)! {
            scheduleNotification(habit: (delegate?.habits[i])!)
        }
    }
    
    func scheduleNotification (habit: Habit) {
        if (habit.notificationTime == "") {
            return
        }
        var dateComponents = DateComponents()
        let time = habit.notificationTime
        dateComponents.hour = Int(time.components(separatedBy: ":")[0]) ?? 19
        dateComponents.minute = Int(time.components(separatedBy: ":")[1]) ?? 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.body = "Are you ready to \"" + habit.name + "\" today?"
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
    @IBAction func startNewDayButton(_ sender: Any) {
        let pickerView = pickStartNewDay()
        pickerView.modalPresentationStyle = .pageSheet
        pickerView.delegate = self
        pickerView.timeOptions24 = timeOptions24
        pickerView.timeOptions12 = timeOptions12
        pickerView.currentOption = timeOffset
        present(pickerView, animated: true, completion: nil)
        
        UISelectionFeedbackGenerator().selectionChanged()
    }
    func changeStartNewDay (save: Bool = false) {
        if (is24Hour()) {
            startNewDayLabel.text = timeOptions24[timeOffset]
        } else {
            startNewDayLabel.text = timeOptions12[timeOffset]
        }
        
        if (!save) {
            return
        }
        UserDefaults.standard.set(timeOffset, forKey: "FINALE_DEV_APP_timeOffset")

        delegate?.checkTimeOffset(offset: timeOffset)
        
        var time = ""
        switch timeOffset {
        case 0:
            time = "00:00"
        case 1:
            time = "01:00"
        case 2:
            time = "02:00"
        case 3:
            time = "03:00"
        case 4:
            time = "04:00"
        case 5:
            time = "05:00"
        default:
            time = "00:00"
        }
        Analytics.logEvent("app_newDayTimeSet", parameters: ["time" : time])
    }
    func is24Hour() -> Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        return dateFormat.firstIndex(of: "a") == nil
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


class pickStartNewDay: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var timeOptions24 = [String]()
    var timeOptions12 = [String]()
    
    var currentOption = 0
    
    weak var delegate: SettingsView?
    var UIPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "app.background")
        
        let title = UILabel()
        title.text = "Choose when to start a new day"
        title.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        title.numberOfLines = 1
        view.addSubview(title)
        
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        title.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        
        let explanation = UILabel()
        explanation.text = "Your habits will refresh at the start of a new day."
        explanation.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        explanation.textColor = UIColor.systemGray
        explanation.translatesAutoresizingMaskIntoConstraints = false
        explanation.textAlignment = .left
        explanation.numberOfLines = 0
        view.addSubview(explanation)
        
        explanation.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        explanation.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        explanation.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        UIPicker.delegate = self as UIPickerViewDelegate
        UIPicker.dataSource = self as UIPickerViewDataSource
        UIPicker.backgroundColor = .systemGray6
        UIPicker.layer.cornerRadius = 10
        UIPicker.selectRow(currentOption, inComponent: 0, animated: false)
        UIPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(UIPicker)
        
        UIPicker.topAnchor.constraint(equalTo: explanation.bottomAnchor, constant: 20).isActive = true
        UIPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        UIPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        let confirmButton = UIButton()
        confirmButton.layer.cornerRadius = 10
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        confirmButton.backgroundColor = .systemTeal
        confirmButton.tintColor = .white
        confirmButton.center = view.center
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        
        view.addSubview(confirmButton)
        
        confirmButton.topAnchor.constraint(equalTo: UIPicker.bottomAnchor, constant: 20).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeOptions24.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (is24Hour()) {
            return timeOptions24[row]
        } else {
            return timeOptions12[row]
        }
    }
    
    func is24Hour() -> Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        return dateFormat.firstIndex(of: "a") == nil
    }
    @objc func confirm() {
        self.dismiss(animated: true, completion: nil)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.timeOffset = UIPicker.selectedRow(inComponent: 0)
        delegate?.changeStartNewDay(save: true)
    }
}
