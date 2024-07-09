import UIKit
import CoreLocation

class OpenViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var enterNameButton: UIButton!
    
    @IBOutlet weak var startGameButton: UIButton!
    
    @IBOutlet weak var eastImageView: UIImageView!
    
    @IBOutlet weak var westImageView: UIImageView!
    
    let defaults = UserDefaults.standard
    var locationManager: CLLocationManager!
    var userName: String? {
        didSet {
            updateUI()
        }
    }
    var userLocation: CLLocation? {
        didSet {
            updateUI()
        }
    }
    var isEast: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startGameButton.isHidden = true
        userName = defaults.string(forKey: "username")
        setupLocationManager()
        updateUI()
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            isEast = location.coordinate.latitude > 34.817549168324334
            locationManager.stopUpdatingLocation()
        }
    }
    
    func updateUI() {
        if let name = userName {
            greetingLabel.text = "Hello, \(name)!"
            enterNameButton.isHidden = true
        } else {
            greetingLabel.text = "Please enter your name"
            enterNameButton.isHidden = false
        }
        
        if let location = userLocation {
            if location.coordinate.latitude > 34.817549168324334 {
                eastImageView.isHidden = false
                westImageView.isHidden = true
            } else {
                eastImageView.isHidden = true
                westImageView.isHidden = false
            }
        }
        
        startGameButton.isHidden = userName == nil || userLocation == nil
    }
    
    @IBAction func insertNameTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Enter Name", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter your name"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in
            guard let textField = alertController?.textFields?.first, let name = textField.text else { return }
            self?.defaults.set(name, forKey: "username")
            self?.userName = name
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startGameTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showGame", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGame" {
            if let gameVC = segue.destination as? ViewController {
                gameVC.playerName = userName
                gameVC.isEast = isEast
            }
        }
    }
}
