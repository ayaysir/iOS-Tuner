//
//  TunerIndicator.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/07.
//

import UIKit

class TunerIndicator: UIView {
    
    var circleLayer: CAShapeLayer!
    
    private struct Constants {
        static let lineWidth: CGFloat = 5.0
        static let arcWidth: CGFloat = 5
        
        static var halfOfLineWidth: CGFloat {
            return lineWidth / 2
        }
        
        static let startDegree: Double = 204
        static let endDegree: Double = 336
        static let divedBy = 20
        static let eachStep: Double = (endDegree - startDegree) / Double(divedBy)
        static let addDegree = eachStep * 0.96
    }
    
    @IBInspectable var counter: Int = 5
    @IBInspectable var outlineColor: UIColor = UIColor.blue
    @IBInspectable var innerColor: UIColor = UIColor.orange
    
    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIGraphicsGetCurrentContext()?.fill(rect)
        
        // 1
        let center = CGPoint(x: bounds.width / 2, y: bounds.height)


        // 2
        let radius: CGFloat = max(bounds.width, bounds.height)

        // 3
//        let startAngle: CGFloat = 7 * .pi / 6
//        let endAngle: CGFloat = 11 * .pi / 6
        let startAngle: CGFloat = CGFloat(204.degreesToRadians)
        let endAngle: CGFloat = CGFloat(336.degreesToRadians)

        let position = CGPoint(x: bounds.width / 2, y: 220)
        // 4
        let outerLinePath = UIBezierPath(arcCenter: position,
                                   radius: radius / 2 - Constants.arcWidth / 2,
                               startAngle: startAngle,
                                 endAngle: endAngle,
                                clockwise: true)
        
        // 5
//        path.move(to: CGPoint(x: 0, y: 1000))
        outerLinePath.lineWidth = Constants.arcWidth
        outerLinePath.lineCapStyle = .butt
        
        outlineColor.setStroke()
        let dashPattern: [CGFloat] = [10, 5]
        outerLinePath.setLineDash(dashPattern, count: 2, phase: 0)
        outerLinePath.stroke()
        
        let index = Int.random(in: Int(Constants.startDegree)...Int(Constants.endDegree - Constants.addDegree))

        let innerStartAngle: CGFloat = CGFloat(Double(index).degreesToRadians)
        let innerEndAngle: CGFloat = CGFloat((Double(index) + Constants.addDegree).degreesToRadians)
        let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y: 220), radius: radius / 2 - Constants.arcWidth / 2 - Constants.arcWidth, startAngle: innerStartAngle, endAngle: innerEndAngle, clockwise: true)
        
        let innerCircleCenter = CGPoint(x: bounds.width / 2, y: outerLinePath.bounds.maxY + 5)
        innerCirclePath.addLine(to: innerCircleCenter)
    
        innerCirclePath.lineWidth = Constants.arcWidth
        
        innerColor.setFill()
        innerCirclePath.fill()
        
        let coreCircleRadius = 76
        let coreCircleCenter = CGPoint(x: innerCircleCenter.x, y: innerCircleCenter.y + CGFloat(coreCircleRadius) / 2)
        let coreCirclePath = UIBezierPath(arcCenter: coreCircleCenter,
                                          radius: CGFloat(coreCircleRadius),
                                     startAngle: startAngle,
                                       endAngle: endAngle,
                                      clockwise: true)
        
        UIColor.white.setFill()
        coreCirclePath.fill()

    }
}
