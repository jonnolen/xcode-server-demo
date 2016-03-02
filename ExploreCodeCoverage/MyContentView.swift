//
//  MyContentView.swift
//  ExploreCodeCoverage
//
//  Created by Jonathan Nolen on 3/2/16.
//  Copyright © 2016 DT. All rights reserved.
//

import UIKit

class MyContentView:UIView, ActiveViewProvider, UITextFieldDelegate{
    
    weak var myActiveView:UIView?
    
    init(){
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let cells = Array(1...5).map{_ in cellView() }
        
        var cellsDictionary: Dictionary<String, UIView> = [:], cellsVerticalFormat = "V:|-"
        
        for (idx, cell) in cells.enumerate(){
            self.addSubview(cell)
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[cell]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["cell": cell]))
            let cellKey = "cell\(idx)"
            cellsDictionary[cellKey] = cell
            cellsVerticalFormat = cellsVerticalFormat + "[\(cellKey)]-"
        }
        
        cellsVerticalFormat = cellsVerticalFormat + "|"
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(cellsVerticalFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: cellsDictionary))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func cellView() -> UIView{
        let result = UIView()
        result.backgroundColor = UIColor.magentaColor()
        result.translatesAutoresizingMaskIntoConstraints = false
        
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        
        result.addSubview(text)
        text.delegate = self
        result.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[text]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["text": text]))
        result.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[text]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["text": text]))
        return result
    }
    
    func widgets() {
        print("\(MyContentView.self) widgets")
    }
    
    func activeView() -> UIView? {
        return myActiveView
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        myActiveView = textField.superview!
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if myActiveView === textField.superview! {
            myActiveView = nil
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
