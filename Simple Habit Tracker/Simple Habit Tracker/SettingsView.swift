//
//  SettingsView.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 20.12.2020.
//

import UIKit

class SettingsView: UIViewController {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var hapticsEnabled: Bool = true
    
    @IBOutlet weak var slideIndicator: UIView!
    @IBOutlet weak var AppIconLight: UIButton!
    @IBOutlet weak var AppIconDark: UIButton!
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var hapticsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeView()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        

        if (UserDefaults.standard.object(forKey: "haptics") == nil) {
            hapticsEnabled = true
            UserDefaults.standard.set(hapticsEnabled, forKey: "haptics")
        } else {
            hapticsEnabled = UserDefaults.standard.bool(forKey: "haptics")
        }
        hapticsSwitch.setOn(hapticsEnabled, animated: false)
    }
    
    func initializeView () {
        slideIndicator.roundCorners(.allCorners, radius: 10)
        
        AppIconDark.imageView?.layer.cornerRadius = 15
        AppIconDark.layer.shadowColor = UIColor.black.cgColor
        AppIconDark.layer.shadowRadius = 4
        AppIconDark.layer.shadowOpacity = 0.3
        AppIconDark.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        AppIconLight.imageView?.layer.cornerRadius = 15
        AppIconLight.layer.shadowColor = UIColor.black.cgColor
        AppIconLight.layer.shadowRadius = 4
        AppIconLight.layer.shadowOpacity = 0.3
        AppIconLight.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        hapticsSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        AppIconDark.addTarget(self, action: #selector(changeIcon), for: .touchUpInside)
    }
    
    @objc func changeIcon() {
        //Check if the app supports alternating icons
        guard UIApplication.shared.supportsAlternateIcons else {
            return;
        }
        
        let name = "icon.dark_60pt"
        //Change the icon to a specific image with given name
        UIApplication.shared.setAlternateIconName(name) { (error) in
            //After app icon changed, print our error or success message
            if let error = error {
                print("App icon failed to due to \(error)")
            } else {
                print("App icon changed successfully.")
            }
        }
    }
    
    @objc func switchValueChanged (sender: UISwitch) {
        if (sender == hapticsSwitch) {
            hapticsEnabled = sender.isOn
            UserDefaults.standard.set(hapticsEnabled, forKey: "haptics")
        }
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
