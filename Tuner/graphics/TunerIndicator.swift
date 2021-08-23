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
        static let startDegree: Double = 204
        static let endDegree: Double = 336
        static let divedBy = 21
        static let eachStep: Double = (endDegree - startDegree) / Double(divedBy)
        static let addDegree = eachStep * 0.96
    }
    
    var outlineColor: UIColor = UIColor.blue
    var innerColor: UIColor = UIColor.orange
    var coreColor: UIColor? = UIColor(named: "indicator-background")
    var textColor: UIColor? = UIColor(named: "indicator-black")
    var leftDegree: CGFloat =  0
    
    
    override func draw(_ rect: CGRect) {
        UIColor(named: "indicator-background")?.setFill()
        UIGraphicsGetCurrentContext()?.fill(rect)
        
        // 상대
        let arcWidth = 0.0127 * bounds.width // 5

        let boundsMax: CGFloat = max(bounds.width, bounds.height)
        // xr: 394, 331

        // 외각 점선
        let startAngle: CGFloat = CGFloat(204.degreesToRadians)
        let endAngle: CGFloat = CGFloat(336.degreesToRadians)

        let position = CGPoint(x: bounds.width / 2, y: bounds.height * 0.85)
        
        guard let context = UIGraphicsGetCurrentContext() else { fatalError("context를 찾을 수 없음.") }
        
        let outerLinePath = UIBezierPath(arcCenter: position,
                                         radius: boundsMax / 2 - arcWidth / 2,
                               startAngle: startAngle,
                                 endAngle: endAngle,
                                clockwise: true)
        
        outerLinePath.lineWidth = arcWidth
        outerLinePath.lineCapStyle = .butt
        
        // https://stackoverflow.com/questions/62891571
        
        let outerLineColor = state.tuningSystem == .equalTemperament
            ? UIColor(named: "indicator-outline-et")?.cgColor
            : UIColor(named: "indicator-outline-ji")?.cgColor
        context.setStrokeColor(outerLineColor ?? UIColor.blue.cgColor)
        context.setLineWidth(2)
        context.setShadow(offset: .zero, blur: 20, color: outerLineColor)
        context.setBlendMode(.sourceAtop)
        // .difference, .exclusion(stroke), .multiply(light), screen(dark), sourceAtop, In, (stroke)

        context.addPath(outerLinePath.cgPath)
        context.strokePath()
        
        let innerCircleCenter = CGPoint(x: bounds.width / 2, y: outerLinePath.bounds.maxY + 5)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        context.setBlendMode(.sourceAtop)
        context.setShadow(offset: .zero, blur: 20, color: CGColor(red: 255, green: 0, blue: 0, alpha: 1))
        
        let activeCondition = state.isStdSmooth && state.octave >= 0
        if activeCondition {
            // 막대기
            // 튜닝이 맞는 경우 강조표시
            if state.centDist >= -1 && state.centDist <= 1 {
                let middleIndex = 0.5 * (Constants.endDegree - Constants.eachStep - Constants.startDegree) + Constants.startDegree
                let leftIndex = middleIndex - Constants.eachStep
                let rightIndex = middleIndex + Constants.eachStep
                
                let needleWingColor = #colorLiteral(red: 0.9960579276, green: 0.7117440104, blue: 0.4905742407, alpha: 0.6352405159)
                
                makeIndicatorSubNeedle(index: leftIndex, color: needleWingColor, center: innerCircleCenter, direction: "left")
                makeIndicatorNeedle(index: middleIndex, color: UIColor.orange, center: innerCircleCenter)
                makeIndicatorSubNeedle(index: rightIndex, color: needleWingColor, center: innerCircleCenter, direction: "right")
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
            
        } else {
            let index = 0 * (Constants.endDegree - Constants.eachStep - Constants.startDegree) + Constants.startDegree
            makeIndicatorNeedle(index: index, color: innerColor, center: innerCircleCenter)
        }
        
        // 중심부 (흰색)
        context.setBlendMode(.normal)
        let circleShadowColor = UIColor(named: "indicator-circle-shadow") ?? UIColor.red
        context.setShadow(offset: .zero, blur: 10, color: circleShadowColor.cgColor)
//        let coreCircleRadius = 76
        let coreCircleRadius = 0.1944 * bounds.width
        let coreCircleCenter = CGPoint(x: innerCircleCenter.x, y: innerCircleCenter.y + CGFloat(coreCircleRadius) / 2)
        let coreCirclePath = UIBezierPath(arcCenter: coreCircleCenter,
                                          radius: CGFloat(coreCircleRadius),
                                     startAngle: startAngle,
                                       endAngle: endAngle,
                                      clockwise: true)
        
        coreColor?.setFill()
        coreCirclePath.fill()
        
        // 빈 칸 채우는 네모
        context.setLineWidth(0)
        let squareMargin: CGFloat = 0
        let square = CGRect(x: coreCirclePath.bounds.minX + squareMargin, y: coreCirclePath.bounds.maxY - 1.5, width: coreCirclePath.bounds.width - (squareMargin * 2), height: 50)
        let squarePath = UIBezierPath(rect: square)
        context.setFillColor(UIColor(named: "indicator-background")!.cgColor)
        context.addPath(squarePath.cgPath)
        context.setShadow(offset: .zero, blur: 10, color: UIColor(named: "indicator-background")!.cgColor)
        context.fillPath()
        
        // 삼각형
        context.setShadow(offset: .zero, blur: 10, color: UIColor(named: "indicator-black")?.cgColor)
        let trianglePath = UIBezierPath()
        let tpXDiff = 0.0256 * bounds.width // 10
        let tpYDiff = 0.1726 * bounds.width // 67.5
        trianglePath.move(to: CGPoint(x: bounds.width / 2 - tpXDiff, y: innerCircleCenter.y - boundsMax / 2 + tpYDiff))
        trianglePath.addLine(to: CGPoint(x: bounds.width / 2, y: innerCircleCenter.y - boundsMax / 2 + tpYDiff + tpXDiff))
        trianglePath.addLine(to: CGPoint(x: bounds.width / 2 + tpXDiff, y: innerCircleCenter.y - boundsMax / 2 + tpYDiff))
        trianglePath.close()
        UIColor(named: "indicator-black")?.setFill()
        trianglePath.fill()
        
        // 텍스트
        if activeCondition {
            context.setShadow(offset: .zero, blur: 0)
            var noteFontSize: CGFloat {
                if 0.1574 * bounds.width >= 62 {
                    return 62
                } else {
                    return 0.1574 * bounds.width
                }
            }
            var noteNameAttrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: noteFontSize)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            noteNameAttrs[.foregroundColor] = textColor
            
            // config-notation 반영
            let configNotation = UserDefaults.standard.string(forKey: "config-notation") ?? "sharp"
            let notePart = configNotation == "sharp" ? state.note.textValueForSharp : state.note.textValueForFlat
            
            let noteNameStr = "\(notePart)\(makeSubscriptOfNumber(state.octave))"
            let noteNameY = boundsMax / 2 - arcWidth / 2 - arcWidth
            
            noteNameStr.draw(with: CGRect(x: 0, y: noteNameY, width: bounds.width, height: bounds.height), options: .usesLineFragmentOrigin, attributes: noteNameAttrs, context: nil)
            
            var frequencyAttrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 56)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            frequencyAttrs[.foregroundColor] = textColor
            let frequencyStr = String(format: "%d", Int(round(state.pitch)))
            
            let triangleMinY = trianglePath.bounds.minY
            frequencyStr.draw(with: CGRect(x: 0, y: triangleMinY - 72, width: bounds.width, height: bounds.height), options: .usesLineFragmentOrigin, attributes: frequencyAttrs, context: nil)
            
            var centAtrr = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 17)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            centAtrr[.foregroundColor] = textColor
            let centStr = "\(Int(state.centDist)) cents"
            
            centStr.draw(with: CGRect(x: 0, y: noteNameY + 80, width: bounds.width, height: bounds.height), options: .usesLineFragmentOrigin, attributes: centAtrr, context: nil)
        }
        
        
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
        let arcWidth = 0.01269 * bounds.width
        
        let innerStartAngle: CGFloat = CGFloat(index.degreesToRadians)
        let innerEndAngle: CGFloat = CGFloat((index + Constants.addDegree).degreesToRadians)
        let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y:  bounds.height * 0.85), radius: boundsMax / 2 - arcWidth / 2 - arcWidth, startAngle: innerStartAngle, endAngle: innerEndAngle, clockwise: true)
        
        innerCirclePath.addLine(to: center)
        innerCirclePath.lineWidth = arcWidth
        
        color.setFill()
        innerCirclePath.fill()
    }
    
    func makeIndicatorSubNeedle(index: Double, color: UIColor, center: CGPoint, direction: String) {
        let arcWidth = 0.01269 * bounds.width
        let boundsMax: CGFloat = max(bounds.width, bounds.height)
        var innerStartAngle: CGFloat
        var innerEndAngle: CGFloat
        
        if direction == "left" {
            innerStartAngle = CGFloat((index + Constants.addDegree / 2).degreesToRadians)
            innerEndAngle = CGFloat((index + Constants.addDegree).degreesToRadians)
        } else {
            innerStartAngle = CGFloat(index.degreesToRadians)
            innerEndAngle = CGFloat((index + (Constants.addDegree / 2)).degreesToRadians)
        }
        
        let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y:  bounds.height * 0.85), radius: boundsMax / 2 - arcWidth / 2 - arcWidth, startAngle: innerStartAngle, endAngle: innerEndAngle, clockwise: true)
        
        innerCirclePath.addLine(to: center)
        innerCirclePath.lineWidth = arcWidth
        
        color.setFill()
        innerCirclePath.fill()
    }
}

