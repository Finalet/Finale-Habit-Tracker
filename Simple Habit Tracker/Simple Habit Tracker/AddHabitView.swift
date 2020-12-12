import UIKit

class AddHabitView: UIViewController, UITextFieldDelegate {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var editingHabit: Habit = Habit(name: "", color: "", count: 0, streakCount: 0, doneToday: false, lastDone: Calendar.current.component(.minute, from: Date()));
    var isEditingHabit = false
    var editHabitIndex = 0
    
    @IBOutlet weak var slideIndicator: UIView!
    @IBOutlet weak var nameInputField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var pageDots: UIPageControl!
    
    weak var delegate: AddHabitDelegate?
    
    var allColorButtons = [UIButton]()
    
    var currentSelectedColor: String = ""
    
    let colors = ["lightgreen", "lightpurple", "green", "purple", "yellow", "deeppurple", "orange", "bluepurple", "darkorange", "blue", "lightred", "lightblue", "red", "cyan", "pastel.lightgreen", "pastel.pink", "pastel.green", "pastel.lightpurple", "pastel.darkgreen", "pastel.purple", "pastel.yellow", "pastel.darkpurple", "pastel.orange", "pastel.lightblue", "pastel.darkorange", "pastel.blue", "pastel.red", "pastel.darkblue", "dark.darkgreen", "dark.purple", "dark.green", "dark.darkpurple", "dark.yellowgreen", "dark.bluepurple", "dark.darkyellow", "dark.trueblue", "dark.brown", "dark.darkblue", "dark.darkbrown", "dark.bluegreen", "dark.darkred", "dark.lakegreen"]
    
    
    
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
            createButton.alpha = 1
            
            if (editingHabit.color.contains("pastel.")) {
                DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1){
                    self.colorCollectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .left, animated: false)
                }
            } else if (editingHabit.color.contains("dark.")) {
                DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1){
                    self.colorCollectionView.scrollToItem(at: IndexPath(item: 0, section: 2), at: .left, animated: false)
                }
            }
        } else {
            viewTitle.text = "New Habit"
            nameInputField.text = ""
            createButton.setTitle("Create", for: .normal)
            createButton.isUserInteractionEnabled = false
            createButton.alpha = 0.5
        }

        self.hideKeyboardWhenTappedAround()
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
            createButton.alpha = 1.0
        } else {
            createButton.isUserInteractionEnabled = false
            createButton.alpha = 0.5
        }
        return true
    }
    func checkCompletion() {
        if nameInputField.text!.isEmpty || currentSelectedColor == "" {
            createButton.isUserInteractionEnabled = false
            createButton.alpha = 0.5
        } else {
            createButton.isUserInteractionEnabled = true
            createButton.alpha = 1.0
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

extension AddHabitView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count/3
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (colorCollectionView.bounds.width - 40) / 9, height: (colorCollectionView.bounds.width - 40) / 9)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageDots.currentPage = indexPath.section
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let cellSize = (colorCollectionView.bounds.width - 40) / 9
        return (colorCollectionView.bounds.width - 40 - cellSize * 7)/6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) //as colorCell
        
        cell.backgroundColor = UIColor.clear
        cell.layer.cornerRadius = cell.frame.height / 2
        
        var color = ""
        if indexPath.section == 0 {
            color = colors[indexPath.row]
        } else if indexPath.section == 1 {
            color = colors[indexPath.row + colors.count/3]
        } else if indexPath.section == 2 {
            color = colors[indexPath.row + 2 * colors.count/3]
        }
        
        let button: HorizontalSplitButton = HorizontalSplitButton(type: UIButton.ButtonType.custom)
        button.frame.size = cell.frame.size
        button.addTarget(self, action: #selector(pickColor), for: .touchUpInside)
        button.layer.cornerRadius = cell.frame.height / 2
        button.accessibilityLabel = color
        button.leftColor = UIColor(named: color + ".main")!
        button.rightColor = UIColor(named: color + ".secondary")!
        
        cell.addSubview(button)
        allColorButtons.append(button)
        
        if isEditingHabit {
            if editingHabit.color == color {
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
        self.view.endEditing(true)
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
