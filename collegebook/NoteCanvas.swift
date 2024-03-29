//
//  NotePad.swift
//  collegebook
//
//  Created by Alex Speicher on 1/13/18.
//  Copyright © 2018 Alex Speicher. All rights reserved.
//

import UIKit

class NoteCanvas: UIView {
    var strokePaths = [[CBFile.Stroke]()]
    var removedStrokes = [[CBFile.Stroke]()]
    var index = 0
    
    var drawingImage: UIImage? = nil
    var imageView = UIImageView()
    
    
    var background: UIColor? {
        didSet {
            self.backgroundColor = background
            print("Set Document Background")
        }
    }
    
    override init(frame : CGRect){
        super.init(frame: frame)
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(imageView)
        //fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Stroke variables
    var strokeSize: Float = 5.0
    var strokeOpacity: Float = 1.0
    var strokeColorHex: Int = 0x000000
    
    var touchPoint: CGPoint!
    var touchForce: Float!
    
    var lowestYPoint: CGFloat = 0.0
    var onePageLength: CGFloat?
    
    var lowestTouchPoint = CGPoint(x: 0.0, y: 0.0)//CGPoint?
    var scrollDelegate: DocumentScrollViewDelegate?
    var noteDelegate: NoteCanvasDelegate?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let isStylus = touch?.type == .stylus
        if isStylus {
            scrollDelegate?.changeScrolling()
        }
 
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let isStylus = touch?.type == .stylus
        if isStylus {
            
            //UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
            //let context = UIGraphicsGetCurrentContext()
            
            //drawingImage?.draw(in: bounds)
            
            if let coalescedTouches = event?.coalescedTouches(for: touch!) {
                for aTouch in coalescedTouches {
                    touchPoint = aTouch.location(in: self)
                    touchForce = Float(aTouch.force)
                    let stroke = CBFile.Stroke(strokePoint: touchPoint, strokeColorHex: strokeColorHex, strokeSize: strokeSize * touchForce, strokeOpacity: strokeOpacity)
                    strokePaths[strokePaths.endIndex - 1].append(stroke)
                    
                    let y = touchPoint.y
                    if y > lowestYPoint{
                        lowestYPoint = y
                    }
                }
            } else {
                touchPoint = touch?.location(in: self)
                touchForce = Float(touch!.force)
                let stroke = CBFile.Stroke(strokePoint: touchPoint, strokeColorHex: strokeColorHex, strokeSize: strokeSize * touchForce, strokeOpacity: strokeOpacity)
                strokePaths[strokePaths.endIndex - 1].append(stroke)
                
                let y = touchPoint.y
                if y > lowestYPoint{
                    lowestYPoint = y
                }
            }
            
            //drawLastStroke(context: context, strokes: strokePaths[strokePaths.endIndex - 1])
            
            //self.drawingImage = UIGraphicsGetImageFromCurrentImageContext()
            
            //imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            
            //imageView.frame = self.bounds //CGRect(x: 0, y: 0, width: drawingImage!.size.width, height: drawingImage!.size.height)
            
            //UIGraphicsEndImageContext()
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let isStylus = touch?.type == .stylus
        if isStylus {
            imageView.image = self.drawingImage
            let spaceLeft = self.frame.maxY - lowestYPoint
            if spaceLeft < onePageLength! {
                noteDelegate?.changeNoteFrame()
            }
            
            strokePaths.append([CBFile.Stroke]())
            noteDelegate?.noteHasChanged()
            scrollDelegate?.changeScrolling()
        }
    }
    
    func drawLastStroke(context: CGContext!, strokes: [CBFile.Stroke]) {
        if strokes.count == 1 {
            context!.beginPath()
            context?.move(to: strokes[0].strokePoint)
            context!.setLineWidth(CGFloat(strokes[0].strokeSize))
            context!.setStrokeColor(UIColor(rgb: strokes[0].strokeColorHex).withAlphaComponent(CGFloat(strokes[0].strokeOpacity)).cgColor)
            context!.setLineCap(.round)
            context?.addLine(to: strokes[0].strokePoint)
            context!.strokePath()
        }
        else {
            for i in 0..<strokes.count - 1  {
                context!.beginPath()
                context?.move(to: strokes[i].strokePoint)
                context!.setLineWidth(CGFloat(strokes[i].strokeSize))
                context!.setStrokeColor(UIColor(rgb:strokes[i].strokeColorHex).withAlphaComponent(CGFloat(strokes[i].strokeOpacity)).cgColor)
                context!.setLineCap(.round)
                context?.addLine(to: strokes[i+1].strokePoint)
                context!.strokePath()
            }
            
        }
    }
    
    /* Might not be needed 
    private func drawStroke(context: CGContext!, touch: UITouch) {
        let previousTouchLocation = touch.previousLocation(in: self)
        let TouchLocation = touch.location(in: self)
        let strokeWidth = strokeSize * Float(touch.force)
        context.setLineWidth(CGFloat(strokeWidth))
        context!.setLineCap(.round)
        context.move(to: previousTouchLocation)
        context.addLine(to: TouchLocation)
        context.strokePath()
    }
    */
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        for path in strokePaths {
            if path.count >= 1 {
                if path.count == 1 {
                    context!.beginPath()
                    context?.move(to: path[0].strokePoint)
                    context!.setLineWidth(CGFloat(path[0].strokeSize))
                    context!.setStrokeColor(UIColor(rgb: path[0].strokeColorHex).withAlphaComponent(CGFloat(path[0].strokeOpacity)).cgColor)
                    context!.setLineCap(.round)
                    context?.addLine(to: path[0].strokePoint)
                    context!.strokePath()
                }
                else {
                    for i in 0..<path.count - 1  {
                        context!.beginPath()
                        context?.move(to: path[i].strokePoint)
                        context!.setLineWidth(CGFloat(path[i].strokeSize))
                        context!.setStrokeColor(UIColor(rgb:path[i].strokeColorHex).withAlphaComponent(CGFloat(path[i].strokeOpacity)).cgColor)
                        context!.setLineCap(.round)
                        context?.addLine(to: path[i+1].strokePoint)
                        context!.strokePath()
                    }
                    
                }
            }
        }
        self.drawingImage = nil
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func clearCanvas(){
        if(index >= 0){
            strokePaths = [[CBFile.Stroke]()]
            self.setNeedsDisplay()
        }
    }
    
    func undo(){
        
        if strokePaths.count > 1{
            let lastStroke = strokePaths.remove(at: strokePaths.count - 2)
            removedStrokes.append(lastStroke)
            //strokePaths.removeLast()
            //strokePaths.append([CBFile.Stroke]())
            self.setNeedsDisplay()
            noteDelegate?.noteHasChanged()
        }
    }
    
    func redo(){
        if removedStrokes.count > 1{
            strokePaths[strokePaths.count - 1 ] = removedStrokes.removeLast()
            strokePaths.append([CBFile.Stroke]())
            //strokePaths.append(removedStrokes.last!)
            
            self.setNeedsDisplay()
            noteDelegate?.noteHasChanged()
        }
    }

}

public extension UIImage {
    public convenience init?(Pattern: String, BackgroundColor: UIColor, GuidesColor: UIColor, Scale: Float) {
        var Patternrect: CGRect!
        var DrawPath =  [CGPoint]()
        
        switch Pattern {
            case "Hex":
                Patternrect = CGRect(origin: .zero, size: CGSize(width: 17.32052, height: 30))
                DrawPath = [CGPoint(x: 17.32052, y: 7.5),CGPoint(x: 12.99038, y: 5),CGPoint(x: 12.99038, y: 0),CGPoint(x: 12.99038, y: 5),CGPoint(x: 4.33013, y: 10),CGPoint(x: 0, y: 7.5),CGPoint(x: 4.33013, y: 10),CGPoint(x: 4.33013, y: 20),CGPoint(x: 0, y: 22.5),CGPoint(x: 4.33013, y: 20),CGPoint(x: 12.99038, y: 25),CGPoint(x: 12.99038, y: 30),CGPoint(x: 12.99038, y: 25),CGPoint(x: 17.32052, y: 22.5)]
            case "Graph":
                Patternrect = CGRect(origin: .zero, size: CGSize(width: 25, height: 25))
                DrawPath = [CGPoint(x: 0, y: 12.5),CGPoint(x: 25, y: 12.5),CGPoint(x: 12.5, y: 12.5),CGPoint(x: 12.5, y: 0),CGPoint(x: 12.5, y: 25)]
            case "Ruled":
                Patternrect = CGRect(origin: .zero, size: CGSize(width: 50, height: 25))
                DrawPath = [CGPoint(x: 0, y: 25),CGPoint(x: 50, y: 25)]
            default:
                print( "default case")
        }
        UIGraphicsBeginImageContextWithOptions(Patternrect.size, false, 0.0)
        let Patternpath = UIBezierPath()
        Patternpath.move(to: DrawPath[0])
        for Point in DrawPath[1...] {
            Patternpath.addLine(to: Point)
        }
        BackgroundColor.setFill()
        UIRectFill(Patternrect)
        GuidesColor.setStroke()
        Patternpath.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

