//
//  Line.swift
//  SoundLines
//
//

import Foundation
import UIKit

class Line {
    
    var position: (Double, Double, Double)
    var dimension: (Double, Double)
    var sound: (Double, Double, Double)
    var image: UIImageView = UIImageView()
    var isHidden: Bool = false
    
    init(position: (a: Double, b: Double, c: Double), dimension: (width: Double, height: Double), sound: (volume: Double, pitch: Double, frequency: Double), image: UIImageView, isHidden: Bool) {
        
        self.position = position
        self.dimension = dimension
        self.sound = sound
        self.image = image
        self.isHidden = isHidden
        
    }
}
