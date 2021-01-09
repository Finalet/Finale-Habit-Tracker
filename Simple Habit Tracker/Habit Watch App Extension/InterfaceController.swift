//
//  InterfaceController.swift
//  Habit Watch App Extension
//
//  Created by Grant Oganyan on 03.01.2021.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var hiTextLabel: WKInterfaceLabel!
    
    @IBOutlet weak var habitsTable: WKInterfaceTable!
    
    var wcSession : WCSession?
    var lastDay = 0
    
    var habitsNames = [String]()
    var habitsIcons = [String]()
    var habitsCounts = [Int]()
    var habitsStreaks = [Int]()
    var habitsDoneTodays = [Bool]()
    var habitsLastDones = [Date]()
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        if(WCSession.isSupported()) {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        
        
        let userDefaults = UserDefaults.standard
        let name = userDefaults.string(forKey: "FINALE_DEV_APP_displayName") ?? ""
        hiTextLabel.setText("Hi, " + name)
        
        habitsNames = userDefaults.stringArray(forKey: "FINALE_DEV_APP_habitsNames") ?? [String]()
        habitsIcons = userDefaults.stringArray(forKey: "FINALE_DEV_APP_habitsIcons") ?? [String]()
        habitsCounts = userDefaults.array(forKey: "FINALE_DEV_APP_habitsCounts") as? [Int] ?? [Int]()
        habitsStreaks = userDefaults.array(forKey: "FINALE_DEV_APP_habitsStreaks") as? [Int] ?? [Int]()
        habitsDoneTodays = userDefaults.array(forKey: "FINALE_DEV_APP_habitsDoneTodays") as? [Bool] ?? [Bool]()
        habitsLastDones = userDefaults.array(forKey: "FINALE_DEV_APP_habitsLastDones") as? [Date] ?? [Date]()

        lastDay = userDefaults.integer(forKey: "FINALE_DEV_APP_lastDay")
        
        updateTable(save: false)
    }
    
    func updateTable (save: Bool) {
        if (habitsNames.count != habitsCounts.count || habitsNames.count != habitsStreaks.count || habitsNames.count != habitsIcons.count || habitsNames.count != habitsDoneTodays.count) {
            return
        }
        
        habitsTable.setNumberOfRows(habitsNames.count, withRowType: "cell")
        for index in 0..<habitsNames.count {
            let habitRow = habitsTable.rowController(at: index) as! RowController
            habitRow.habitName.setText(habitsNames[index])
            habitRow.emoji.setText(getEmoji(streakCount: habitsStreaks[index]))
            if(habitsDoneTodays[index] == true) {
                habitRow.habitIcon.setImage(UIImage(systemName: "checkmark.circle"))
                habitRow.habitIcon.setTintColor(UIColor.green)
            } else {
                habitRow.habitIcon.setImage(UIImage(named: habitsIcons[index]))
            }
        }
        
        if (save == false) {
            return
        }
        UserDefaults.standard.set(habitsNames, forKey: "FINALE_DEV_APP_habitsNames")
        UserDefaults.standard.set(habitsIcons, forKey: "FINALE_DEV_APP_habitsIcons")
        UserDefaults.standard.set(habitsCounts, forKey: "FINALE_DEV_APP_habitsCounts")
        UserDefaults.standard.set(habitsStreaks, forKey: "FINALE_DEV_APP_habitsStreaks")
        UserDefaults.standard.set(habitsDoneTodays, forKey: "FINALE_DEV_APP_habitsDoneTodays")
        UserDefaults.standard.set(habitsLastDones, forKey: "FINALE_DEV_APP_habitsLastDones")
    }
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        var habitExpanded = [habitsNames[rowIndex], habitsIcons[rowIndex], habitsCounts[rowIndex], habitsStreaks[rowIndex], habitsDoneTodays[rowIndex], rowIndex, self] as [Any]
        self.presentController(withName: "ExpandedView", context: habitExpanded)
    }
    func completeHabit (index: Int) {
        habitsCounts[index] += 1
        
        if (!habitsDoneTodays[index]) {
            habitsStreaks[index] += 1
        }
        habitsDoneTodays[index] = true
        habitsLastDones[index] = Date.today
        updateTable(save: true)
    }
    func resetHabit (index: Int) {
        if (!habitsDoneTodays[index]) {
            return
        }
        habitsDoneTodays[index] = false
        habitsCounts[index] -= 1
        if (habitsStreaks[index] > 0) {
            habitsStreaks[index] -= 1
        }
        
        updateTable(save: true)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let name = applicationContext["name"] as? String {
            hiTextLabel.setText("Hi, " + name)
            UserDefaults.standard.setValue(name, forKey: "FINALE_DEV_APP_displayName")
        }
        
        if let names = applicationContext["habitsNames"] as? [String]  {
            habitsNames = names
        }
        if let icons = applicationContext["habitsIcons"] as? [String] {
            habitsIcons = icons
        }
        if let counts = applicationContext["habitsCounts"] as? [Int] {
            habitsCounts = counts
        }
        if let streaks = applicationContext["habitsStreaks"] as? [Int] {
            habitsStreaks = streaks
        }
        if let donetoday = applicationContext["habitsDoneTodays"] as? [Bool] {
            habitsDoneTodays = donetoday
        }
        if let lastdone = applicationContext["habitsLastDones"] as? [Date] {
            habitsLastDones = lastdone
        }
        updateTable(save: true)
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("RECIEVED USER INFO")
        if let names = userInfo["habitsNames"] as? [String]  {
            habitsNames = names
        }
        if let icons = userInfo["habitsIcons"] as? [String] {
            habitsIcons = icons
        }
        if let counts = userInfo["habitsCounts"] as? [Int] {
            habitsCounts = counts
        }
        if let streaks = userInfo["habitsStreaks"] as? [Int] {
            habitsStreaks = streaks
        }
        if let donetoday = userInfo["habitsDoneTodays"] as? [Bool] {
            habitsDoneTodays = donetoday
        }
        if let lastdone = userInfo["habitsLastDones"] as? [Date] {
            habitsLastDones = lastdone
        }
        updateTable(save: true)
    }
    
    func getEmoji (streakCount: Int) -> String {
        if (streakCount <= 1) {
            return ""
        } else if (streakCount <= 6){
            return "👌"
        } else if (streakCount <= 13){
            return "🙌"
        } else if (streakCount <= 20){
            return "💪"
        } else if (streakCount <= 29){
            return "🔥"
        } else if (streakCount <= 59){
            return "🎊"
        } else if (streakCount <= 89){
            return "👑"
        } else if (streakCount <= 119){
            return "💘"
        } else if (streakCount <= 149){
            return "💕"
        } else if (streakCount <= 179){
            return "💓"
        } else {
            return "🃏"
        }
    }
    
    func checkDate () {
        if (lastDay != Date().dayNumberOfWeek()) {
            for x in 0..<habitsNames.count {
                if (habitsDoneTodays[x] == true) {
                    //reset icon
                    habitsDoneTodays[x] = false
                }
                if (Calendar.current.isDateInYesterday(habitsLastDones[x]) != true && Calendar.current.isDateInToday(habitsLastDones[x]) != true && Calendar.current.isDateInTomorrow(habitsLastDones[x]) != true) {
                    habitsStreaks[x] = 0
                }
            }
            lastDay = Date().dayNumberOfWeek()!
            //lastDay = Calendar.current.component(.minute, from: Date())
            UserDefaults.standard.set(lastDay, forKey: "FINALE_DEV_APP_lastDay")
            updateTable(save: true)
        }
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    static var today:  Date { return Date().thisDay }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var thisDay: Date {
        return Calendar.current.date(byAdding: .day, value: 0, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}
