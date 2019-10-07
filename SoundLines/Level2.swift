//
//  Level2.swift
//  SoundLines
//
//

import UIKit
import AudioKit

class Level2: UIViewController {
    
    // AudioKit setup and start
    
    var oscillator = AKFMOscillator()
    var oscillator2 = AKOscillator()
    var panner = AKPanner()
    
    var catSound: AKAudioPlayer!
    var kittenSound: AKAudioPlayer!
    
    // Variables
    
    @IBOutlet var kitten: UIImageView!
    @IBOutlet var cat: UIImageView!
    @IBOutlet var redLine: UIImageView!
    
    var gameStarted: Bool = false
    var levelComplete: Bool = false
    
    var catShown: Bool = false
    var startedFromKitten: Bool = false
    
    var kittenFound = 0
    var catFound = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides back button and navigation bar
        
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
        
        // Every time the user touches the cat image, cat sound is played
        
        if Utility.isInsideCat(cat: cat, point: initialPoint) {
            
            playCatSound()
            
        }
        
        // Every time the user touches the kitten image, kitten sound is played
        
        if Utility.isInsideKitten(kitten: kitten, point: initialPoint) && kitten.isHidden == false {
            
            playKittenSound()
            
        }
        
        // Every time the user is outside cat, kitten or line images the outside the line oscillator starts, to let a VI user know the interface is working
        
        if Utility.isInsideKitten(kitten: kitten, point: initialPoint) == false && Utility.isInsideCat(cat: cat, point: initialPoint) == false && redLine.isHidden {
            
            startOutsideLineOscillator()
            
            // If the finger is not touching the screen stops the oscillator
            
            if gestureRecognizer.state == .ended {
                
                oscillator2.stop()
                
            }
        }
        
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
            
            // PanDetector state: changed. The finger has moved.
            
            if gestureRecognizer.state == .changed {
                
                // Distinguishes 3 cases based on the finger position:
                // 1. Inside the line: not in the center
                // 2. Inside the line: at the center of the line
                // 3. Outside the line
                
                // 1 & 2. Inside the line
                
                if (distPointLine(point: initialPoint) <= Double(redLine.frame.width / 2)){
                    
                    // If the finger position is between the two cat images start oscillator
                    // or play cat or kitten sound
                    
                    if isBetweenCats(cat: cat, kitten: kitten, point: initialPoint) {
                        
                        // 1. Inside the line but not in the center
                        
                        startInsideLineOscillator(point: initialPoint)
                        
                        // If the user touches the kitten image play kitten sound
                        
                        if Utility.isInsideKitten(kitten: kitten, point: initialPoint) {
                            
                            playKittenSound()
                            
                        }
                        
                        // If the user touches the cat image play cat sound
                        
                        if Utility.isInsideCat(cat: cat, point: initialPoint) {
                            
                            playCatSound()
                            
                        }
                        
                        // 2. At the center of the line
                        
                        // If the finger position is at the center of the line start the second oscillator, whose frequency is fixed
                        
                        if (distPointLine(point: initialPoint) <= 5) {
                            
                            startCenterLineOscillator(point: initialPoint)
                            
                        }
                        
                        // If the user has moved from the kitten to the cat levelComplete becomes true, else the user is notified to restart from the kitten
                        
                        if Utility.isInsideCat(cat: cat, point: initialPoint) {
                            
                            // If the user movement has started from the kitten the oscillators stop and levelComplete becomes true
                            
                            if startedFromKitten {
                                
                                lastPointInsideCatHandler()
                                
                            } else {
                                
                                lastPointNotInsideCatHandler()
                            }
                        }
                    }
                    
                } else {
                    
                    // 3. Outside the line
                    
                    outsideLineHandler()
                }
            }
            
            // PanDetector state: ended. The finger has been released.
            
            // If the finger has been released, the oscillators are stopped, the user is alerted and startedFromKitten becomes false
            
            if gestureRecognizer.state == .ended {
                
                panEndedHandler()
                
            }
        }
        
        // 3. Level complete: redirect to the next screen
        
        if levelComplete == true {
            
            levelCompleteHandler(gestureRecognizer: gestureRecognizer)
            
        }
    }
    
    // FUNCTIONS
    
    // 1. ONLOAD FUNCTIONS
    
    // setAudioKitElements: inizialization of AudioKit elements: cat and kitten sounds, oscillators
    
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
    
    // setViewElements: sets positions and dimensions of view elements
    
    func setViewElements() -> Void {
        
        print("setViewElements")
        
        // Sets the width of the line image: 50% of screen height
        
        let frameHeight = view.frame.size.height * 0.5
        let aspectRatio = CGFloat(3)
        let frameWidth = frameHeight / aspectRatio
        
        redLine.frame = CGRect(x:0, y:0, width:frameWidth, height:frameHeight)
        
        // Sets dimensions of kitten and cat images
        
        kitten.frame = CGRect(x:0, y:0, width: frameWidth, height: frameWidth)
        cat.frame = CGRect(x:0, y:0, width: frameWidth, height: frameWidth)
        
        // Sets a frame for the images: the line image is centered horizontally and vertically
        // while kitten and cat are centered vertically and have some distance from the line image
        
        redLine.frame.origin.x = CGFloat(self.view.frame.size.width / 2 - self.redLine.frame.width / 2)
        redLine.frame.origin.y = CGFloat(self.view.frame.size.height / 2 - self.redLine.frame.height / 2)
        
        kitten.frame.origin.x = CGFloat(self.view.frame.size.width / 2 - self.kitten.frame.width / 2)
        kitten.frame.origin.y = redLine.frame.minY - kitten.frame.height - 10.0
        
        cat.frame.origin.x = CGFloat(self.view.frame.size.width / 2 - self.cat.frame.width / 2)
        cat.frame.origin.y = redLine.frame.maxY + 10.0
        
        // Hides the kitten label
        
        kitten.isHidden = true
        redLine.isHidden = true
    }
    
    // 2. GAME LOGIC FUNCTIONS
    
    // catFoundHandler: if the user position is inside the cat image, catShown becomes true and the kitten is shown
    
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
    
    // kittenFoundHandler: if the cat has been found and shown and the user position is inside the kitten image, the line is shown and gameStarted becomes true
    
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
    
    // startInsideLineOscillator: if cat, kitten and line have been shown and the finger is between the to cat images, start the first oscillator, whose frequency depends on distance from the middle line
    
    func startInsideLineOscillator(point: CGPoint) -> Void {
        
        print("startInsideLineOscillator")
        
        // Stops other oscillators playing
        
        oscillator2.stop()
        
        // Sets up and starts the oscillator
        
        oscillator.baseFrequency = 300 + 10 * distPointLine(point: point)
        oscillator.amplitude = 1
        oscillator.start()
    }
    
    // startCenterLineOscillator: stops others oscillators and starts the center line oscillator, whose frequency is fixed
    
    func startCenterLineOscillator(point: CGPoint) -> Void {
        
        print("startCenterLineOscillator")
        
        // Stops other oscillators
        
        oscillator2.stop()
        
        // Sets panner value for the oscillator: necessary for sound spatialization, which depends from finger horizontal position (sound "moves" accordingly from left to right and vice versa)
        
        panner.pan = Utility.normalizePannerValue(cat: cat, kitten: kitten, num: Double(point.x))
        
        // Fixes the frequency for the oscillator
        
        oscillator.baseFrequency = 300
    }
    
    // startOutsideLineOscillator: stops others oscillators and starts the outside line oscillator, whose frequency is fixed
    
    func startOutsideLineOscillator() -> Void {
        
        print("startOutsideLineOscillator")
        
        // Stops other oscillators
        
        oscillator.stop()
        
        // Sets panner value for the oscillator: necessary for sound spatialization
        
        panner.pan = 0.0
        
        // Sets up and starts the second oscillator
        
        oscillator2.amplitude = 0.5
        oscillator2.frequency = 200
        oscillator2.start()
    }
    
    // lastPointInsideCatHandler: if the user has moved from the kitten to the cat the oscillators are stopped and levelComplete becomes true
    
    func lastPointInsideCatHandler() -> Void {
        
        print("lastPointInsideCatHandler")
        
        // Stops the oscillators
        
        oscillator.stop()
        oscillator2.stop()
        
        // Stops the game
        
        gameStarted = false
        
        // Sets levelComplete to true
        
        levelComplete = true
    }
    
    // lastPointNotInsideCatHandler: if the user has moved from the kitten but not to the cat, an alert message is read
    
    func lastPointNotInsideCatHandler() -> Void {
        
        print("lastPointNotInsideCatHandler")
        
        // Tells the user to restart
        
        UIAccessibility.post(notification: .announcement, argument: "Go back to the kitten and follow the line")
    }
    
    // outsideLineHandler: if the finger position is outside the line, set up an oscillator with fixed and lower frequency
    
    func outsideLineHandler() -> Void {
        
        print("outsideLineHandler")
        
        startOutsideLineOscillator()
        
        // StartedFromKitten becomes false
        
        startedFromKitten = false
    }
    
    // panEndedHandler: if the finger has been released, the oscillators are stopped, the user is alerted and startedFromKitten becomes false
    
    func panEndedHandler() -> Void {
        
        print("panEndedHandler")
        
        // Stops other oscillators
        
        oscillator.stop()
        oscillator2.stop()
        
        // Tells the user to restart the movement from kitten
        
        UIAccessibility.post(notification: .announcement, argument: "Touch released, go back to the kitten and follow the line")
        
        // Sets startedFromKitten false
        
        startedFromKitten = false
    }
    
    // levelCompleteHandler: the user has moved from kitten to the cat and has completed the level. Stops gestureRecognizer, tells the user level is completed, plays cat sound and redirects to the next screen
    
    func levelCompleteHandler(gestureRecognizer: UIGestureRecognizer) -> Void {
        
        print("levelCompleteHandler")
        
        // Stops gestureRecognizer
        
        gestureRecognizer.isEnabled = false

        // Tells the user level is completed
        
        UIAccessibility.post(notification: .announcement, argument: "Well done! Level 2 completed")

        // Plays cat sound
        
        playCatSound()
        
        // After 2 seconds
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            
            // Stops AudioKit
            
            try! AudioKit.stop()
            
            // Redirects to the next screen
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let level3Screen = storyBoard.instantiateViewController(withIdentifier: "Level3Screen")
            self.present(level3Screen, animated: true, completion: nil)
        })
    }
    
    // playKittenSound: stops other oscillators and plays kitten sound
    
    func playKittenSound() -> Void {
        
        print("playKittenSound")
        
        // Stops other oscillators
        
        oscillator.stop()
        oscillator2.stop()
        
        // Plays kitten sound
        
        kittenSound.start()
    }
    
    // playCatSound: stops other oscillators and plays cat sound
    
    func playCatSound() -> Void {
        
        print("playCatSound")
        
        // Stops other oscillators
        
        oscillator.stop()
        oscillator2.stop()
        
        // Plays kitten sound
        
        catSound.start()
    }
    
    // 3. UTILITY
    
    // distPointLine: creates a virtual line based on an equation: returns distance from given point
    
    func distPointLine(point: CGPoint) -> Double {
        
        print("distPointLine")
        
        let a = Double(1)
        let b = Double(0)
        let c = Double(self.view.frame.size.width / 2)
        
        let den = sqrt(pow(a, 2) + pow(b, 2))
        
        return abs(a * Double(point.x) + b * Double(point.y) - c) / den
    }
    
    // isBetweenCats: returns true if the given point is between the cat and kitten image
    
    func isBetweenCats(cat: UIImageView, kitten: UIImageView, point: CGPoint) -> Bool {
        
        print("isBetweenCats")
        
        let kittenMinY = kitten.frame.minY
        let catMaxY = cat.frame.maxY
        
        return point.y <= catMaxY && point.y >= kittenMinY
    }

}
