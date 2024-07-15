import UIKit

class EndViewController: UIViewController {
    @IBOutlet weak var menu_BTN: UIButton!
    @IBOutlet weak var winnerLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var winner: String?
    var winnerScore: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let winner = winner, let winnerScore = winnerScore {
            winnerLabel.text = "Winner: \(winner)"
            scoreLabel.text = "Score: \(winnerScore)"
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
