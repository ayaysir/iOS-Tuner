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
    @IBInspectable var leftDegree: CGFloat =  0
    
    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIGraphicsGetCurrentContext()?.fill(rect)

        let boundsMax: CGFloat = max(bounds.width, bounds.height)

        // 외각 점선
        let startAngle: CGFloat = CGFloat(204.degreesToRadians)
        let endAngle: CGFloat = CGFloat(336.degreesToRadians)

        let position = CGPoint(x: bounds.width / 2, y: bounds.height * 0.85)
        
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
        
        let innerCircleCenter = CGPoint(x: bounds.width / 2, y: outerLinePath.bounds.maxY + 5)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        
       
        
        if state.isStdSmooth && state.octave >= 0 {
            
            // 막대기
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
            
            
            // 텍스트
            let noteNameAttrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 62)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            
            // config-notation 반영
            let configNotation = UserDefaults.standard.string(forKey: "config-notation") ?? "sharp"
            let notePart = configNotation == "sharp" ? state.note.textValueForSharp : state.note.textValueForFlat
            
            let noteNameStr = "\(notePart)\(makeSubscriptOfNumber(state.octave))"
            let noteNameY = boundsMax / 2 - Constants.arcWidth / 2 - Constants.arcWidth
            
            noteNameStr.draw(with: CGRect(x: 0, y: noteNameY, width: bounds.width, height: bounds.height), options: .usesLineFragmentOrigin, attributes: noteNameAttrs, context: nil)
            
            let frequencyAttrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 56)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            let frequencyStr = String(format: "%d", Int(round(state.pitch)))
            
            frequencyStr.draw(with: CGRect(x: 0, y: innerCircleCenter.y - boundsMax / 2 - 15, width: bounds.width, height: bounds.height), options: .usesLineFragmentOrigin, attributes: frequencyAttrs, context: nil)
            
            let centArr = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 17)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            let centStr = "\(Int(state.centDist)) cent 만큼 차이가 납니다."
            
            centStr.draw(with: CGRect(x: 0, y: noteNameY + 80, width: bounds.width, height: bounds.height), options: .usesLineFragmentOrigin, attributes: centArr, context: nil)
        } else {
            let index = 0 * (Constants.endDegree - Constants.eachStep - Constants.startDegree) + Constants.startDegree
            makeIndicatorNeedle(index: index, color: innerColor, center: innerCircleCenter)
            
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
        

        
        
        // 삼각형
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: bounds.width / 2 - 10, y: innerCircleCenter.y - boundsMax / 2 + 67.5))
        trianglePath.addLine(to: CGPoint(x: bounds.width / 2, y: innerCircleCenter.y - boundsMax / 2 + 77.5))
        trianglePath.addLine(to: CGPoint(x: bounds.width / 2 + 10, y: innerCircleCenter.y - boundsMax / 2 + 67.5))
        trianglePath.close()
        UIColor.black.setFill()
        trianglePath.fill()
        
//        if state.tuningSystem == .equalTemperament {
//            // 왼쪽
//            let leftJIIndicatorIndex = 0.3 * (Constants.endDegree - Constants.eachStep - Constants.startDegree) + Constants.startDegree
//
//            let leftStartAngle: CGFloat = CGFloat(leftJIIndicatorIndex.degreesToRadians)
//            let leftEndAngle: CGFloat = CGFloat((leftJIIndicatorIndex + Constants.addDegree).degreesToRadians)
//            let leftPart = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y:  bounds.height * 0.85), radius: boundsMax / 2 - Constants.arcWidth / 2 - Constants.arcWidth, startAngle: leftStartAngle, endAngle: leftEndAngle, clockwise: true)
//            leftPart.addLine(to: innerCircleCenter)
//            leftPart.lineWidth = Constants.arcWidth
//
//            let leftTri = UIBezierPath()
//            leftTri.move(to: CGPoint(x: leftPart.bounds.minX, y: leftPart.bounds.minY - 11))
//            leftTri.addLine(to: CGPoint(x: leftPart.bounds.minX + 10, y: leftPart.bounds.minY - 1))
//            leftTri.addLine(to: CGPoint(x: leftPart.bounds.minX + 20, y: leftPart.bounds.minY - 11))
//            leftTri.close()
//            leftTri.rotateAroundCenter(angle: 5.8)
//            leftTri.fill()
//
//            // 오른쪽
//            let rightJIIndicatorIndex = 0.7 * (Constants.endDegree - Constants.eachStep - Constants.startDegree) + Constants.startDegree
//
//            let rightStartAngle: CGFloat = CGFloat(rightJIIndicatorIndex.degreesToRadians)
//            let rightEndAngle: CGFloat = CGFloat((rightJIIndicatorIndex + Constants.addDegree).degreesToRadians)
//            let rightPart = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y:  bounds.height * 0.85), radius: boundsMax / 2 - Constants.arcWidth / 2 - Constants.arcWidth, startAngle: rightStartAngle, endAngle: rightEndAngle, clockwise: true)
//            rightPart.addLine(to: innerCircleCenter)
//            rightPart.lineWidth = Constants.arcWidth
//
//            let rightTri = UIBezierPath()
//            rightTri.move(to: CGPoint(x: rightPart.bounds.maxX, y: rightPart.bounds.minY - 11))
//            rightTri.addLine(to: CGPoint(x: rightPart.bounds.maxX - 10, y: rightPart.bounds.minY - 1))
//            rightTri.addLine(to: CGPoint(x: rightPart.bounds.maxX - 20, y: rightPart.bounds.minY - 11))
//            rightTri.close()
//            rightTri.rotateAroundCenter(angle: -5.8)
//            rightTri.fill()
//        }
    }
    
    func makeIndicatorNeedle(index: Double, color: UIColor, center: CGPoint) {
        let boundsMax: CGFloat = max(bounds.width, bounds.height)
        
        let innerStartAngle: CGFloat = CGFloat(index.degreesToRadians)
        let innerEndAngle: CGFloat = CGFloat((index + Constants.addDegree).degreesToRadians)
        let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y:  bounds.height * 0.85), radius: boundsMax / 2 - Constants.arcWidth / 2 - Constants.arcWidth, startAngle: innerStartAngle, endAngle: innerEndAngle, clockwise: true)
        
        innerCirclePath.addLine(to: center)
        innerCirclePath.lineWidth = Constants.arcWidth
        
        color.setFill()
        innerCirclePath.fill()
    }
}

