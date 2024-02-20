//
//  UINavigationBar+extension.swift
//  CoreDataListDemo
//
//  Created by ashley canty on 2/19/24.
//

import UIKit


extension UIViewController {
    
    func setNavigationBarColors(backgroundColor: UIColor = UIColor.white.withAlphaComponent(0.5),
                                tintColor: UIColor = UIColor.systemBlue,
                                titleTextColor: UIColor = UIColor.black,
                                largeTitleColor: UIColor = UIColor.black) {
            
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : titleTextColor]
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : largeTitleColor]
        
        if let navSelf = self as? UINavigationController {
            applyNavBarAppearance(to: navSelf.navigationBar, appearance: appearance, tintColor: tintColor)
        } else {
            applyNavBarAppearance(to: navigationController?.navigationBar, appearance: appearance,tintColor: tintColor)
        }
    }
    
    fileprivate func applyNavBarAppearance(to navBar: UINavigationBar?, appearance: UINavigationBarAppearance, tintColor: UIColor) {
        navBar?.standardAppearance = appearance
        navBar?.compactAppearance = appearance
        navBar?.scrollEdgeAppearance = appearance
        navBar?.tintColor = tintColor
    }
}
