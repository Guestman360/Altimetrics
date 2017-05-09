//
//  CircleView.swift
//  Altimetrics
//
//  Created by The Guest Family on 2/5/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

import UIKit

@IBDesignable class CircleView: UIView {
    
    // Variables
    private var pi: CGFloat = CGFloat(M_PI)
    private var progressCircle = CAShapeLayer()
    private var circlePath = UIBezierPath()
    internal var statusProgress: Int = Int()
    
    // Method for calculate ARC
    private func arc(arc: CGFloat) -> CGFloat {
        let results = ( pi * arc ) / 180
        return results
    }
    
    // Variables for IBInspectable
    @IBInspectable var circleColor: UIColor = UIColor.white
    @IBInspectable var lineWidth: Float = Float(3.0)
    @IBInspectable var valueProgress: Float = Float()
    
    override func draw(_ rect: CGRect) {
        
        // Create Path for ARC
        let centerPointArc = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let radiusArc: CGFloat = self.frame.width / 2 * 1.0
        circlePath = UIBezierPath(arcCenter: centerPointArc, radius: radiusArc, startAngle: arc(arc: -90), endAngle: arc(arc: 450), clockwise: true)
        
        // Define background circle progress
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = circleColor.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = CGFloat(lineWidth)
        progressCircle.strokeStart = 0
        progressCircle.strokeEnd = 100
        
        // Set for sublayer circle progress
        layer.addSublayer(progressCircle)
    }
    
}

