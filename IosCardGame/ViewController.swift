//
//  ViewController.swift
//  IosCardGame
//
//  Created by Student18 on 02/07/2024.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var westCard: UIImageView!
    
    @IBOutlet weak var eastCard: UIImageView!
    
    @IBOutlet weak var nameWest: UILabel!
    
    @IBOutlet weak var nameEast: UILabel!
    
    @IBOutlet weak var scoreEast: UILabel!
    
    @IBOutlet weak var scoreWest: UILabel!
    
    
    
    var eastScore = 0
        var westScore = 0
        var playCount = 0
        let totalPlays = 10
        var counter = 0
        var cardsVisible = false
        var playerName: String?
        var isEast: Bool?
        
        let cardImages = (2...14).map { "card\($0)" }
        var stepDetector: StepDetector?
        
        var tickSoundPlayer: AVAudioPlayer?

        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupAudioSession()
            
            // Display player's name and adjust UI based on location
            if let playerName = playerName, let isEast = isEast {
                if isEast {
                    nameEast.text = playerName
                    nameWest.text = "West Player"
                } else {
                    nameWest.text = playerName
                    nameEast.text = "East Player"
                }
            }
            
            resetGame()
            setupAudioPlayer()
        }
        
        func setupAudioSession() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set up audio session: \(error.localizedDescription)")
            }
        }
        
        func setupAudioPlayer() {
            guard let soundURL = Bundle.main.url(forResource: "tick", withExtension: "mp3") else {
                print("Tick sound file not found")
                return
            }

            do {
                tickSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                tickSoundPlayer?.prepareToPlay()
            } catch {
                print("Error loading and playing tick sound: \(error.localizedDescription)")
            }
        }

        func playTickSound() {
            tickSoundPlayer?.play()
        }
        
        func resetGame() {
            eastScore = 0
            westScore = 0
            playCount = 0
            counter = 0
            cardsVisible = false
            updateUI()
            startGameTimer()
        }
        
        func startGameTimer() {
            stepDetector = StepDetector(cb: self)
            stepDetector?.startSensors(steps: totalPlays)
        }
        
        func stopGameTimer() {
            stepDetector?.stopSensors()
        }
        
        func updateGameState() {
            playTickSound() // Add this line to play the tick sound

            counter += 1
            
            if cardsVisible && counter == 3 {
                // Hide cards after 3 seconds
                westCard.image = UIImage(named: "back")
                eastCard.image = UIImage(named: "back")
                cardsVisible = false
                counter = 0
            } else if !cardsVisible && counter == 2 {
                // Show new cards after 2 seconds of hiding
                if playCount >= totalPlays {
                    stopGameTimer()
                    determineWinner()
                    return
                }
                
                let eastCardIndex = Int.random(in: 0..<cardImages.count)
                let westCardIndex = Int.random(in: 0..<cardImages.count)
                
                let eastCardImage = cardImages[eastCardIndex]
                let westCardImage = cardImages[westCardIndex]
                
                eastCard.image = UIImage(named: eastCardImage)
                westCard.image = UIImage(named: westCardImage)
                
                updateScores(eastCardIndex: eastCardIndex, westCardIndex: westCardIndex)
                playCount += 1
                
                cardsVisible = true
                counter = 0
            }
        }
        
        func updateScores(eastCardIndex: Int, westCardIndex: Int) {
            if eastCardIndex > westCardIndex {
                eastScore += 1
            } else if eastCardIndex < westCardIndex {
                westScore += 1
            }
            updateUI()
        }
        
        func updateUI() {
            scoreEast.text = "\(eastScore)"
            scoreWest.text = "\(westScore)"
        }
        
        func determineWinner() {
            let winner: String
            let winnerScore: Int
            
            // Home player wins in case of a draw
            if eastScore == westScore {
                winner = playerName ?? "Home Player"
                winnerScore = eastScore
            } else if eastScore > westScore {
                winner = isEast == true ? playerName! : "East Player"
                winnerScore = eastScore
            } else {
                winner = isEast == false ? playerName! : "West Player"
                winnerScore = westScore
            }
            
            performSegue(withIdentifier: "showEnd", sender: (winner, winnerScore))
        }
        
        @IBAction func startClicked(_ sender: Any) {
            resetGame()
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showEnd" {
                if let endVC = segue.destination as? EndViewController,
                   let (winner, winnerScore) = sender as? (String, Int) {
                    endVC.winner = winner
                    endVC.winnerScore = winnerScore
                }
            }
        }
    }

    extension ViewController: CallBack_StepDetector {
        func step(counter: Int) {
            updateGameState()
        }
    }
