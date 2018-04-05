//
//  ViewController.swift
//  SegmentControllLib
//
//  Created by Andrey Doroshko on 3/29/18.
//  Copyright © 2018 Andrey Doroshko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var container: UIView!
    
    var segment: SegmentView!
    var viewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewController1 = FirstViewController()
        let viewController2 = SecondViewController()
        let viewController3 = UIViewController()
        
        viewControllers.append(viewController1)
        viewControllers.append(viewController2)
        viewControllers.append(viewController3)
        
        viewController1.title = "VC1"
        viewController2.title = "VC2"
        
        viewController3.view.backgroundColor = .blue
        
        segment = SegmentView(
            viewControllers: viewControllers,
            segmentH: 44.0,
            startIndex: 0,
            segmentColor: .black,
            selectedColor: .blue,
            normalColor: .brown,
            font: nil
        )
        
        
        segment.willMove(toParentViewController: self)
        self.addChildViewController(segment)
        container.addSubview(segment.view)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            var controllers = [UIViewController]()
//
//            let viewController1 = FirstViewController()
//            let viewController2 = SecondViewController()
//
//            viewController1.title = "newVC1"
//            viewController2.title = "newVC2"
//            
//            viewController1.view.backgroundColor = .yellow
//            viewController2.view.backgroundColor = .green
//
//            controllers.append(viewController1)
//            controllers.append(viewController2)
//            self.reloadData(controllers: controllers)
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            var controllers = [UIViewController]()
//
//            let viewController1 = FirstViewController()
//
//            viewController1.title = "newVC1"
//
//            controllers.append(viewController1)
//            self.reloadData(controllers: controllers)
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
//            var controllers = [UIViewController]()
//
//            let viewController1 = FirstViewController()
//            let viewController2 = SecondViewController()
//
//            viewController1.title = "newVC1"
//            viewController2.title = "newVC2"
//
//            controllers.append(viewController1)
//            controllers.append(viewController2)
//            self.reloadData(controllers: controllers)
//        }
    }
    
    func reloadData(controllers: [UIViewController]){
        viewControllers = controllers
        segment!.reloadData(with: viewControllers)
        view.layoutSubviews()
    }
}

//extension ViewController: SegmentDelegate {
//    func segmentViewDidSelected(segment: UIScrollView,
//                                index: NSInteger,
//                                sender: UIButton) {
//        print(index)
//        print(sender.titleLabel?.text ?? "")
//    }
//}
