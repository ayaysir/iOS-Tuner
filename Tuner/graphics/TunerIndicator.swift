//
//  TunerIndicator.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/07.
//

import UIKit

class TunerIndicator: UIView {
    
    var state: TunerData = TunerData() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private struct Constants {
        static let lineWidth: CGFloat = 5.0
        static let arcWidth: CGFloat = 5
        
        static var halfOfLineWidth: CGFloat {
            return lineWidth / 2
        }
        
        static let startDegree: Double = 204
        static let endDegree: Double = 336
        static let divedBy = 21
        static let eachStep: Double = (endDegree - startDegree) / Double(divedBy)
        static let addDegree = eachStep * 0.96
    }
    
    @IBInspectable var outlineColor: UIColor = UIColor.blue
    @IBInspectable var innerColor: UIColor = UIColor.orange
    @IBInspectable var coreColor: UIColor = UIColor.white
    
    
    
    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIGraphicsGetCurrentContext()?.fill(rect)

        let boundsMax: CGFloat = max(bounds.width, bounds.height)

        // 외각 점선
        let startAngle: CGFloat = CGFloat(204.degreesToRadians)
        let endAngle: CGFloat = CGFloat(336.degreesToRadians)

        let position = CGPoint(x: bounds.width / 2, y: 220)
        
        let outerLinePath = UIBezierPath(arcCenter: position,
                                         radius: boundsMax / 2 - Constants.arcWidth / 2,
                               startAngle: startAngle,
                                 endAngle: endAngle,
                                clockwise: true)
        
        outerLinePath.lineWidth = Constants.arcWidth
        outerLinePath.lineCapStyle = .butt
        
        outlineColor.setStroke()
        let dashPattern: [CGFloat] = [10, 5]
        outerLinePath.setLineDash(dashPattern, count: 2, phase: 0)
        outerLinePath.stroke()
        
        // 막대기
        let innerCircleCenter = CGPoint(x: bounds.width / 2, y: outerLinePath.bounds.maxY + 5)
        
        // 튜닝이 맞는 경우 강조표시
        if state.centDist >= -1 && state.centDist <= 1 {
            let middleIndex = 0.5 * (Constants.endDegree - Constants.eachStep - Constants.startDegree) + Constants.startDegree
            let leftIndex = middleIndex - Constants.eachStep
            let rightIndex = middleIndex + Constants.eachStep
            makeIndicatorNeedle(index: leftIndex, color: UIColor.gray, center: innerCircleCenter)
            makeIndicatorNeedle(index: middleIndex, color: UIColor.orange, center: innerCircleCenter)
            makeIndicatorNeedle(index: rightIndex, color: UIColor.gray, center: innerCircleCenter)
        } else if state.centDist > -50 && state.centDist <= 50 {
            let percentOfCurrentFreq: Double = (Double(state.centDist) + 50) / 100
            let index = percentOfCurrentFreq * (Constants.endDegree - Constants.eachStep - Constants.startDegree) + Constants.startDegree
            makeIndicatorNeedle(index: index, color: innerColor, center: innerCircleCenter)
        } else if state.centDist <= -50 {
            let index = 0 * (Constants.endDegree - Constants.eachStep - Constants.startDegree) + Constants.startDegree
            makeIndicatorNeedle(index: index, color: innerColor, center: innerCircleCenter)
        } else {
            let index = (Constants.endDegree - Constants.eachStep - Constants.startDegree) + Constants.startDegree
            makeIndicatorNeedle(index: index, color: innerColor, center: innerCircleCenter)
        }
        
        
        
        // 중심부 (흰색)
        let coreCircleRadius = 76
        let coreCircleCenter = CGPoint(x: innerCircleCenter.x, y: innerCircleCenter.y + CGFloat(coreCircleRadius) / 2)
        let coreCirclePath = UIBezierPath(arcCenter: coreCircleCenter,
                                          radius: CGFloat(coreCircleRadius),
                                     startAngle: startAngle,
                                       endAngle: endAngle,
                                      clockwise: true)
        
        coreColor.setFill()
        coreCirclePath.fill()

    }
    
    func makeIndicatorNeedle(index: Double, color: UIColor, center: CGPoint) {
        let boundsMax: CGFloat = max(bounds.width, bounds.height)
        
        let innerStartAngle: CGFloat = CGFloat(index.degreesToRadians)
        let innerEndAngle: CGFloat = CGFloat((index + Constants.addDegree).degreesToRadians)
        let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y: 220), radius: boundsMax / 2 - Constants.arcWidth / 2 - Constants.arcWidth, startAngle: innerStartAngle, endAngle: innerEndAngle, clockwise: true)
        
        innerCirclePath.addLine(to: center)
        innerCirclePath.lineWidth = Constants.arcWidth
        
        color.setFill()
        innerCirclePath.fill()
    }
}
