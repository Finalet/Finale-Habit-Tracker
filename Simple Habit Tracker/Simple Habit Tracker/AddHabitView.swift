import UIKit

class AddHabitView: UIViewController, UITextFieldDelegate {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var editingHabit = false
    var editingHabitName = ""
    var editHabitIndex = 0
    
    @IBOutlet weak var slideIndicator: UIView!
    @IBOutlet weak var nameInputField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var viewTitle: UILabel!
    
    weak var delegate: AddHabitDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        slideIndicator.roundCorners(.allCorners, radius: 10)
        createButton.roundCorners(.allCorners, radius: 10)
        
        self.nameInputField.delegate = self
        
        if (editingHabit) {
            viewTitle.text = "Edit Habit"
            nameInputField.text = editingHabitName
            createButton.setTitle("Confirm", for: .normal)
        } else {
            viewTitle.text = "New Habit"
            nameInputField.text = ""
            createButton.setTitle("Create", for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @IBAction func createHabitButton(_ sender: Any) {
        var name: String
        if (nameInputField.text == "") {
            name = "New Habit"
        } else {
            name = String(nameInputField.text ?? "New Habit")
        }
        if (!editingHabit) {
            delegate?.addHabit(name: name)
        } else {
            delegate?.editHabit(habitIndex: editHabitIndex, name: name)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}

protocol AddHabitDelegate: class {
    func addHabit(name: String)
    func editHabit(habitIndex: Int, name: String)
}
