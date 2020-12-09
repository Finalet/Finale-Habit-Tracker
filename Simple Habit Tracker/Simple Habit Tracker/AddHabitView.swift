import UIKit

class AddHabitView: UIViewController, UITextFieldDelegate {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var editingHabit: Habit = Habit(name: "", color: "");
    var isEditingHabit = false
    var editHabitIndex = 0
    
    @IBOutlet weak var slideIndicator: UIView!
    @IBOutlet weak var nameInputField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    weak var delegate: AddHabitDelegate?
    
    var allColorButtons = [UIButton]()
    
    var currentSelectedColor: String = ""
    
    let colors = ["green", "lightgreen", "yellow", "orange", "darkorange", "lightred", "red", "lightpurple", "purple", "deeppurple", "bluepurple", "blue", "lightblue", "cyan"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        slideIndicator.roundCorners(.allCorners, radius: 10)
        createButton.layer.cornerRadius = 10
        
        
        let nibName = UINib(nibName: "ColorViewCell", bundle: nil)
        colorCollectionView.register(nibName, forCellWithReuseIdentifier: "colorCell")
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        self.nameInputField.delegate = self
        
        if (isEditingHabit) {
            viewTitle.text = "Edit Habit"
            nameInputField.text = editingHabit.name
            createButton.setTitle("Confirm", for: .normal)
            createButton.isUserInteractionEnabled = true
            createButton.titleLabel?.alpha = 1
        } else {
            viewTitle.text = "New Habit"
            nameInputField.text = ""
            createButton.setTitle("Create", for: .normal)
            createButton.isUserInteractionEnabled = false
            createButton.titleLabel?.alpha = 0.5
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
        if (!isEditingHabit) {
            delegate?.addHabit(name: name, color: currentSelectedColor)
        } else {
            delegate?.editHabit(habitIndex: editHabitIndex, name: name, color: currentSelectedColor)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        if !text.isEmpty && currentSelectedColor != "" {
            createButton.isUserInteractionEnabled = true
            createButton.titleLabel?.alpha = 1.0
        } else {
            createButton.isUserInteractionEnabled = false
            createButton.titleLabel?.alpha = 0.5
        }
        return true
    }
    func checkCompletion() {
        if nameInputField.text!.isEmpty || currentSelectedColor == "" {
            createButton.isUserInteractionEnabled = false
            createButton.titleLabel?.alpha = 0.5
        } else {
            createButton.isUserInteractionEnabled = true
            createButton.titleLabel?.alpha = 1.0
        }
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

extension AddHabitView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) //as colorCell
        
        cell.backgroundColor = UIColor.gray
        cell.layer.cornerRadius = cell.frame.height / 2
        
        let button: HorizontalSplitButton = HorizontalSplitButton(type: UIButton.ButtonType.custom)
        button.frame.size = cell.frame.size
        button.addTarget(self, action: #selector(pickColor), for: .touchUpInside)
        button.leftColor = UIColor(named: colors[indexPath.row] + ".main")!
        button.rightColor = UIColor(named: colors[indexPath.row] + ".secondary")!
        button.layer.cornerRadius = cell.frame.height / 2
        button.accessibilityLabel = colors[indexPath.row]
        cell.addSubview(button)
        
        allColorButtons.append(button)
        
        if isEditingHabit {
            if editingHabit.color == colors[indexPath.row] {
                pickColor(sender: button)
            }
        }
        
        
        return cell
    }
    
    @objc func pickColor (sender: UIButton) {
        for button in allColorButtons {
            button.layer.borderWidth = 0
        }
        
        currentSelectedColor = sender.accessibilityLabel ?? "green"
        sender.layer.borderWidth = 3
        sender.layer.borderColor = UIColor(named: "app.selection")?.cgColor
        
        checkCompletion()
    }
}

protocol AddHabitDelegate: class {
    func addHabit(name: String, color: String)
    func editHabit(habitIndex: Int, name: String, color: String)
}

class HorizontalSplitButton: UIButton {
    var leftColor: UIColor = UIColor.systemGray
    var rightColor: UIColor = UIColor.systemGray2
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let topRect = CGRect(x: 0, y: 0, width: rect.size.width/2, height: rect.size.height)
        leftColor.set()
        guard let topContext = UIGraphicsGetCurrentContext() else { return }
        topContext.fill(topRect)

        let bottomRect = CGRect(x: rect.size.width/2, y: 0, width: rect.size.width/2, height: rect.size.height)
        rightColor.set()
        guard let bottomContext = UIGraphicsGetCurrentContext() else { return }
        bottomContext.fill(bottomRect)
    }
}
