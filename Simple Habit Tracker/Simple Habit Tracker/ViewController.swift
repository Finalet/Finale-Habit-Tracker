//
//  ViewController.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 02.12.2020.
//

import UIKit

class ViewController: UIViewController, MTSlideToOpenDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(slideToLock)
        self.view.addSubview(slideToLock1)
        self.view.addSubview(slideToLock2)
        self.view.addSubview(slideToLock3)
    }
    
    lazy var slideToLock: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: 200, width: UIScreen.main.bounds.width - 80, height: 68))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = 34
        slide.thumnailImageView.backgroundColor  = UIColor(red:50/255, green:230/255, blue:50/255, alpha:1.0)
        slide.draggedView.backgroundColor = UIColor(red:50/255, green:230/255, blue:50/255, alpha:1.0)
        slide.sliderBackgroundColor = UIColor(red:90/255, green:200/255, blue:90/255, alpha:1.0)
        slide.delegate = self
        slide.labelText = "Slide to record Running"
        slide.textLabel.textColor = .white
        return slide
    }()
    
    lazy var slideToLock1: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: 300, width: UIScreen.main.bounds.width - 80, height: 68))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = 34
        slide.thumnailImageView.backgroundColor  = UIColor(red:50/255, green:230/255, blue:50/255, alpha:1.0)
        slide.draggedView.backgroundColor = UIColor(red:50/255, green:230/255, blue:50/255, alpha:1.0)
        slide.sliderBackgroundColor = UIColor(red:90/255, green:200/255, blue:90/255, alpha:1.0)
        slide.delegate = self
        slide.labelText = "Slide to record Running"
        slide.textLabel.textColor = .white
        return slide
    }()
    
    lazy var slideToLock2: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: 400, width: UIScreen.main.bounds.width - 80, height: 68))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = 34
        slide.thumnailImageView.backgroundColor  = UIColor(red:50/255, green:230/255, blue:50/255, alpha:1.0)
        slide.draggedView.backgroundColor = UIColor(red:50/255, green:230/255, blue:50/255, alpha:1.0)
        slide.sliderBackgroundColor = UIColor(red:90/255, green:200/255, blue:90/255, alpha:1.0)
        slide.delegate = self
        slide.labelText = "Slide to record Running"
        slide.textLabel.textColor = .white
        return slide
    }()
    
    lazy var slideToLock3: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: 500, width: UIScreen.main.bounds.width - 80, height: 68))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = 34
        slide.thumnailImageView.backgroundColor  = UIColor(red:50/255, green:230/255, blue:50/255, alpha:1.0)
        slide.draggedView.backgroundColor = UIColor(red:50/255, green:230/255, blue:50/255, alpha:1.0)
        slide.sliderBackgroundColor = UIColor(red:90/255, green:200/255, blue:90/255, alpha:1.0)
        slide.delegate = self
        slide.labelText = "Slide to record Running"
        slide.textLabel.textColor = .white
        return slide
    }()

    
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        let alertController = UIAlertController(title: "", message: "Done!", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Okay", style: .default) { (action) in
            sender.resetStateWithAnimation(false)
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
        
        let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
    
    }    
}

