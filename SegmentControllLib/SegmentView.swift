//
//  SegmentView.swift
//  SegmentControllLib
//
//  Created by Andrey Doroshko on 3/29/18.
//  Copyright © 2018 Andrey Doroshko. All rights reserved.

import UIKit

extension TimeInterval {
    static var defaultAnimationDuration: TimeInterval {
        return 0.3
    }
}

class SegmentView: UIViewController {
    
    typealias Animator = (_ parent: SegmentView, _ from: UIViewController, _ to: UIViewController, _ side: Direction) -> Void
    
    enum Direction {
        case left
        case right
    }
    
    let animator: Animator = { parent, from, to, direction in
        to.willMove(toParentViewController: parent)
        parent.addChildViewController(to)
        let dX = direction == .right ? parent.view.bounds.width : -parent.view.bounds.width
        
        parent.segment.addSubview(to.view)
        
        to.view.frame = parent.view.bounds
        to.view.transform = CGAffineTransform(translationX: dX, y: 0)
        //from.view.transform = .identity
        //let newMarkerLineOrigin = CGPoint(x: parent.buttons[parent.currentPoint].frame.origin.x,
//                                          y: parent.buttons[parent.currentPoint].frame.origin.y
//                                            + parent.buttons[parent.currentPoint].frame.height
//                                            - parent.markerLine.frame.height)
//        
        UIView.animate(
            withDuration: .defaultAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.2,
            options: [.beginFromCurrentState, .curveEaseIn],
            animations: {
                to.view.transform = .identity
                //parent.markerLine.frame.origin = newMarkerLineOrigin
        },
            completion: { (completed) in
                from.willMove(toParentViewController: nil)
                from.removeFromParentViewController()
        })
    }
    
    public var currentPoint: Int = 0 {
        didSet {
            guard currentPoint < controllers.count else { fatalError() }
            guard isViewLoaded else { return }
            updateCurrentVC(for: currentPoint, oldIndex: oldValue)
        }
    }
    
    fileprivate var controllers = [UIViewController]() {
        didSet {
            self.currentPoint = 0
        }
    }
    
    fileprivate var titles = [String]()
    fileprivate var buttons = [UIButton]()
    fileprivate var markerLine = UIView()
    fileprivate var segmentView = UIView()
    fileprivate var segmetStackView = UIStackView()
    
    fileprivate var segment = UIView()
    fileprivate var selected = UIColor()
    fileprivate var normal = UIColor()
    fileprivate var lastButton = UIButton()
    
    private var segmentViewInVisible = NSLayoutConstraint()
    private var segmentViewVisible = NSLayoutConstraint()

    override func loadView() {
        super.loadView()
        
        segmentView = UIView(frame: .zero)
        segmentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(segmentView)
        
        segmetStackView = UIStackView(frame: CGRect.zero)
        segmetStackView.translatesAutoresizingMaskIntoConstraints = false
        segmetStackView.axis = .horizontal
        segmetStackView.distribution = .fillEqually
        segmentView.addSubview(segmetStackView)
        
        markerLine = UIView(frame: CGRect.zero)
        markerLine.translatesAutoresizingMaskIntoConstraints = false
        markerLine.backgroundColor = selected
        segmentView.addSubview(markerLine)
        
        segment = UIView(frame: CGRect.zero)
        segment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment)
        
        reloadData(with: controllers)
        
        setUpConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildWithoutAnimation(controllers[currentPoint])
    }
    
    convenience init(viewControllers: [UIViewController],
                     segmentH: CGFloat = 44.0,
                     startIndex: Int,
                     segmentColor: UIColor,
                     selectedColor: UIColor,
                     normalColor: UIColor,
                     font: UIFont? = nil) {
        self.init()
        
        selected = selectedColor
        normal = normalColor
        controllers = viewControllers
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        segmentView.isHidden = controllers.count <= 1
        
        segmentViewVisible.isActive = !segmentView.isHidden
        segmentViewInVisible.isActive = segmentView.isHidden
        
        let animation = CABasicAnimation(keyPath: "position")
        segment.layer.add(animation, forKey: "position")
        
        let markerOrigin = CGPoint(x: buttons[currentPoint].frame.origin.x,
                                   y: buttons[currentPoint].frame.origin.y + 40)
        let markerSize = CGSize(width: buttons[currentPoint].frame.width,
                                height: 4)
        markerLine.frame = CGRect(origin: markerOrigin, size: markerSize)
        markerLine.layer.add(animation, forKey: "position")
    }
    
    func setUpConstraints() {
        segmentViewVisible = segmentView.heightAnchor.constraint(equalToConstant: 44)
        segmentViewInVisible = segmentView.heightAnchor.constraint(equalToConstant: 0)
        
        segmentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        segmentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        segmentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        segmetStackView.topAnchor.constraint(equalTo: segmentView.topAnchor).isActive = true
        segmetStackView.bottomAnchor.constraint(equalTo: segmentView.bottomAnchor).isActive = true
        segmetStackView.leadingAnchor.constraint(equalTo: segmentView.leadingAnchor).isActive = true
        segmetStackView.trailingAnchor.constraint(equalTo: segmentView.trailingAnchor).isActive = true
        
        segment.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        segment.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        segment.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        segment.topAnchor.constraint(equalTo: segmentView.bottomAnchor).isActive = true
    
        markerLine.bottomAnchor.constraint(equalTo: segmentView.bottomAnchor).isActive = true
    }

    func setUpButton(index: Int, title: String) {
        let button = UIButton(type: .custom)
        button.frame = CGRect.zero
        button.tag = index
        button.titleLabel?.font = UIFont(name: "normal", size: 16)
        button.setTitle(title, for: .normal)
        button.setTitleColor(normal, for: .normal)
        button.setTitle(title, for: .selected)
        button.setTitleColor(selected, for: .selected)
        button.addTarget(self,
                         action: #selector(clickingSckrollViewButton(selectedButton:)),
                         for: UIControlEvents.touchUpInside)
        
        segmetStackView.addArrangedSubview(button)
        buttons.append(button)
        if currentPoint == index {
            button.isSelected = true
            lastButton = button
        }
    }
    
    func reloadData(with newControllers: [UIViewController]) {
        guard !controllers.isEmpty else { fatalError("cannot be empty") }
        segment.subviews.forEach{ $0.removeFromSuperview() }
        self.childViewControllers.forEach{
            $0.willMove(toParentViewController: nil)
            $0.removeFromParentViewController()
        }
        controllers = newControllers
        titles = newControllers.map { $0.title ?? "Description" }
        segmetStackView.subviews.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        titles.enumerated().forEach(setUpButton)
        

        view.setNeedsLayout()
    }
    
    @objc func clickingSckrollViewButton(selectedButton: UIButton) -> () {
        lastButton.isSelected = false
        currentPoint = selectedButton.tag
        selectedButton.setTitleColor(selected, for: .normal)
        for button in buttons {
            if button != selectedButton {
                button.setTitleColor(normal, for: .normal)
            }
        }
    }
}

extension SegmentView {
    
    fileprivate func addChildWithoutAnimation(_ newViewController: UIViewController) {
        newViewController.willMove(toParentViewController: self)
        self.addChildViewController(newViewController)
        segment.insertSubview(
            newViewController.view,
            belowSubview: self.segmentView
        )
    }
    
    fileprivate func updateCurrentVC(for index: Int, oldIndex: Int) {
        let newViewController = controllers[index]
        guard index != oldIndex else { return addChildWithoutAnimation(newViewController) }
        guard oldIndex < controllers.count else { return addChildWithoutAnimation(newViewController) }
        let viewControllerToRemove = controllers[oldIndex]
        let direction: Direction = index < oldIndex ? .left : .right
        
        animator(self, viewControllerToRemove, newViewController, direction)
    }
}
