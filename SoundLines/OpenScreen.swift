//
//  OpenScreen.swift
//  SoundLines
//
//  Created by Fede on 10/09/19.
//  Copyright © 2019 Comelicode. All rights reserved.
//

import Foundation
import UIKit

class OpenScreen: UIViewController {
    
    // Variables
    
    @IBOutlet var screenTitle: UILabel!
    @IBOutlet var screenText: UILabel!
    @IBOutlet var screenButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Sets view elements dimension and position
        
        setViewElements()
        
        // Hides navigation bar
        
        self.navigationController?.navigationBar.isHidden = true;
        
        // Reads label if VoiceOver is activated
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            UIAccessibility.post(notification: .announcement, argument: "Help a kitten play with its cat friend: you just need to connect them with a line! Ready? Press the play button to start the game.")
        })
        
    }
    
    // FUNCTIONS
    
    // 1. ONLOAD FUNCTIONS
    
    // setViewElements: sets positions and dimensions of view elements: they are centered vertically and their dimension depends on screen width and height
    
    func setViewElements() -> Void {
        
        print("setViewElements")

        let screenWidth = view.frame.width
        let screenHeight = view.frame.size.height
        
        // Sets title dimension and position
        
        screenTitle.sizeToFit()
        screenTitle.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.8, height: screenHeight * 0.2)
        screenTitle.center.x = self.view.center.x
        screenTitle.center.y = self.view.center.y - screenHeight * 0.3
        
        // Sets text dimension and position
        
        screenText.sizeToFit()
        screenText.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.8, height: screenHeight * 0.4)
        screenText.center = self.view.center
        
        // Sets constant to multiply for button: different between iPhone and iPad
        
        var screenHeighMultiplicationConstant = CGFloat()
        if screenWidth >= 1024 {
            screenHeighMultiplicationConstant = 0.15
        } else {
            screenHeighMultiplicationConstant = 0.2
        }
        
        // Sets button dimension and position
        
        screenButton.sizeToFit()
        screenButton.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.3, height: screenHeight * screenHeighMultiplicationConstant)
        screenButton.center.x = self.view.center.x
        screenButton.center.y = self.view.center.y + screenHeight * 0.3
        
    }
}
