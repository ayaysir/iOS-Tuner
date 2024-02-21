# DGCharts 커스터마이징
## 이유
- 모서리 둥글게 처리하고 싶은데 몇년째 기능구현이 안되고 있다고함
  - https://github.com/danielgindi/Charts/issues/1066
  - SPM으로 가져올 경우 파일 수정이 불가능하여 커스터마이징할 수 없음

## 구현
- SPM의 소스를 그대로 복사해 iOS Framework로 분리
- `BarChartRenderer` 클래스의 `drawDataSet(context:dataSet:index:)`를 다음과 같이 변경
```swift
@objc open func drawDataSet(context: CGContext, dataSet: BarChartDataSetProtocol, index: Int)
{
    guard let dataProvider = dataProvider else { return }

    let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)

    prepareBuffer(dataSet: dataSet, index: index)
    trans.rectValuesToPixel(&_buffers[index])
    
    let borderWidth = dataSet.barBorderWidth
    let borderColor = dataSet.barBorderColor
    let drawBorder = borderWidth > 0.0
    
    context.saveGState()
    defer { context.restoreGState() }
    
    // draw the bar shadow before the values
    if dataProvider.isDrawBarShadowEnabled
    {
        guard let barData = dataProvider.barData else { return }
        
        let barWidth = barData.barWidth
        let barWidthHalf = barWidth / 2.0
        var x: Double = 0.0

        let range = (0..<dataSet.entryCount).clamped(to: 0..<Int(ceil(Double(dataSet.entryCount) * animator.phaseX)))
        for i in range
        {
            guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
            
            x = e.x
            
            _barShadowRectBuffer.origin.x = CGFloat(x - barWidthHalf)
            _barShadowRectBuffer.size.width = CGFloat(barWidth)
            
            trans.rectValueToPixel(&_barShadowRectBuffer)
            
            guard viewPortHandler.isInBoundsLeft(_barShadowRectBuffer.origin.x + _barShadowRectBuffer.size.width) else { continue }
            
            guard viewPortHandler.isInBoundsRight(_barShadowRectBuffer.origin.x) else { break }
            
            _barShadowRectBuffer.origin.y = viewPortHandler.contentTop
            _barShadowRectBuffer.size.height = viewPortHandler.contentHeight

            context.setFillColor(dataSet.barShadowColor.cgColor)
            context.fill(_barShadowRectBuffer)
        }
    }

    let buffer = _buffers[index]
    
    // draw the bar shadow before the values
    if dataProvider.isDrawBarShadowEnabled
    {
        for barRect in buffer where viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width)
        {
            guard viewPortHandler.isInBoundsRight(barRect.origin.x) else { break }
            
            // Customized: 라운드 테두리 ====================
            let cornerRadius: CGFloat = CGRectGetWidth(barRect) <= 5 ? 1.0 : 2.0
            let bezierPath = UIBezierPath(roundedRect: barRect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSizeMake(cornerRadius, cornerRadius))
            let roundedPath = bezierPath.cgPath
            context.addPath(roundedPath)
            context.setFillColor(dataSet.barShadowColor.cgColor)
            context.fillPath()
            // ===========================================
            
            // context.setFillColor(dataSet.barShadowColor.cgColor)
            // context.fill(barRect)
        }
    }
    
    let isSingleColor = dataSet.colors.count == 1
    
    if isSingleColor
    {
        context.setFillColor(dataSet.color(atIndex: 0).cgColor)
    }
    
    // In case the chart is stacked, we need to accomodate individual bars within accessibilityOrdereredElements
    let isStacked = dataSet.isStacked
    let stackSize = isStacked ? dataSet.stackSize : 1

    for j in buffer.indices
    {
        let barRect = buffer[j]
        
        guard viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width) else { continue }
        guard viewPortHandler.isInBoundsRight(barRect.origin.x) else { break }

        if !isSingleColor
        {
            // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
            context.setFillColor(dataSet.color(atIndex: j).cgColor)
        }
        // Customized: 라운드 테두리 ====================
        let cornerRadius: CGFloat = CGRectGetWidth(barRect) <= 5 ? 1.0 : 2.0
        let bezierPath = UIBezierPath(roundedRect: barRect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSizeMake(cornerRadius, cornerRadius))
        let roundedPath = bezierPath.cgPath
        context.addPath(roundedPath)
        context.fillPath()
        // ===========================================
        
        // context.fill(barRect)
        
        
        if drawBorder
        {
            context.setStrokeColor(borderColor.cgColor)
            context.setLineWidth(borderWidth)
            context.stroke(barRect)
        }

        // Create and append the corresponding accessibility element to accessibilityOrderedElements
        if let chart = dataProvider as? BarChartView
        {
            let element = createAccessibleElement(
                withIndex: j,
                container: chart,
                dataSet: dataSet,
                dataSetIndex: index,
                stackSize: stackSize
            ) { (element) in
                element.accessibilityFrame = barRect
            }

            accessibilityOrderedElements[j/stackSize].append(element)
        }
    }
}
```

