//
//  ViewController.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 02.12.2020.
//

import UIKit
import WidgetKit
import Foundation
import Firebase
import WatchConnectivity
import AVFoundation
import StoreKit

class ViewController: UIViewController, MTSlideToOpenDelegate, MTSlideToOpenSwiftDelegate, AddHabitDelegate { //WATCH wcsessiondelegate
    
    @IBOutlet weak var addButtonUI: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var habits = [Habit]()
    var sliders = [MTSlideToOpenView]()
    
    let sliderHeight: CGFloat = 60.0
    let slidersGap: CGFloat = 20
    
    var lastDay: Int = 0
    
    @IBOutlet weak var motivationalPhrasesLable: UILabel!
    var motivationalPhrases = ["Ready to change your habits?", "A small move forward every day.", "Don't let 'later' become 'never'.", "Little things make big days.", "Habits change into character.", "Life is a succession of habits.", "Winning is a habit", "Out of routine comes inspiration.", "Good habits are the key to success.", "Once you learn to win, it becomes a habit."]
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var hiText: UILabel!
    @IBOutlet weak var suggestionLabel: UILabel!
    
    var timeOffset = 0
    
    // var wcSession : WCSession? WATCH
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTable()
        initializedAddButton()
        initializeTitle()
        GSAudio.sharedInstance.preloadSound(soundFileName: "tickSound")
        
        self.hideKeyboardWhenTappedAround()
        let holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(openSettings))
        view.addGestureRecognizer(holdRecognizer)
        
        lastDay = UserDefaults.standard.integer(forKey: "FINALE_DEV_APP_lastDay")
        self.checkTimeOffset()
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.checkDate()
        }
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(appWentToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(stopEditingTable))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // watch() WATCH
    }
    
    func checkTimeOffset(offset: Int = Int()) {
        if (offset != Int()) {
            timeOffset = offset
            return
        }
        
        if (UserDefaults.standard.object(forKey: "FINALE_DEV_APP_timeOffset") == nil) {
            timeOffset = 0
            UserDefaults.standard.set(timeOffset, forKey: "FINALE_DEV_APP_timeOffset")
        } else {
            timeOffset = UserDefaults.standard.integer(forKey: "FINALE_DEV_APP_timeOffset")
        }
    }
    
    func watch () {
        if(WCSession.isSupported()) {
            //wcSession = WCSession.default WATCH
            //wcSession?.delegate = self
            //wcSession?.activate()
        }

        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1) {
            //self.watch_updateName()
            //self.watch_updateTable()
            //self.watch_updateLastDay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadInterface()
        let tutorialShown = UserDefaults.standard.bool(forKey: "FINALE_DEV_APP_tutorialDone")
        if (tutorialShown != true) {
            presentTutorial()
        } else {
            requestNotificationAccess()
        }
    }
    
    func presentTutorial() {
        let slideVC = TutorialView()
        slideVC.modalPresentationStyle = .overCurrentContext
        slideVC.modalTransitionStyle = .crossDissolve
        slideVC.transitioningDelegate = self
        slideVC.delegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    func loadInterface () {
        let i = UserDefaults.standard.integer(forKey: "FINALE_DEV_APP_interface")
        switch i {
        case 0:
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .unspecified
            view.overrideUserInterfaceStyle = .unspecified
            overrideUserInterfaceStyle = .unspecified
        case 1:
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .light
            view.overrideUserInterfaceStyle = .light
            overrideUserInterfaceStyle = .light
        case 2:
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .dark
            view.overrideUserInterfaceStyle = .dark
            overrideUserInterfaceStyle = .dark
        default:
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .unspecified
            view.overrideUserInterfaceStyle = .unspecified
            overrideUserInterfaceStyle = .unspecified
        }
    }
    
    @objc func appWentToBackground () {
        Analytics.logEvent("app_in_background", parameters: ["app_habits_count": habits.count])
        passDataToWidget()
    }
    
    func passDataToWidget () {
        let userDefaults = UserDefaults(suiteName: "group.finale-habit-widget-cache")
        var habitsNames = [String]()
        var habitsIcons = [String]()
        var habitsStreaks = [Int]()
        var habitsDoneTodays = [Bool]()
        for habit in habits {
            if (habitsNames.count >= 5) {
                break
            }
            if (habit.doneToday) {
                continue
            }
            habitsNames.append(habit.name)
            habitsIcons.append(habit.icon.replacingOccurrences(of: ".png", with: ""))
            habitsStreaks.append(habit.streakCount)
            habitsDoneTodays.append(habit.doneToday)
        }
        for habit in habits {
            if (habitsNames.count >= 5) {
                break
            }
            if (!habit.doneToday) {
                continue
            }
            habitsNames.append(habit.name)
            habitsIcons.append(habit.icon.replacingOccurrences(of: ".png", with: ""))
            habitsStreaks.append(habit.streakCount)
            habitsDoneTodays.append(habit.doneToday)
        }
        userDefaults?.setValue(habitsNames, forKey: "FINALE_DEV_APP_widgetCache")
        userDefaults?.setValue(habitsIcons, forKey: "FINALE_DEV_APP_widgetCacheIcons")
        userDefaults?.setValue(nameTextField.text, forKey: "FINALE_DEV_APP_widgetCacheName")
        userDefaults?.setValue(habitsStreaks, forKey: "FINALE_DEV_APP_widgetCacheStreak")
        userDefaults?.setValue(habitsDoneTodays, forKey: "FINALE_DEV_APP_widgetCacheDoneTodays")
        userDefaults?.setValue(timeOffset, forKey: "FINALE_DEV_APP_widgetTimeOffset")
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
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
    
    func initializeTable () {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = sliderHeight + slidersGap
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = .clear
        
        loadHabits()
    }
    
    func initializedAddButton () {
        addButtonUI.layer.cornerRadius = addButtonUI.bounds.width/2
        addButtonUI.layer.shadowColor = UIColor.black.cgColor
        addButtonUI.layer.shadowRadius = 6
        addButtonUI.layer.shadowOpacity = 0.3
        addButtonUI.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func initializeTitle () {
        let x = Int.random(in: 0..<motivationalPhrases.count)
        motivationalPhrasesLable.text = motivationalPhrases[x]
        
        nameTextField.delegate = self
        
        hiText.font = nameTextField.font?.withSize(CGFloat(UserDefaults.standard.float(forKey: "FINALE_DEV_APP_displayNameFontSize")))
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1){
            self.nameTextField.text = UserDefaults.standard.string(forKey: "FINALE_DEV_APP_displayName") ?? ""
        }
    }
    func createNewSlider(habit: Habit) -> MTSlideToOpenView {
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: slidersGap/2, width: UIScreen.main.bounds.width - 80, height: sliderHeight))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = sliderHeight/2
        slide.thumbnailViewTopDistance = 4
        slide.thumbnailViewStartingDistance = 4
        slide.thumnailImageView.backgroundColor  = .clear
        slide.backgroundColor = UIColor.clear
        slide.delegate = self
        slide.swiftDelegate = self
        slide.ViewControllerDelegate = self
        slide.labelText = habit.name
        slide.textLabel.textColor = .white
        slide.textLabel.font = slide.textLabel.font.withSize(18)
        slide.showSliderText = true
        slide.sliderTextLabel.textColor = .white
        slide.sliderTextLabel.font = slide.textLabel.font
        slide.sliderTextLabel.alpha = 0
        slide.habit = habit
        slide.sliderHolderView.layer.borderWidth = 3
        slide.sliderHolderView.layer.borderColor = UIColor.systemGray2.withAlphaComponent(0.5).cgColor
        slide.textLabelLeadingDistance = 60
        slide.draggedView.backgroundColor = UIColor(named: habit.color + ".main")
        slide.sliderBackgroundColor = UIColor(named: habit.color + ".secondary")!
        slide.layer.cornerRadius = sliderHeight/2
        
        slide.thumnailImageView.layer.shadowRadius = 4
        slide.thumnailImageView.layer.shadowOpacity = 0.3
        slide.thumnailImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        let icon = UIImageView(image: UIImage(named: "Images.bundle/" + habit.icon))
        icon.frame.size = CGSize(width: slide.thumnailImageView.frame.width - slide.thumbnailViewTopDistance * 2, height: slide.thumnailImageView.frame.height - slide.thumbnailViewTopDistance * 2)
        slide.thumnailImageView.addSubview(icon)
        
        slide.totalCountText.frame = CGRect(x: sliderHeight/2, y: 0, width: sliderHeight*2, height: sliderHeight)
        slide.totalCountText.text = String(habit.count)
        slide.totalCountText.font = slide.textLabel.font.withSize(20)
        
        slide.streakCountText.frame = CGRect(x: slide.bounds.width - sliderHeight * 2.5, y: 0, width: sliderHeight*2, height: sliderHeight)
        slide.streakCountText.text = String(habit.streakCount)
        slide.streakCountText.font = slide.textLabel.font.withSize(20)
        
        slide.emojiText.frame = CGRect(x: slide.bounds.width-sliderHeight*0.45, y: 0, width: sliderHeight/2, height: sliderHeight)
        slide.emojiText.text = getEmoji(streakCount: habit.streakCount)
        
        slide.streakLabel.frame = CGRect(x: slide.bounds.width - sliderHeight * 2.5, y: 0.6*sliderHeight, width: sliderHeight*2, height: sliderHeight/3)
        slide.totalCountLabel.frame = CGRect(x: sliderHeight/2, y: 0.6*sliderHeight, width: sliderHeight*2, height: sliderHeight/3)
        
        if (habit.doneToday == true) {
            DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1){
                slide.updateThumbnailXPosition(slide.xEndingPoint)
                slide.isFinished = true
                slide.totalCountLabel.alpha = 1
                slide.sliderTextLabel.alpha = 1
            }
        }
        
        var didInsert = false
        for i in 0..<sliders.count {
            if sliders[i].habit == habit {
                sliders.remove(at: i)
                sliders.insert(slide, at: i)
                didInsert = true
                break
            }
        }
        if !didInsert { sliders.append(slide) }
        
        return slide
    }
    

    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        if (sender.hapticsEnabled == true) {
            let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
        }
        var soundsEnabled = true
        if (UserDefaults.standard.object(forKey: "FINALE_DEV_APP_sounds") != nil) {
            soundsEnabled = UserDefaults.standard.bool(forKey: "FINALE_DEV_APP_sounds")
        }
        if (soundsEnabled) {
            GSAudio.sharedInstance.playSound(soundFileName: "tickSound")
        }
        
        for x in 0..<habits.count {
            if (habits[x] == sender.habit) {
                habits[x].count += 1
                if (!habits[x].doneToday) {
                    habits[x].streakCount += 1
                }
                habits[x].doneToday = true
                habits[x].lastDone = Date.today 
                sender.habit = habits[x]
                
                if (habits[x].count >= 3) {
                    SKStoreReviewController.requestReview()
                }
                break
            }
        }
        for x in 0..<sliders.count {
            if (sliders[x] == sender) {
                sliders[x].totalCountText.text = String(sender.habit.count)
                sliders[x].streakCountText.text = String(sender.habit.streakCount)
                sliders[x].emojiText.text = getEmoji(streakCount: sender.habit.streakCount)
                break
            }
        }
        saveHabits()
        PlayConfetti()
        
        Analytics.logEvent("habit_done", parameters: ["habit_total_count" : sender.habit.count, "habit_streak_count" : sender.habit.streakCount])
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
    
    @IBAction func newButton(_ sender: Any) {
        let slideVC = AddHabitView()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        slideVC.delegate = self
        slideVC.isEditingHabit = false
        self.present(slideVC, animated: true, completion: nil)
        
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func resetHabit (index: Int) {
        if (habits[index].doneToday == false) {
            return
        }
        
        for i in 0..<sliders.count {
            if (sliders[i].habit == habits[index]) {
                sliders[i].resetStateWithAnimation(true)
                habits[index].doneToday = false
                habits[index].count -= 1
                if (habits[index].streakCount > 0) {
                    habits[index].streakCount -= 1
                }
                sliders[i].streakCountText.text = String(habits[index].streakCount)
                sliders[i].emojiText.text = getEmoji(streakCount: habits[index].streakCount)
                sliders[i].totalCountText.text = String(habits[index].count)
                sliders[i].habit = habits[index]
                saveHabits()
                break
            }
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    func fixHabitNumbers (habitIndex: Int, totalDays: Int, streakCount: Int) {
        habits[habitIndex].count = totalDays
        habits[habitIndex].streakCount = streakCount
        sliders.removeAll()
        tableView.reloadData()
        saveHabits()
    }
    func removeHabit (index: Int) {
        let name = String(habits[index].name)
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                if(request.identifier == name) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [name])
                    print(request)
                }
            }
        })
        
        UISelectionFeedbackGenerator().selectionChanged()
        
        self.habits.remove(at: index)
        self.sliders.removeAll()
        self.tableView.reloadData()
        self.saveHabits()
        
        Analytics.logEvent("habit_removed", parameters: nil)
    }
    func openEditHabit (index: Int) {
        let slideVC = AddHabitView()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        slideVC.delegate = self
        slideVC.isEditingHabit = true
        slideVC.editingHabit = habits[index]
        slideVC.editHabitIndex = index
        self.present(slideVC, animated: true, completion: nil)
        
        UISelectionFeedbackGenerator().selectionChanged()
    }
    func editHabit (habitIndex: Int, name: String, color: String, icon: String, notificationTime: String) {
        habits[habitIndex].name = name
        habits[habitIndex].color = color
        habits[habitIndex].icon = icon
        habits[habitIndex].notificationTime = notificationTime
        sliders.removeAll()
        tableView.reloadData()
        saveHabits()
        
        Analytics.logEvent("habit_edited", parameters: ["habit_name" : name, "habit_color" : color, "habit_icon" : icon, "habit_notification_time" : notificationTime])
    }
    func addHabit(name: String, color: String, icon: String, notificationTime: String) {
        let newHabit = Habit(name: name, color: color, icon: icon, count: 0, streakCount: 0, doneToday: false, lastDone: Date.today, notificationTime: notificationTime)
        habits.append(newHabit)
        
        sliders.removeAll()
        tableView.reloadData()
        
        saveHabits()
        
        Analytics.logEvent("habit_added", parameters: ["habit_name" : name, "habit_color" : color, "habit_icon" : icon, "habit_notification_time" : notificationTime])
    }
    
    func saveHabits (updateWatch: Bool = true) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(habits), forKey:"FINALE_DEV_APP_savedHabits")
        
        if (updateWatch) {
            //watch_updateTable() WATCH
        }
    }
    func loadHabits () {
        if let data = UserDefaults.standard.value(forKey:"FINALE_DEV_APP_savedHabits") as? Data {
            let loadedHabits = try? PropertyListDecoder().decode(Array<Habit>.self, from: data)
            habits = loadedHabits ?? [Habit]()
        }
    }
    
    var currentRed: CGFloat = 0
    var currentGreen: CGFloat = 0
    var currentBlue: CGFloat = 0
    func startColorLerp () {
        let colorComponents = UIColor(named: "app.background")!.components
        currentRed = CGFloat(colorComponents.red) * 255.0
        currentGreen = CGFloat(colorComponents.green) * 255.0
        currentBlue = CGFloat(colorComponents.blue) * 255.0
    }
    func lerpBackgroundColor(progress: CGFloat, habit: Habit) {
        let futureColor = UIColor(named: habit.color + ".main")!.components
        let futureRed = CGFloat(futureColor.red ) * 255.0
        let futureGreen = CGFloat(futureColor.green ) * 255.0
        let futureBlue = CGFloat(futureColor.blue ) * 255.0
        
        let newRed = (1.0 - progress) * currentRed   + progress * futureRed;
        let newGreen = (1.0 - progress) * currentGreen + progress * futureGreen;
        let newBlue = (1.0 - progress) * currentBlue  + progress * futureBlue;
        
        let newColor: UIColor = UIColor(red: newRed/255, green: newGreen/255, blue: newBlue/255, alpha: 1.0)
        self.view.backgroundColor = newColor
    }
    func resetBackgroundColor(sender: MTSlideToOpenView, progress: CGFloat, habit: Habit, done: Bool, showLabel: Bool) {
        if (done == true) {
            let currectColor = self.view.backgroundColor
            self.view.backgroundColor = UIColor(named: "app.background")!
            DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.2) {
                self.view.backgroundColor = currectColor
            }
            DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 1) {
                self.resetBackgroundColor(sender: sender, progress: progress, habit: habit, done: false, showLabel: showLabel)
            }
            return
        }
        var reduceVar: CGFloat = progress
        let velocity = progress/20
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            
            reduceVar -= velocity
            self.lerpBackgroundColor(progress: reduceVar, habit: habit)
            
            if (showLabel == true) {
                sender.sliderTextLabel.alpha = 1 - reduceVar
            } else {
                sender.totalCountLabel.alpha = reduceVar
            }
            
            if reduceVar <= 0 {
                timer.invalidate()
                self.view.backgroundColor = UIColor(named: "app.background")
            }
        }
    }
    
    func checkDate () {
        if (lastDay != Date().dayNumberOfWeek(timeOffset: timeOffset)) {
            for x in 0..<habits.count {
                let slider = getSlider(habit: habits[x])
                
                if (habits[x].doneToday == true) {
                    slider?.resetStateWithAnimation(true)
                    habits[x].doneToday = false
                    slider?.habit = habits[x]
                }
                if (Calendar.current.isDateInYesterday(habits[x].lastDone) != true && Calendar.current.isDateInToday(habits[x].lastDone) != true && Calendar.current.isDateInTomorrow(habits[x].lastDone) != true) {
                    for i in 0..<sliders.count {
                        if (sliders[i].habit == habits[x]) {
                            sliders[i].streakCountText.text = "0"
                            sliders[i].emojiText.text = getEmoji(streakCount: 0)
                            habits[x].streakCount = 0
                            sliders[i].habit = habits[x]
                            break
                        }
                    }
                }
            }
            lastDay = Date().dayNumberOfWeek(timeOffset: timeOffset)
            // watch_updateLastDay() WATCH
            UserDefaults.standard.set(lastDay, forKey: "FINALE_DEV_APP_lastDay")
            saveHabits()
        }
    }
    
    func getSlider(habit: Habit) -> MTSlideToOpenView? {
        for slider in sliders {
            if slider.habit == habit { return slider }
        }
        return nil
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
    
    @objc func openSettings (sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let slideVC = SettingsView()
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            slideVC.delegate = self
            self.present(slideVC, animated: true, completion: nil)
            
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    /*
    //MARK: Watch stuff
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }

    func watch_updateName () {
        do {
            try wcSession?.updateApplicationContext(["name" : nameTextField.text!])
        } catch {
            print(error)
        }
    }
    func watch_updateLastDay() {
        do {
            try wcSession?.updateApplicationContext(["lastDay" : lastDay])
        } catch {
            print(error)
        }
    }
    
    func watch_updateTable () {
        var habitsNames = [String]()
        var habitsIcons = [String]()
        var habitsCounts = [Int]()
        var habitsStreaks = [Int]()
        var habitsDoneTodays = [Bool]()
        var habitsLastDones = [Date]()
        
        for i in 0..<habits.count {
            habitsNames.append(habits[i].name)
            habitsIcons.append(habits[i].icon)
            habitsCounts.append(habits[i].count)
            habitsStreaks.append(habits[i].streakCount)
            habitsDoneTodays.append(habits[i].doneToday)
            habitsLastDones.append(habits[i].lastDone)
        }
        wcSession?.transferUserInfo(["habitsNames" : habitsNames])
        wcSession?.transferUserInfo(["habitsIcons" : habitsIcons])
        wcSession?.transferUserInfo(["habitsCounts" : habitsCounts])
        wcSession?.transferUserInfo(["habitsStreaks" : habitsStreaks])
        wcSession?.transferUserInfo(["habitsDoneTodays" : habitsDoneTodays])
        wcSession?.transferUserInfo(["habitsLastDones" : habitsLastDones])
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 10) {
            print(self.wcSession?.outstandingUserInfoTransfers)
        }
//        DispatchQueue.main.async {
//            do {
//                try self.wcSession?.updateApplicationContext(["habitsNames" : habitsNames])
//            } catch {
//                print(error)
//            }
//        }
//        DispatchQueue.main.async {
//            do {
//                try self.wcSession?.updateApplicationContext(["habitsIcons" : habitsIcons])
//            } catch {
//                print(error)
//            }
//        }
//        DispatchQueue.main.async {
//            do {
//                try self.wcSession?.updateApplicationContext(["habitsCounts" : habitsCounts])
//            } catch {
//                print(error)
//            }
//        }
//        DispatchQueue.main.async {
//            do {
//                try self.wcSession?.updateApplicationContext(["habitsStreaks" : habitsStreaks])
//            } catch {
//                print(error)
//            }
//        }
//        DispatchQueue.main.async {
//            do {
//                try self.wcSession?.updateApplicationContext(["habitsDoneTodays" : habitsDoneTodays])
//            } catch {
//                print(error)
//            }
//        }
//        DispatchQueue.main.async {
//            do {
//                try self.wcSession?.updateApplicationContext(["habitsLastDones" : habitsLastDones])
//            } catch {
//                print(error)
//            }
//        }
    } */
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (habits.count == 0) {
            suggestionLabel.alpha = 1
        } else {
            suggestionLabel.alpha = 0
        }
        return habits.count + 1
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = habits[sourceIndexPath.row]
        habits.remove(at: sourceIndexPath.row)
        habits.insert(itemToMove, at: destinationIndexPath.row)
        
        let sliderToMove = sliders[sourceIndexPath.row]
        sliders.remove(at: sourceIndexPath.row)
        sliders.insert(sliderToMove, at: destinationIndexPath.row)
    }
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (proposedDestinationIndexPath.row == habits.count) {
            return IndexPath(row: proposedDestinationIndexPath.row - 1, section: proposedDestinationIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //NOT USING THIS CAUSE MEMORY OVERLOADED FROM CREATING NEW SLIDERS EVERYTIME
        let cell = CustomTableCell();
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        if (indexPath.row != habits.count) { //Create empty row at the bottom to add space
            cell.contentView.addSubview(createNewSlider(habit: habits[indexPath.row]))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    @objc func stopEditingTable () {
        if (tableView.isEditing) {
            tableView.isEditing = false
            saveHabits()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.row == self.habits.count) {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let indexPath = configuration.identifier as! IndexPath
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let cell = tableView.cellForRow(at: indexPath)!
        let preview = cell.contentView.subviews.first ?? cell.contentView
        
        return UITargetedPreview(view: preview, parameters: parameters)
    }
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let indexPath = configuration.identifier as! IndexPath
        
        let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear

        let cell = tableView.cellForRow(at: indexPath)!
        let preview = cell.contentView.subviews.first ?? cell.contentView
        
        return UITargetedPreview(view: preview, parameters: parameters)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row == habits.count { //if its the last cell which is empty
            return nil
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { suggestedActions in
           /* let removeCancel = UIAction(title: "Cancel", image: UIImage(systemName: "xmark")) { action in }
            let removeConfirm = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.removeHabit(index: indexPath.row)
            }
            let remove = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [removeCancel, removeConfirm])
            */
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                let slideVC = deleteHabitConfirm(habitName: self.habits[indexPath.row].name, habitIndex: indexPath.row)
                slideVC.modalPresentationStyle = .custom
                slideVC.transitioningDelegate = self
                slideVC.delegate = self
                self.present(slideVC, animated: true, completion: nil)
            }
            
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { action in
                self.openEditHabit(index: indexPath.row)
            }
            let reset = UIAction(title: "Reset today", image: UIImage(systemName: "arrow.counterclockwise")) { action in
                self.resetHabit(index: indexPath.row)
            }
            let reorder = UIAction(title: "Reorder", image: UIImage(systemName: "arrow.up.arrow.down")) { action in
                self.tableView.isEditing = true
                UISelectionFeedbackGenerator().selectionChanged()
            }
            let cheat = UIAction(title: "Fix streak", image: UIImage(systemName: "slider.horizontal.3")) { action in
                let cheatVC = DEBUG_CHEAT(habitName: self.habits[indexPath.row].name, days: String(self.habits[indexPath.row].count), streaks: String(self.habits[indexPath.row].streakCount), habitIndex: indexPath.row)
                cheatVC.modalPresentationStyle = .overFullScreen
                cheatVC.modalTransitionStyle = .crossDissolve
                cheatVC.transitioningDelegate = self
                cheatVC.delegate = self
                self.present(cheatVC, animated: true, completion: nil)
            }


            var contextMenu = [UIAction]()
            if (self.habits[indexPath.row].doneToday) {
                contextMenu.append(reset)
            }
            contextMenu.append(reorder)
            contextMenu.append(edit)
            contextMenu.append(cheat)
            let nonDestructive = UIMenu(title: "", options: .displayInline, children: contextMenu)
            return UIMenu(title: "", children: [nonDestructive, delete])
        }
    } 
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        UserDefaults.standard.set(nameTextField.text, forKey: "FINALE_DEV_APP_displayName")
        UserDefaults.standard.set(hiText.font.pointSize, forKey: "FINALE_DEV_APP_displayNameFontSize")
        //watch_updateName()    WATCH
        
        Analytics.logEvent("app_username_set", parameters: ["app_username" : nameTextField.text])
        return false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        hiText.font = nameTextField.font
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField.selectedTextRange = nameTextField.textRange(from: nameTextField.endOfDocument, to: nameTextField.endOfDocument)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround () {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }
}

struct Habit: Codable, Equatable {
    var name: String
    var color: String
    var icon: String
    var count: Int
    var streakCount: Int
    var doneToday: Bool
    var lastDone: Date
    var notificationTime: String
}

extension Date {
    func dayNumberOfWeek(timeOffset: Int) -> Int {
        let dayAdjusted = Calendar.current.date(byAdding: .hour, value: -timeOffset, to: self) ?? self
        return Calendar.current.dateComponents([.weekday], from: dayAdjusted).weekday ?? 0
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

class CustomTableCell: UITableViewCell {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing {
            for view in subviews where view.description.contains("Reorder") {
                for case let subview as UIImageView in view.subviews {
                    subview.frame = subview.frame.offsetBy(dx: 10, dy: 0)
                }
            }
        }
    }
}

class deleteHabitConfirm: UIViewController {
    var displayTitle = UILabel()
    var subtext = UILabel()
    var cancelButton = UIButton()
    var deleteButton = UIButton()
    
    var habitIndex = Int()
    
    weak var delegate: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        view.addSubview(displayTitle)
        view.addSubview(subtext)
        view.addSubview(cancelButton)
        view.addSubview(deleteButton)
        
        displayTitle.translatesAutoresizingMaskIntoConstraints = false
        displayTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        displayTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        displayTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
        subtext.translatesAutoresizingMaskIntoConstraints = false
        subtext.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        subtext.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        subtext.topAnchor.constraint(equalTo: displayTitle.bottomAnchor, constant: 10).isActive = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: subtext.bottomAnchor, constant: 20).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: (view.bounds.width - 80)/2.3).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: (view.bounds.width - 80)/2.3/3.5).isActive = true
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: subtext.bottomAnchor, constant: 20).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: (view.bounds.width - 80)/2.3).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: (view.bounds.width - 80)/2.3/3.5).isActive = true
    }
    init(habitName: String, habitIndex: Int) {
        self.displayTitle.textAlignment = .center
        self.displayTitle.text = "Delete \"\(habitName)\"?"
        self.displayTitle.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        
        self.habitIndex = habitIndex
        
        super.init(nibName: nil, bundle: nil)
        
        subtext.text = "You will lose all your progress"
        subtext.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        subtext.textColor = .gray
        subtext.textAlignment = .center
        
        cancelButton.setTitle(" Cancel", for: .normal) //label space to move icon left
        cancelButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        cancelButton.backgroundColor = .systemTeal
        cancelButton.layer.cornerRadius = 10
        cancelButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        cancelButton.imageView?.contentMode = .scaleAspectFit
        cancelButton.tintColor = .white
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitleColor(.gray, for: .highlighted)
        
        deleteButton.setTitle(" Delete", for: .normal) //label space to move icon left
        deleteButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        deleteButton.addTarget(self, action: #selector(deleteHabit), for: .touchUpInside)
        deleteButton.backgroundColor = .red
        deleteButton.layer.cornerRadius = 10
        deleteButton.setImage(UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.tintColor = .white
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.setTitleColor(.gray, for: .highlighted)
        
        self.view.backgroundColor = UIColor(named: "app.background")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deleteHabit () {
        delegate?.removeHabit(index: habitIndex)
        self.dismiss(animated: true, completion: nil)
    }
    @objc func dismissView () {
        self.dismiss(animated: true, completion: nil)
    }
}
