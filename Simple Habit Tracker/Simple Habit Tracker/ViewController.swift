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
    var motivationalPhrases = ["Ready to change your habits?", "A small move forward every day.", "Don't let 'later' become 'never'.", "Little things make big days.", "Habits change into character.", "Life is a succession of habits.", "Winning is a habit", "Out of routine comes inspiratoin.", "God habits are the key to success.", "Once you learn to win, it becomes a habit."]
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var hiText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTable()
        initializedAddButton()
        initializeTitle()

        self.hideKeyboardWhenTappedAround()
        
        lastDay = UserDefaults.standard.integer(forKey: "lastDay")
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
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
        slide.thumnailImageView.backgroundColor  = UIColor.white
        slide.backgroundColor = UIColor.clear
        slide.delegate = self
        slide.swiftDelegate = self
        slide.labelText = habit.name
        slide.textLabel.textColor = .white
        slide.showSliderText = true
        slide.sliderTextLabel.textColor = .white
        slide.habit = habit
        slide.sliderHolderView.layer.borderWidth = 3
        slide.sliderHolderView.layer.borderColor = UIColor.systemGray2.withAlphaComponent(0.5).cgColor
        slide.draggedView.backgroundColor = UIColor(named: habit.color + ".main")
        slide.sliderBackgroundColor = UIColor(named: habit.color + ".secondary")!
        
        slide.thumnailImageView.layer.shadowRadius = 4
        slide.thumnailImageView.layer.shadowOpacity = 0.3
        slide.thumnailImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        slide.counterText.frame = CGRect(x: slide.bounds.width - sliderHeight/2, y: 0, width: sliderHeight, height: sliderHeight)
        slide.counterText.text = String(habit.count)
        slide.counterText.textColor = .white
        
        
        if (habit.doneToday == true) {
            DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1){
                slide.updateThumbnailXPosition(slide.xEndingPoint)
                slide.isFinished = true
                slide.textLabel.alpha = 0
            }
        }
        
        sliders.append(slide)
        
        return slide
    }
    

    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        
        for x in 0..<habits.count {
            if (habits[x] == sender.habit) {
                habits[x].count += 1
                habits[x].doneToday = true
                sender.habit = habits[x]
                break
            }
        }
        for x in 0..<sliders.count {
            if (sliders[x] == sender) {
                sliders[x].counterText.text = String(sender.habit.count)
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
    
    func removeHabit (index: Int) {
        habits.remove(at: index)
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
    func editHabit (habitIndex: Int, name: String, color: String) {
        habits[habitIndex].name = name
        habits[habitIndex].color = color
        tableView.reloadData()
        saveHabits()
    }
    func addHabit(name: String, color: String, count: Int, doneToday: Bool) {
        let newHabit = Habit(name: name, color: color, count: count, doneToday: false)
        habits.append(newHabit)
        
        tableView.reloadData()
        
        saveHabits()
    }
    
    var currentRed: CGFloat = 0
    var currentGreen: CGFloat = 0
    var currentBlue: CGFloat = 0
    func startColorLerp () {
        let colorComponents = self.view.backgroundColor?.components
        currentRed = CGFloat(colorComponents?.red ?? 1) * 255.0
        currentGreen = CGFloat(colorComponents?.green ?? 1) * 255.0
        currentBlue = CGFloat(colorComponents?.blue ?? 1) * 255.0
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
    func resetBackgroundColor(progress: CGFloat, habit: Habit) {
        self.view.backgroundColor = UIColor.systemBackground
        var reduceVar: CGFloat = progress
        let velocity = progress/20
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            
            reduceVar -= velocity
            self.lerpBackgroundColor(progress: reduceVar, habit: habit)
            
            if reduceVar <= 0 {
                timer.invalidate()
            }
        }
    }
    
    func checkDate () {
        //if (lastDay != Date().dayNumberOfWeek()) {
        if (lastDay != Calendar.current.component(.minute, from: Date())) {
            
            print(habits[0])
            for x in 0..<habits.count {
                if (habits[x].doneToday == true) {
                    sliders[x].resetStateWithAnimation(true)
                    habits[x].doneToday = false
                    sliders[x].habit = habits[x]
                }
            }
            //lastDay = Date().dayNumberOfWeek()!
            lastDay = Calendar.current.component(.minute, from: Date())
            UserDefaults.standard.set(lastDay, forKey: "lastDay")
            saveHabits()
            print(habits[0])
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

            // Create an action for sharing
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.removeHabit(index: indexPath.row)
            }
            let rename = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { action in
                self.openEditHabit(index: indexPath.row)
            }
            // Create other actions...

            return UIMenu(title: "", children: [rename, delete])
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
    var count: Int
    var doneToday: Bool
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
