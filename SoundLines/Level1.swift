//
//  Level1.swift
//  SoundLines
//
//  Created by simona1971 on 25/06/19.
//  Copyright © 2019 Comelicode. All rights reserved.
//
// Level1: creates two elements, then a line between them, and detects if
// the user pans inside the line

import UIKit
import AudioKit

class Level1: UIViewController {
    
    // AudioKit setup and start
    
    var oscillator = AKFMOscillator()
    var oscillator2 = AKOscillator()
    var panner = AKPanner()
    
    var catSound: AKAudioPlayer!
    var kittenSound: AKAudioPlayer!
    
    // Variables
    
    @IBOutlet var cat: UIImageView!
    @IBOutlet var kitten: UIImageView!
    @IBOutlet var redLine: UIImageView!
    
    var gameStarted: Bool = false
    var levelComplete: Bool = false

    var catShown: Bool = false
    var startedFromKitten: Bool = false
    
    var kittenFound = 0
    var catFound = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.navigationController?.navigationBar.isHidden = true;
        
        // Inizialization of AudioKit elements: cat and kitten sounds, oscillators
        
        setAudioKitElements()
        
        // Sets positions and dimensions of view elements

        setViewElements()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            try! AudioKit.stop()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Tell the user to find the cat
        
        if gameStarted == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                UIAccessibility.post(notification: .announcement, argument: "Find the cat")
            })
        }
    }
    
    // The game is divided in 3 steps:
    // 1. The user finds elements: Find the cat -> Find the kitten -> Show the line -> Start game
    // 2. The user connects the kitten to the cat: Start from the kitten -> Follow the line -> Go to the          cat -> Level complete
    // 3. Level complete: redirect to the next screen
    
    // Detects panning on the shape and adds sonification based on the finger position
    
    @IBAction func panDetector(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        print("panDetector")
        
        // Saves the point touched by the user
        
        let initialPoint = gestureRecognizer.location(in: view)
        
        guard gestureRecognizer.view != nil else {return}
        
        // 1. The user finds elements: Find the cat - > Find the kitten -> Show the line -> Start game
        
        if gameStarted == false && levelComplete == false {
            
            // Find the cat: if the user position is inside the cat image, catShown becomes true and the kitten is shown
        
            if Utility.isInsideCat(cat: cat, point: initialPoint) {
                
                catFoundHandler()
                
            }
            
            // Find the kitten: if the cat has been found and shown and the user position is inside the kitten image, the line is shown and gameStarted becomes true
        
            if Utility.isInsideKitten(kitten: kitten, point: initialPoint) && catShown == true {
                
                kittenFoundHandler()
                
            }
        }
        
        // 2. The user connects the kitten to the cat: Start from the kitten -> Follow the line -> Go to the cat -> Level complete
        
        if gameStarted == true {
            
            // Start from the kitten: if the user movement starts from the kitten startedFromKitten becomes true
            
            if Utility.isInsideKitten(kitten: kitten, point: initialPoint) {
                
                startedFromKitten = true
            }
            
            if gestureRecognizer.state == .changed {
                print(initialPoint)
          
                // Distinguishes 3 cases based on the finger position:
                // 1. Inside the line but not in the center
                // 2. At the center of the line
                // 3. Outside the line
                
                // The finger is inside the line
                
                if (distPointLine(point: initialPoint) <= Double(redLine.frame.height / 2)){
                    print("OK: point is inside shape, dist:", distPointLine(point: initialPoint))
                    
                    if isBetweenCats(cat: cat, kitten: kitten, point: initialPoint) {
                        // 1. Inside the line but not in the center
                        
                        oscillator2.stop()
                        oscillator.baseFrequency = 300 + 10 * distPointLine(point: initialPoint)
                        oscillator.amplitude = 1
                        
                        oscillator.start()
                        
                        if Utility.isInsideKitten(kitten: kitten, point: initialPoint) {
                            oscillator.stop()
                            kittenSound.start()
                        } else if Utility.isInsideCat(cat: cat, point: initialPoint) {
                            oscillator.stop()
                            catSound.start()
                        }
                        
                        // 2. At the center of the line
                        
                        if (distPointLine(point: initialPoint) <= 5) {
                            print("Inside the middle line")
                            oscillator2.stop()
                            
                            panner.pan = Utility.normalizePannerValue(cat: cat, kitten: kitten, num: Double(initialPoint.x))
                            
                            oscillator.baseFrequency = 300
                        }
                        
                        if Utility.isInsideCat(cat: cat, point: initialPoint) {
                            
                            if startedFromKitten {
                                print("Last point is inside element")
                                oscillator.stop()
                                oscillator2.stop()
                                
                                gameStarted = false
                                
                                levelComplete = true
                                
                            } else {
                                print("Last point is outside element")
                                print("restart game")
                                UIAccessibility.post(notification: .announcement, argument: "Go back to the kitten and follow the line")
                            }
                        }
                    }
                    
                } else {
                    // 3. Outside the line
                    
                    print("NO: point is outside shape")
                    
                    panner.pan = 0.0
                    
                    oscillator.stop()
                    oscillator2.amplitude = 0.5
                    oscillator2.frequency = 200
                    oscillator2.start()
                    
                    startedFromKitten = false
                    
                    print("restart game")
                }
            }
            
            if gestureRecognizer.state == .ended {
                oscillator.stop()
                oscillator2.stop()
                print("Pan released")
                print("restart game")
                UIAccessibility.post(notification: .announcement, argument: "Touch released, go back to the kitten and follow the line")
                startedFromKitten = false
            }
        }
        
        if levelComplete == true {
            
            gestureRecognizer.isEnabled = false
            
            UIAccessibility.post(notification: .announcement, argument: "Well done! Level 1 completed")
            
            catSound.start()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                try! AudioKit.stop()

                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let level2Screen = storyBoard.instantiateViewController(withIdentifier: "Level2Screen")
                self.present(level2Screen, animated: true, completion: nil)
            })
        }
    }

    // FUNCTIONS
    
    // 1. ONLOAD FUNCTIONS
    
    // Inizialization of AudioKit elements: cat and kitten sounds, oscillators
    
    func setAudioKitElements() -> Void {
        
        print("setAudioKitElements")
        
        // Creates AudioKit mixer and panner: adds cat and kitten sound
        
        let catFile = try! AKAudioFile(readFileName: "cat.wav")
        let kittenFile = try! AKAudioFile(readFileName: "kitten.wav")
        
        catSound = try! AKAudioPlayer(file: catFile)
        kittenSound = try! AKAudioPlayer(file: kittenFile)
        
        let mixer = AKMixer(oscillator, oscillator2, catSound, kittenSound)
        
        panner = AKPanner(mixer, pan: 0.0)
        
        AudioKit.output = panner
        
        // Audio is played with silent mode as well
        
        AKSettings.playbackWhileMuted = true
        
        try! AudioKit.start()
    }
    
    // Sets positions and dimensions of view elements
    
    func setViewElements() -> Void {
        
        print("setViewElements")
        
        // Sets the width of the line image: 60% of screen width
        
        let frameWidth = view.frame.size.width * 0.6
        let aspectRatio = CGFloat(5.336)
        let frameHeight = frameWidth / aspectRatio
        
        redLine.frame = CGRect(x:0, y:0, width:frameWidth, height:frameHeight)
        
        // Sets dimensions of kitten and cat images
        
        kitten.frame = CGRect(x:0, y:0, width: frameHeight, height: frameHeight)
        cat.frame = CGRect(x:0, y:0, width: frameHeight, height: frameHeight)
        
        // Sets a frame for the images: the line image is centered horizontally and vertically
        // while kitten and cat are centered vertically and have some distance from the line image
        
        redLine.frame.origin.x = CGFloat(self.view.frame.size.width / 2 - self.redLine.frame.width / 2)
        redLine.frame.origin.y = CGFloat(self.view.frame.size.height / 2 - self.redLine.frame.height / 2)
        
        kitten.frame.origin.x = redLine.frame.minX - kitten.frame.size.width - 10.0
        kitten.frame.origin.y = CGFloat(self.view.frame.size.height / 2 - kitten.frame.size.height / 2)
        
        cat.frame.origin.x = redLine.frame.maxX + 10.0
        cat.frame.origin.y = CGFloat(self.view.frame.size.height / 2 - cat.frame.size.height / 2)
        
        // Hides the kitten label
        
        kitten.isHidden = true
        redLine.isHidden = true
    }
    
    // 2. GAME LOGIC FUNCTIONS
    
    func catFoundHandler() -> Void {
        
        print("findTheCat")
        
        // If it's the first time finding the cat, tell the user to find the kitten
        
        if catFound == 0 {
            UIAccessibility.post(notification: .announcement, argument: "You found the cat! Find the kitten")
        }
        
        // Counter for number of cat image touches
        
        catFound = catFound + 1
        
        // Play cat sound
        
        catSound.start()
        
        // Show the kitten
        
        kitten.isHidden = false
        
        // Set the variable: the cat has been found and shown
        
        catShown = true
    }
    
    func kittenFoundHandler() -> Void {
        
        print("findTheKitten")
        
        // If it's the first time finding the kitten, tell the user to follow the line
        
        if kittenFound == 0 {
            UIAccessibility.post(notification: .announcement, argument: "You found the kitten! Follow the line to connect the kitten to the cat")
        }
        
        // Counter for number of kitten image touches
        
        kittenFound = kittenFound + 1
        
        // Play kitten sound
        
        kittenSound.start()
        
        // After 2 seconds
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            
            // Show the line
            
            self.redLine.isHidden = false
            
            // Set the variable: the kitten has been found, the line has been shown and the game can start
            
            self.gameStarted = true
        })
    }
    
    
    // 3. UTILITY
    
    // Creates a virtual line based on an equation: returns distance from given point
    
    func distPointLine(point: CGPoint) -> Double {
        
        print("distPointLine")
        
        let a = Double(0)
        let b = Double(1)
        let c = Double(self.view.frame.size.height / 2)
        
        let den = sqrt(pow(a, 2) + pow(b, 2))
        
        return abs(a * Double(point.x) + b * Double(point.y) - c) / den
    }
    
    // Returns true if the given point is between the cat and kitten image
    
    func isBetweenCats(cat: UIImageView, kitten: UIImageView, point: CGPoint) -> Bool {
        
        print("isBetweenCats")
        
        let kittenMaxX = kitten.frame.minX
        let catMinX = cat.frame.maxX
        
        return point.x >= kittenMaxX && point.x <= catMinX
    }
}
