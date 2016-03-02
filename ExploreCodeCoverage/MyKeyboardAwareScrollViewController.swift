import UIKit

class MyKeyboardAwareScrollViewController : KeyboardAwareScrollViewController{
    let myContentView: MyContentView = MyContentView()
    
    let myTitleView: UILabel = {
        let result = UILabel()
        
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Pretend This Says\nCohn-Reznick"
        result.numberOfLines = 0
        result.textAlignment = .Center
        result.textColor = UIColor.whiteColor()
        return result
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(titleView: myTitleView, contentView: myContentView, debugBorders: false)
    }
}

