//
//  ViewContronller+Extension.swift
//  HDDev
//
//  Created by Harsh Duggal on 24/08/24.
//

import Foundation

import UIKit
import FirebaseAnalytics

extension UIViewController {
    /// Tracks the screen view event using Firebase Analytics.
    /// - Parameters:
    ///   - screenName: Custom name for the screen. If not provided, the view controller's class name is used.
    ///   - screenClass: Optional custom class name. Defaults to the view controller's class.
    func trackScreenView(screenName: String? = nil, screenClass: String? = nil) {
        let name = screenName ?? String(describing: type(of: self))
        let className = screenClass ?? String(describing: type(of: self))

        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name,
            AnalyticsParameterScreenClass: className
        ])
    }
    /// Returns the name of the current screen, which is the view controller's class name.
     var currentScreenName: String {
         return String(describing: type(of: self))
     }

     /// Returns the class name of the current screen.
     var currentScreenClass: String {
         return NSStringFromClass(type(of: self))
     }
    /// Logs the screen view event using Firebase Analytics.
      func logScreenViewEvent() {
          print("FireBase Log: CSreenName \(currentScreenName), CScreenClass: \(currentScreenClass)")
          Analytics.logEvent(AnalyticsEventScreenView, parameters: [
              AnalyticsParameterScreenName: currentScreenName,
              AnalyticsParameterScreenClass: currentScreenClass
          ])
      }
}

extension UIViewController {
    // Swizzle the `viewDidAppear` method
    static let swizzleViewDidAppear: Void = {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))// original fuinction
        let swizzledSelector = #selector(swizzled_viewDidAppear(_:))// Swizzled Function
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else { return}
        method_exchangeImplementations(originalMethod, swizzledMethod)// Swicth the functions
    }()
    
    // New implementation of `viewDidAppear`
    @objc func swizzled_viewDidAppear(_ animated: Bool) {
        swizzled_viewDidAppear(animated)// Call the original `viewDidAppear` (actually the swizzled method)
        logScreenViewEvent()// Log the screen view event
    }
}

// Ensure swizzling happens at app launch
extension UIApplication {
    private static let runOnce: Void = {
        UIViewController.swizzleViewDidAppear
    }()
    
    override open var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }
}
