
import UIKit

protocol ActiveViewProvider{
    func widgets() -> Void
    func activeView() -> UIView?
}



class KeyboardAwareScrollViewController: UIViewController, UIScrollViewDelegate {
    private let titleView: UIView
    private let contentView: UIView
    private let activeFieldProvider: ActiveViewProvider
    private let debugBorders: Bool
    
    private weak var scrollView: UIScrollView?
    private weak var titleViewContainer: UIView?
    private var titleContainerHeightConstraint: NSLayoutConstraint?
    
    
    init(titleView:UIView, contentView: UIView, debugBorders: Bool = false){
        self.titleView = titleView
        self.contentView = contentView
        self.activeFieldProvider = contentView as! ActiveViewProvider
        self.debugBorders = debugBorders
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.titleView = aDecoder.decodeObjectOfClass(UIView.self, forKey: "titleView")!
        self.contentView = aDecoder.decodeObjectOfClass(UIView.self, forKey: "contentView")!
        self.activeFieldProvider = self.contentView as! ActiveViewProvider
        self.debugBorders = false
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool){
        updateHeaderView()
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
            
            if let activeField = self.activeFieldProvider.activeView(){
                let convertedFrame = scrollView.convertRect(activeField.bounds, fromView: activeField)
                let offsetFrame = CGRectOffset(convertedFrame, 0.0, 19.0)
                let frame = CGRectInset(offsetFrame, 0.0, 17.0)
                print("call scrollToRect")
                scrollView.scrollRectToVisible(frame, animated: false)
                print("scrolled to rect")
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
        view.backgroundColor = UIColor.blackColor()

        let sv = UIScrollView()
        sv.backgroundColor = UIColor.clearColor()
        sv.opaque = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.delegate = self
        
        self.scrollView = sv

        let titleContainer = buildTitleContainer(self.titleView)
        view.addSubview(titleContainer)
        view.addSubview(sv)
        
        //peg scroll view to container.
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: ["scrollView":sv]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[scrollView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: ["scrollView":sv]))
        
        let contentViewWrapper = UIView()
        addDebugBorderToView(contentViewWrapper)
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

        let titleViewContainerHeight = NSLayoutConstraint(item: titleContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
        titleViewContainerHeight.priority = 750.0
        
        self.titleContainerHeightConstraint = titleViewContainerHeight
        
        titleContainer.addConstraint(titleViewContainerHeight)
        //title view height.
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20@1-[titleContainer]",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["titleContainer":titleContainer]))

        self.view = view
        self.titleViewContainer = titleContainer
    }
    
    func buildTitleContainer(titleView:UIView) -> UIView{
        addDebugBorderToView(titleView)
        
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.backgroundColor = UIColor.clearColor()
        titleContainer.addSubview(titleView)
        addDebugBorderToView(titleContainer)
        
        titleView.setContentCompressionResistancePriority(1000.0, forAxis: .Vertical)
        
        titleContainer.addConstraint(NSLayoutConstraint(item: titleView, attribute: .CenterY, relatedBy: .Equal, toItem: titleContainer, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        titleContainer.addConstraint(NSLayoutConstraint(item: titleView, attribute: .CenterX, relatedBy: .Equal, toItem: titleContainer, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        titleContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[titleContainer(>=titleView@1000)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["titleContainer": titleContainer, "titleView": titleView]))
        
        return titleContainer;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    func updateHeaderView(){
        //shrink down to intrinsic size of titleView and then scroll off screen.
        if let view = self.view, titleContainerHeightConstraint = self.titleContainerHeightConstraint, titleContainer = self.titleViewContainer{
            let topOfContentView = view.convertPoint(self.contentView.bounds.origin, fromView: self.contentView)
            titleContainerHeightConstraint.constant = topOfContentView.y-20
            
            //fade out as we scroll over. (need to use some sort of sizing function to determine resolved new height.)
            
            let newHeight = titleContainer.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            titleContainer.alpha = 1.0 - 0.05 * (newHeight - topOfContentView.y)
        }
    }
    func addDebugBorderToView(view: UIView){
        if (self.debugBorders){
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.grayColor().CGColor
        }
    }
}

