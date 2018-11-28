//
//  EqualizerView.swift
//  AudioVisualizer
//
//  Created by Thành Lã on 11/27/18.
//  Copyright © 2018 MonstarLab. All rights reserved.
//

import UIKit
import DisPlayers_Audio_Visualizers
import EZAudioiOS

protocol EqualizerViewOptions {
    var scale: CGFloat { get }
}

extension EqualizerViewOptions {
    var scale: CGFloat {
        return 0.75
    }
}

class EqualizerView: DPRollingEqualizerView, EqualizerViewOptions {

    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        let frame: CGRect = bounds
        
        backgroundColor?.set()
        UIRectFill(frame)
        
        let columnWidth: CGFloat = (rect.size.width * scale) / (CGFloat(equalizerSettings.numOfBins) - 1)
        
        let actualWidth = max(1, columnWidth * (1 - 2 * equalizerSettings.padding))
        let actualPadding = max(0, (columnWidth - actualWidth) / 2)
        
        guard let timeHeights = audioService()?.timeHeights() as? [CGFloat] else { return }
        for i in 0 ..< Int(equalizerSettings.numOfBins) {
            let columnHeight = timeHeights[i] / 2
            
            if columnHeight <= 0 {
                continue
            }
            let columnX: CGFloat = CGFloat(i) * columnWidth
            
            var rollingPath = UIBezierPath()
            rollingPath = UIBezierPath(roundedRect: CGRect(x: columnX + actualPadding, y: frame.height / 2 - columnHeight / 2, width: actualWidth, height: columnHeight), cornerRadius: actualWidth)
            
            equalizerBinColor.setFill()
            
            rollingPath.fill()
        }
        
        equalizerBinColor.setStroke()
        
        let linePath = UIBezierPath()
        
        linePath.lineWidth = 2.0
        linePath.move(to: CGPoint(x: rect.width * scale + actualPadding, y: rect.height / 2))
        linePath.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        linePath.stroke()
        
        ctx?.restoreGState()
    }


}

class AudioPlot: EZAudioPlot {
    
}
