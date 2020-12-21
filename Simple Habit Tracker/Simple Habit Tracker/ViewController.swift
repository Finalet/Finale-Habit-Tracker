//
//  ViewController.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 02.12.2020.
//

import UIKit
import Foundation

class ViewController: UIViewController, MTSlideToOpenDelegate, MTSlideToOpenSwiftDelegate, AddHabitDelegate {

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
    @IBOutlet weak var suggestionLabel1: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTable()
        initializedAddButton()
        initializeTitle()

        self.hideKeyboardWhenTappedAround()
        let holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(openSettings))
        view.addGestureRecognizer(holdRecognizer)
        
        lastDay = UserDefaults.standard.integer(forKey: "lastDay")
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.checkDate()
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
        
        hiText.font = nameTextField.font?.withSize(CGFloat(UserDefaults.standard.float(forKey: "displayNameFontSize")))
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1){
            self.nameTextField.text = UserDefaults.standard.string(forKey: "displayName") ?? ""
        }
    }
    func createNewSlider(habit: Habit) -> MTSlideToOpenView {
        let slide = MTSlideToOpenView(frame: CGRect(x: 20, y: slidersGap/2, width: UIScreen.main.bounds.width - 80, height: sliderHeight))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = sliderHeight/2
        slide.thumbnailViewTopDistance = 4
        slide.thumbnailViewStartingDistance = 4
        slide.thumnailImageView.backgroundColor  = .clear
        slide.backgroundColor = UIColor.clear
        slide.delegate = self
        slide.swiftDelegate = self
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
        
        sliders.append(slide)
        
        return slide
    }
    

    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        if (sender.hapticsEnabled == true) {
            let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
        }
        
        for x in 0..<habits.count {
            if (habits[x] == sender.habit) {
                habits[x].count += 1
                if (!habits[x].doneToday) {
                    habits[x].streakCount += 1
                }
                habits[x].doneToday = true
                //habits[x].lastDone = Calendar.current.component(.minute, from: Date())
                habits[x].lastDone = Date.today 
                sender.habit = habits[x]
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
        
    }
    func moveUp (index: Int) {
        let habitToMove = habits[index]
        habits.remove(at: index)
        habits.insert(habitToMove, at: index-1)
        tableView.reloadData()
        saveHabits()
    }
    func moveDown (index: Int) {
        let habitToMove = habits[index]
        habits.remove(at: index)
        habits.insert(habitToMove, at: index+1)
        tableView.reloadData()
        saveHabits()
    }
    func removeHabit (index: Int) {
        habits.remove(at: index)
        sliders.removeAll()
        tableView.reloadData()
        
        saveHabits()
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
    func editHabit (habitIndex: Int, name: String, color: String, icon: String) {
        habits[habitIndex].name = name
        habits[habitIndex].color = color
        habits[habitIndex].icon = icon
        sliders.removeAll()
        tableView.reloadData()
        saveHabits()
    }
    func addHabit(name: String, color: String, icon: String) {
        let newHabit = Habit(name: name, color: color, icon: icon, count: 0, streakCount: 0, doneToday: false, lastDone: Date.today)
        //let newHabit = Habit(name: name, color: color, icon: icon, count: 0, streakCount: 0, doneToday: false, lastDone: Calendar.current.component(.minute, from: Date()))
        habits.append(newHabit)
        
        sliders.removeAll()
        tableView.reloadData()
        
        saveHabits()
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
            }
        }
    }
    
    func checkDate () {
        if (lastDay != Date().dayNumberOfWeek()) {
        //if (lastDay != Calendar.current.component(.minute, from: Date())) {
            for x in 0..<habits.count {
                if (habits[x].doneToday == true) {
                    sliders[x].resetStateWithAnimation(true)
                    habits[x].doneToday = false
                    sliders[x].habit = habits[x]
                }
                if (habits[x].lastDone != Date.yesterday && habits[x].lastDone != Date.today) {
                //if (habits[x].lastDone != Calendar.current.component(.minute, from: Date()) - 1 && habits[x].lastDone != Calendar.current.component(.minute, from: Date())) {
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
            lastDay = Date().dayNumberOfWeek()!
            //lastDay = Calendar.current.component(.minute, from: Date())
            UserDefaults.standard.set(lastDay, forKey: "lastDay")
            saveHabits()
        }
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
            self.present(slideVC, animated: true, completion: nil)
            
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
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
        //print("cell tapped")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (habits.count == 0) {
            suggestionLabel.alpha = 1
            suggestionLabel1.alpha = 1
        } else {
            suggestionLabel.alpha = 0
            suggestionLabel1.alpha = 0
        }
        return habits.count + 1
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = habits[sourceIndexPath.row]
        habits.remove(at: sourceIndexPath.row)
        habits.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //NOT USING THIS CAUSE MEMORY OVERLOADED FROM CREATING NEW SLIDERS EVERYTIME
        let cell = UITableViewCell();
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        if (indexPath.row != habits.count) { //Create empty row at the bottom to add space
            cell.contentView.addSubview(createNewSlider(habit: habits[indexPath.row]))
        }
        return cell
    }
    
    func saveHabits () {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(habits), forKey:"savedHabits")
    }
    func loadHabits () {
        if let data = UserDefaults.standard.value(forKey:"savedHabits") as? Data {
            let loadedHabits = try? PropertyListDecoder().decode(Array<Habit>.self, from: data)
            habits = loadedHabits ?? [Habit]()
        }
    }
    
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row == habits.count { //if its the last cell which is empty
            return nil
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let removeCancel = UIAction(title: "Cancel", image: UIImage(systemName: "xmark")) { action in }
            let removeConfirm = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.removeHabit(index: indexPath.row)
            }
            let remove = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [removeCancel, removeConfirm])
            
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { action in
                self.openEditHabit(index: indexPath.row)
            }
            let reset = UIAction(title: "Reset today", image: UIImage(systemName: "arrow.counterclockwise")) { action in
                self.resetHabit(index: indexPath.row)
            }
            let moveUp = UIAction(title: "Move up", image: UIImage(systemName: "arrow.up.circle")) { action in
                self.moveUp(index: indexPath.row)
            }
            let moveDown = UIAction(title: "Move down", image: UIImage(systemName: "arrow.down.circle")) { action in
                self.moveDown(index: indexPath.row)
            }

            var contextMenu = [UIAction]()
            if (self.habits[indexPath.row].doneToday) {
                contextMenu.append(reset)
            }
            if (indexPath.row != 0) {
                contextMenu.append(moveUp)
            }
            if (indexPath.row != self.habits.count - 1) {
                contextMenu.append(moveDown)
            }
            contextMenu.append(edit)
            let nonDestructive = UIMenu(title: "", options: .displayInline, children: contextMenu)

            return UIMenu(title: "", children: [nonDestructive, remove])
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
        UserDefaults.standard.set(nameTextField.text, forKey: "displayName")
        UserDefaults.standard.set(hiText.font.pointSize, forKey: "displayNameFontSize")
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
    //var lastDone: Int
    var lastDone: Date

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
