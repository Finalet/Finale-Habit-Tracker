//
//  TutorialView.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 28.12.2020.
//

import Foundation
import UIKit
import Firebase

class TutorialView: UIViewController, MTSlideToOpenDelegate {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        if (sender.hapticsEnabled == true) {
            let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
        }
    }
    
    
    weak var delegate: ViewController?
    
    let blurEffectView: UIVisualEffectView! = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var doneButtonUI: UIButton!
    @IBOutlet weak var fakeAddButton: UIButton!
    
    @IBOutlet weak var swipeText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.layer.cornerRadius = 20
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOffset = CGSize(width: 0, height: 0)
        mainView.layer.shadowRadius = 10
        mainView.layer.shadowOpacity = 0.4
        
        blurEffectView.frame = UIScreen.main.bounds
        blurEffectView.alpha = 0.6
        view.insertSubview(blurEffectView, belowSubview: mainView)
        
        doneButtonUI.layer.cornerRadius = 10
        
        fakeAddButton.layer.cornerRadius = fakeAddButton.frame.width/2
        
        let slider = MTSlideToOpenView(frame: CGRect(x: 20, y: swipeText.frame.origin.y + 35, width: UIScreen.main.bounds.width - 80, height: 50))
        slider.delegate = self
        slider.sliderViewTopDistance = 0
        slider.sliderCornerRadius = 25
        slider.thumbnailViewTopDistance = 4
        slider.thumbnailViewStartingDistance = 4
        slider.labelText = "Try it out!"
        slider.textLabelLeadingDistance = 60
        slider.textColor = .white
        slider.showSliderText = true
        slider.sliderTextLabel.text = "Try it out"
        slider.sliderTextLabel.textColor = .white
        slider.draggedView.backgroundColor = .systemTeal
        slider.sliderBackgroundColor = UIColor.systemTeal.withAlphaComponent(0.5)
        slider.thumnailImageView.layer.shadowRadius = 4
        slider.thumnailImageView.layer.shadowOpacity = 0.3
        slider.thumnailImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        slider.thumnailImageView.image = UIImage(systemName: "lightbulb.fill")
        slider.thumnailImageView.tintColor = .white
        
        let interaction = UIContextMenuInteraction(delegate: self)
        slider.addInteraction(interaction)
        
        mainView.addSubview(slider)
        
        let holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(openSettings))
        view.addGestureRecognizer(holdRecognizer)
        
        Analytics.logEvent("tutorial_open", parameters: nil)
    }
    @IBAction func doneButtonPress(_ sender: Any) {
        requestNotificationAccess()
        dismiss(animated: true, completion: nil)
        UserDefaults.standard.setValue(true, forKey: "FINALE_DEV_APP_tutorialDone")
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    @objc func openSettings (sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let slideVC = SettingsView()
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            slideVC.delegate = delegate
            self.present(slideVC, animated: true, completion: nil)
            
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    func requestNotificationAccess() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notification Access Granted")
            } else {
                print("Notification Access Denied")
            }
        }
    }
    @IBAction func fakeAddButtonAction(_ sender: Any) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

extension TutorialView: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension TutorialView: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    configurationForMenuAtLocation location: CGPoint)
      -> UIContextMenuConfiguration? {
    
    let testMenuAction = UIAction(title: "Well done!", image: UIImage(systemName: "hand.thumbsup.fill")) {action in
        
    }
    
    return UIContextMenuConfiguration(
      identifier: nil,
      previewProvider: nil,
      actionProvider: { _ in
        return UIMenu(title: "", children: [testMenuAction])
    })
  }
}
