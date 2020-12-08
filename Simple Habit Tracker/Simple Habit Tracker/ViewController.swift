//
//  ViewController.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 02.12.2020.
//

import UIKit
import Foundation

class ViewController: UIViewController, MTSlideToOpenDelegate, AddHabitDelegate {

    @IBOutlet weak var addButtonUI: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var habits = [Habit]()
    
    let sliderHeight: CGFloat = 60.0
    let slidersGap: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTable()
        initializedAddButton()
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
        addButtonUI.layer.shadowRadius = 8
        addButtonUI.layer.shadowOpacity = 0.4
        addButtonUI.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func createNewSlider(name: String) -> MTSlideToOpenView {
        let slide = MTSlideToOpenView(frame: CGRect(x: 20, y: slidersGap/2, width: UIScreen.main.bounds.width - 80, height: sliderHeight))
        slide.sliderViewTopDistance = 0
        slide.sliderCornerRadius = sliderHeight/2
        slide.thumbnailViewTopDistance = 4
        slide.thumbnailViewStartingDistance = 4
        slide.thumnailImageView.backgroundColor  = UIColor(red:50/255, green:255/255, blue:50/255, alpha:1.0)
        slide.draggedView.backgroundColor = UIColor(red:50/255, green:230/255, blue:50/255, alpha:1.0)
        slide.sliderBackgroundColor = UIColor(red:90/255, green:200/255, blue:90/255, alpha:1.0)
        slide.backgroundColor = UIColor.clear
        slide.delegate = self
        slide.labelText = name
        slide.textLabel.textColor = .white

        
        /*
        slide.layer.shadowRadius = 5
        slide.layer.shadowOpacity = 0.4
        slide.layer.shadowOffset = CGSize(width: 0, height: 0) */
        return slide
    }
    

    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        sender.resetStateWithAnimation(false)
        
        let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        
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
        slideVC.editingHabit = false
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
        slideVC.editingHabit = true
        slideVC.editingHabitName = habits[index].name
        slideVC.editHabitIndex = index
        self.present(slideVC, animated: true, completion: nil)
        
        UISelectionFeedbackGenerator().selectionChanged()
    }
    func editHabit (habitIndex: Int, name: String) {
        habits[habitIndex].name = name
        tableView.reloadData()
        saveHabits()
    }
    func addHabit(name: String) {
        let newHabit = Habit(name: name)
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
    func lerpBackgroundColor(progress: CGFloat) {
        var newRed: CGFloat
        var newGreen: CGFloat
        var newBlue: CGFloat
        
        newRed   = (1.0 - progress) * currentRed   + progress * 50;
        newGreen = (1.0 - progress) * currentGreen + progress * 230;
        newBlue  = (1.0 - progress) * currentBlue  + progress * 50;
        
        let newColor: UIColor = UIColor(red: newRed/255, green: newGreen/255, blue: newBlue/255, alpha: 1.0)
        self.view.backgroundColor = newColor
    }
    func resetBackgroundColor(progress: CGFloat) {
        self.view.backgroundColor = UIColor.systemBackground
        var reduceVar: CGFloat = progress
        let velocity = progress/20
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            
            reduceVar -= velocity
            self.lerpBackgroundColor(progress: reduceVar)
            
            if reduceVar <= 0 {
                timer.invalidate()
            }
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
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = habits[sourceIndexPath.row]
        habits.remove(at: sourceIndexPath.row)
        habits.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let habit = habits[indexPath.row]
        let habitSlider = createNewSlider(name: habit.name)
        cell.backgroundColor = .clear
        cell.contentView.addSubview(habitSlider)
        
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

struct Habit: Codable {
    var name: String
}
