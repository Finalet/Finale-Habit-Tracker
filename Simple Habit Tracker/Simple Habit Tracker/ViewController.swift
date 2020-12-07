//
//  ViewController.swift
//  Simple Habit Tracker
//
//  Created by Grant Oganyan on 02.12.2020.
//

import UIKit
import Foundation

class ViewController: UIViewController, MTSlideToOpenDelegate {

    @IBOutlet weak var addButtonUI: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var sliders = [MTSlideToOpenView]()
    
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
        
        let numberOfHabits = UserDefaults.standard.integer(forKey: "numberOfHabits")
        if numberOfHabits == 0 {
            return
        }
        for n in 1...numberOfHabits {
            addSlider(habitName: "Running1")
        }
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
        slide.delegate = self
        slide.labelText = "Slide to record " + name
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
        UISelectionFeedbackGenerator().selectionChanged()
        addSlider(habitName: "Running")
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell tapped")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sliders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let newSlider = sliders[indexPath.row]
        cell.contentView.addSubview(newSlider)
        
        return cell
    }
    
    func addSlider (habitName: String) {
        sliders.append(createNewSlider(name: habitName))
        
        tableView.reloadData()
        UserDefaults.standard.set(sliders.count, forKey: "numberOfHabits")
    }
}
