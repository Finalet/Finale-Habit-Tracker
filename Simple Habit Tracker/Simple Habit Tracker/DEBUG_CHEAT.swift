//
//  DEBUG_CHEAT.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 06.01.2021.
//

import Foundation
import UIKit

class DEBUG_CHEAT: UIViewController {
    
    @IBOutlet weak var viewPanel: UIView!
    @IBOutlet weak var totalDaysInput: UITextField!
    @IBOutlet weak var totalStreakInput: UITextField!
    @IBOutlet weak var confirmButtonUI: UIButton!
    @IBOutlet weak var titleText: UILabel!
    
    weak var delegate: ViewController?
    
    var habitIndex = 0
    var habitName = ""
    var days = ""
    var streaks = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPanel.layer.cornerRadius = 10
        viewPanel.layer.shadowColor = UIColor.black.cgColor
        viewPanel.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewPanel.layer.shadowRadius = 6
        viewPanel.layer.shadowOpacity = 0.3
        
        confirmButtonUI.layer.cornerRadius = 6
        titleText.text = "Fix " + habitName
        totalDaysInput.text = days
        totalStreakInput.text = streaks
    }
    
    @IBAction func confirmButtonAction(_ sender: UIButton) {
        let days: String = totalDaysInput.text!
        let streak: String = totalStreakInput.text!
        delegate?.fixHabitNumbers(habitIndex: habitIndex, totalDays: Int(days) ?? 0, streakCount: Int(streak) ?? 0)
        self.dismiss(animated: true, completion: nil)
    }
}

