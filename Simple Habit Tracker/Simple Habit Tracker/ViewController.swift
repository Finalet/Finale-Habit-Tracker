//
//  ViewController.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 02.12.2020.
//

import UIKit
import Foundation

class ViewController: UIViewController, MTSlideToOpenDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(slideToLock)
        self.view.addSubview(slideToLock1)
        self.view.addSubview(slideToLock2)
        self.view.addSubview(slideToLock3)
    }
    
    lazy var slideToLock: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: 240, width: UIScreen.main.bounds.width - 80, height: 68))
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
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: 340, width: UIScreen.main.bounds.width - 80, height: 68))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = 34
        slide.thumnailImageView.backgroundColor  = UIColor(red:40/255, green:170/255, blue:255/255, alpha:1.0)
        slide.draggedView.backgroundColor = UIColor(red:40/255, green:170/255, blue:255/255, alpha:1.0)
        slide.sliderBackgroundColor = UIColor(red:30/255, green:120/255, blue:180/255, alpha:1.0)
        slide.delegate = self
        slide.labelText = "Slide to record Running"
        slide.textLabel.textColor = .white
        return slide
    }()
    
    lazy var slideToLock2: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: 440, width: UIScreen.main.bounds.width - 80, height: 68))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = 34
        slide.thumnailImageView.backgroundColor = UIColor(red:255/255, green:80/255, blue:220/255, alpha:1.0)
        slide.draggedView.backgroundColor = UIColor(red:255/255, green:80/255, blue:220/255, alpha:1.0)
        slide.sliderBackgroundColor = UIColor(red:200/255, green:40/255, blue:170/255, alpha:1.0)
        slide.delegate = self
        slide.labelText = "Slide to record Running"
        slide.textLabel.textColor = .white
        return slide
    }()
    
    lazy var slideToLock3: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: 540, width: UIScreen.main.bounds.width - 80, height: 68))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = 34
        slide.thumnailImageView.backgroundColor  = UIColor(red:250/255, green:40/255, blue:40/255, alpha:1.0)
        slide.draggedView.backgroundColor = UIColor(red:250/255, green:40/255, blue:40/255, alpha:1.0)
        slide.sliderBackgroundColor = UIColor(red:200/255, green:20/255, blue:20/255, alpha:1.0)
        slide.delegate = self
        slide.labelText = "Slide to record Running"
        slide.textLabel.textColor = .white
        return slide
    }()
    

    var first: Bool = true
    
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        sender.resetStateWithAnimation(false)
        
        let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        
        PlayConfetti()
        
        if (first) {
            first = false
        }
    }
    
    func PlayConfetti () {
        let foreground = createConfettiLayer()
        let background: CAEmitterLayer = {
            let emitterLayer = createConfettiLayer()
            
            for emitterCell in emitterLayer.emitterCells ?? [] {
                emitterCell.scale = 0.5
            }

            emitterLayer.opacity = 0.5
            emitterLayer.speed = 0.95
            
            return emitterLayer
        }()
        view.layer.addSublayer(foreground)
        view.layer.addSublayer(background)
        addBehaviors(to: foreground)
        addBehaviors(to: background)
        addAnimations(to: foreground)
        addAnimations(to: background)
        
        let delay : Double = 5.0
        let time = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline:time){
            foreground.removeFromSuperlayer()
            background.removeFromSuperlayer()
        }
    }
}



