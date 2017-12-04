//
//  ChartViewController.swift
//  RxStockDemo
//
//  Created by Frank on 2017/12/03.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit
import SwiftCharts
import RxSwift
import RxCocoa

class ChartViewController: UIViewController {
    @IBOutlet weak var chartView: UIView!
    
    fileprivate var chart: Chart?
    var symbol: String!
    private var viewModel: ChartViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ChartViewModel(symbol: symbol)
        bindUI()
    }
    
    private func bindUI() {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM dd"
        
        viewModel.prices
            .throttle(1.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (results, changes) in
                if changes != nil, results.count > 1 {
                    var chartPoints: [ChartPointCandleStick] = []
                    
                    var lowest: Double = Double(Int.max)
                    var highest: Double = 0
                    
                    for stockPrice in results {
                        lowest = stockPrice.low < lowest ? stockPrice.low : lowest
                        highest = stockPrice.high > highest ? stockPrice.high : highest
                        
                        let chartPointCandleStick = ChartPointCandleStick(date: stockPrice.date, formatter: displayFormatter, high: stockPrice.high, low: stockPrice.low, open: stockPrice.open, close: stockPrice.close)
                        chartPoints.append(chartPointCandleStick)
                    }
                    
                    self?.bindChart(chartPoints: chartPoints, displayFormatter: displayFormatter, highest: highest, lowest: lowest)
                }
            })
            .disposed(by: bag)
    }
    
    private func bindChart(chartPoints: [ChartPointCandleStick], displayFormatter: DateFormatter, highest: Double, lowest: Double) {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let yValues = stride(from: lowest - 5, through: highest + 5, by: 5).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
        let xGeneratorDate = ChartAxisValuesGeneratorDate(unit: .day, preferredDividers:2, minSpace: 1, maxTextSize: 12)
        let xLabelGeneratorDate = ChartAxisLabelsGeneratorDate(labelSettings: labelSettings, formatter: displayFormatter)
        let firstDate = chartPoints.first!.date
        let lastDate = chartPoints.last!.date
        let xModel = ChartAxisModel(firstModelValue: firstDate.timeIntervalSince1970, lastModelValue: lastDate.timeIntervalSince1970, axisTitleLabels: [ChartAxisLabel(text: "Date", settings: labelSettings)], axisValuesGenerator: xGeneratorDate, labelsGenerator: xLabelGeneratorDate)
        
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Price", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(chartView.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettings // for now zoom & pan disabled, layer needs correct scaling mode.
        
        let coordsSpace = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let chartPointsLineLayer = ChartCandleStickLayer<ChartPointCandleStick>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, itemWidth: Env.iPad ? 10 : 5, strokeWidth: Env.iPad ? 1 : 0.6, increasingColor: .red, decreasingColor: .green)
        
        let settings = ChartGuideLinesLayerSettings(linesColor: .black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        let dividersSettings =  ChartDividersLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth, start: Env.iPad ? 7 : 3, end: 0)
        let dividersLayer = ChartDividersLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: dividersSettings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                dividersLayer,
                chartPointsLineLayer
            ]
        )
        
        chartView.addSubview(chart.view)
        self.chart = chart
    }
}

class Env {
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

struct ExamplesDefaults {
    static var chartSettings: ChartSettings {
        if Env.iPad {
            return iPadChartSettings
        } else {
            return iPhoneChartSettings
        }
    }
    
    static var chartSettingsWithPanZoom: ChartSettings {
        if Env.iPad {
            return iPadChartSettingsWithPanZoom
        } else {
            return iPhoneChartSettingsWithPanZoom
        }
    }
    
    fileprivate static var iPadChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 20
        chartSettings.top = 20
        chartSettings.trailing = 20
        chartSettings.bottom = 20
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.labelsToAxisSpacingY = 10
        chartSettings.axisTitleLabelsToLabelsSpacing = 5
        chartSettings.axisStrokeWidth = 1
        chartSettings.spacingBetweenAxesX = 15
        chartSettings.spacingBetweenAxesY = 15
        chartSettings.labelsSpacing = 0
        return chartSettings
    }
    
    fileprivate static var iPhoneChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.labelsSpacing = 0
        return chartSettings
    }
    
    fileprivate static var iPadChartSettingsWithPanZoom: ChartSettings {
        var chartSettings = iPadChartSettings
        chartSettings.zoomPan.panEnabled = true
        chartSettings.zoomPan.zoomEnabled = true
        return chartSettings
    }
    
    fileprivate static var iPhoneChartSettingsWithPanZoom: ChartSettings {
        var chartSettings = iPhoneChartSettings
        chartSettings.zoomPan.panEnabled = true
        chartSettings.zoomPan.zoomEnabled = true
        return chartSettings
    }
    
    static func chartFrame(_ containerBounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 70, width: containerBounds.size.width, height: containerBounds.size.height - 70)
    }
    
    static var labelSettings: ChartLabelSettings {
        return ChartLabelSettings(font: ExamplesDefaults.labelFont)
    }
    
    static var labelFont: UIFont {
        return ExamplesDefaults.fontWithSize(Env.iPad ? 14 : 11)
    }
    
    static var labelFontSmall: UIFont {
        return ExamplesDefaults.fontWithSize(Env.iPad ? 12 : 10)
    }
    
    static func fontWithSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir Next", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static var guidelinesWidth: CGFloat {
        return Env.iPad ? 0.5 : 0.1
    }
    
    static var minBarSpacing: CGFloat {
        return Env.iPad ? 10 : 5
    }
}
