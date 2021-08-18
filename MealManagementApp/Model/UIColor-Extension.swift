//
//  UIColor-Extension.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/12.
//

import UIKit
extension UIColor{
    static func rgb(red:CGFloat,green:CGFloat,blue:CGFloat) -> UIColor{
        return self.init(red:red / 255, green:green / 255, blue:blue / 255, alpha: 1)
    }
}

