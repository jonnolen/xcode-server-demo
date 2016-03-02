
import UIKit

protocol MyProtocol{
    func widgets() -> Void
    func activeView() -> UIView?
}


class MyContentView:UIView, MyProtocol, UITextFieldDelegate{
    
    weak var myActiveView:UIView?
    
    init(){
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let cells = Array(1...12).map{_ in cellView() }
        
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

class KeyboardAwareScrollViewController<T:UIView where T:MyProtocol>: UIViewController {
    private let titleView: UIView
    private let contentView: T

    private weak var scrollView: UIScrollView?
    private weak var titleViewContainer: UIView?

    
    init(titleView:UIView, contentView: T){
        self.titleView = titleView
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.titleView = aDecoder.decodeObjectOfClass(UIView.self, forKey: "titleView")!
        self.contentView = aDecoder.decodeObjectOfClass(T.self, forKey: "contentView")!
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardShown(notification: NSNotification){
        let kbSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        if let scrollView = scrollView{
            let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
            
            if let activeField = self.contentView.activeView(){
                let convertedFrame = scrollView.convertRect(activeField.superview!.bounds, fromView: activeField.superview!)
                let offsetFrame = CGRectOffset(convertedFrame, 0.0, 19.0)
                let frame = CGRectInset(offsetFrame, 0.0, 17.0)
                scrollView.scrollRectToVisible(frame, animated: false)
            }
        }
    }
    
    func keyboardHidden(notification: NSNotification){
        if let scrollView = scrollView{
            let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
        }
    }

    override func loadView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.brownColor()

        let sv = UIScrollView()
        sv.backgroundColor = UIColor.clearColor()
        sv.opaque = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true

        self.scrollView = sv
        
        let titleContainer = buildTitleContainer(self.titleView)
        view.addSubview(titleContainer)
        view.addSubview(sv)
        
        //peg scroll view to container.
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: ["scrollView":sv]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[scrollView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: ["scrollView":sv]))
        
        let contentViewWrapper = UIView()
        contentViewWrapper.translatesAutoresizingMaskIntoConstraints = false
        contentViewWrapper.addSubview(self.contentView)
        contentViewWrapper.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|->=0-[contentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["contentView": contentView]))
        contentViewWrapper.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[contentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["contentView": contentView]))
        
        sv.addSubview(contentViewWrapper)
        
        let viewsDictionary = [
            "scrollView": sv,
            "view": view,
            "contentViewWrapper": contentViewWrapper
        ]
       
        //peg contentView to be at least as tall as view.
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentViewWrapper(>=view)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
        //peg contentView to be equal to host view width
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[contentViewWrapper(==view)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))

        //peg title container to width of container.
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[titleContainer]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["titleContainer":titleContainer]))

        //title view height.
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[titleContainer][contentView]",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["titleContainer":titleContainer, "contentView":self.contentView]))

        self.view = view
        self.titleViewContainer = titleContainer
    }
    
    
    func buildTitleContainer(titleView:UIView) -> UIView{
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.backgroundColor = UIColor.orangeColor()
        
        titleContainer.addSubview(titleView)
        titleContainer.setContentCompressionResistancePriority(1000.0, forAxis: .Vertical)
        
        titleContainer.addConstraint(NSLayoutConstraint(item: titleView, attribute: .CenterY, relatedBy: .Equal, toItem: titleContainer, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        titleContainer.addConstraint(NSLayoutConstraint(item: titleView, attribute: .CenterX, relatedBy: .Equal, toItem: titleContainer, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        return titleContainer;
    }
}

