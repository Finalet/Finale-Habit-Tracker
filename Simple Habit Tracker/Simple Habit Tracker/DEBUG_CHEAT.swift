///
//  DEBUG_CHEAT.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 06.01.2021.
//

import Foundation
import UIKit

class DEBUG_CHEAT: UIViewController {
    
    let containerView = UIView()
    let titleLabel = UILabel()
    
    let daysLabel = UILabel()
    let daysInputField = UITextField()
    
    let streakLabel = UILabel()
    let streakInputField = UITextField()
    
    let confirmButton = UIButton()
    
    weak var delegate: ViewController?
    
    var habitIndex = 0
    var habitName = ""
    var days = ""
    var streaks = ""
    
    let padding = 20.0
    
    init(habitName: String, days: String, streaks: String, habitIndex: Int) {
        self.habitName = habitName
        self.days = days
        self.streaks = streaks
        self.habitIndex = habitIndex
        super.init(nibName: nil, bundle: nil)
        
        let blurEffect = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        blurEffect.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        self.view.addSubview(blurEffect)
        self.view.backgroundColor = .clear
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Dismiss)))
        
        let containerHeight = 200.0
        containerView.frame = CGRect(x: padding*2, y: 0.5*(UIScreen.main.bounds.height-containerHeight), width: UIScreen.main.bounds.width-padding*4, height: containerHeight)
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .systemBackground
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowRadius = 10.0
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowOpacity = 0.3
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
        
        titleLabel.frame = CGRect(x: padding, y: padding, width: containerView.frame.width-padding*2, height: 20)
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.text = "Fix \"\(habitName)\""
        titleLabel.textAlignment = .center
        
        let inputFieldWidth = 100.0
        
        daysLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY + padding, width: 100, height: 20)
        daysLabel.text = "Total days"
        
        daysInputField.frame = CGRect(x: containerView.frame.width-padding-inputFieldWidth, y: daysLabel.frame.origin.y + 0.5*(daysLabel.frame.height-30), width: inputFieldWidth, height: 30)
        daysInputField.text = days
        daysInputField.borderStyle = .roundedRect
        daysInputField.textAlignment = .right
        daysInputField.keyboardType = .numberPad
        
        streakLabel.frame = CGRect(x: padding, y: daysLabel.frame.maxY+padding, width: 100, height: 20)
        streakLabel.text = "Streak"
        
        streakInputField.frame = CGRect(x: containerView.frame.width-padding-inputFieldWidth, y: streakLabel.frame.origin.y + 0.5*(streakLabel.frame.height-30), width: inputFieldWidth, height: 30)
        streakInputField.text = streaks
        streakInputField.borderStyle = .roundedRect
        streakInputField.textAlignment = .right
        streakInputField.keyboardType = .numberPad
        
        let buttonHeight = 40.0
        confirmButton.frame = CGRect(x: padding, y: streakInputField.frame.maxY + padding, width: containerView.frame.width-padding*2, height: buttonHeight)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = .systemTeal
        confirmButton.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
        confirmButton.layer.cornerRadius = 8
        
        containerView.frame.size.height = confirmButton.frame.maxY + padding
        
        containerView.addSubview(daysLabel)
        containerView.addSubview(streakLabel)
        containerView.addSubview(daysInputField)
        containerView.addSubview(streakInputField)
        containerView.addSubview(titleLabel)
        containerView.addSubview(confirmButton)
        self.view.addSubview(containerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func confirmButtonAction() {
        let days: String = daysInputField.text!
        let streak: String = streakInputField.text!
        delegate?.fixHabitNumbers(habitIndex: habitIndex, totalDays: Int(days) ?? 0, streakCount: Int(streak) ?? 0)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func Dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

