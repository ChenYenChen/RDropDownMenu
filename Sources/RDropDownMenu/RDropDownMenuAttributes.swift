//
//  File.swift
//  
//
//  Created by Ray on 2020/3/24.
//

import UIKit

/// 下拉選單屬性設定
public struct RDropDownMenuAttributes {
    /// 文字顏色
    var textColor: UIColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    /// 已選文字顏色
    var selectedTextColor: UIColor = #colorLiteral(red: 0.9647058824, green: 0.3098039216, blue: 0, alpha: 1)
    /// 選單文字顏色
    var detailTextColor: UIColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    /// 分隔線顏色
    var indicatorColor: UIColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    /// 選單文字大小
    var detailTextFontSize: CGFloat = 11
    /// 選單分隔線顏色
    var separatorColor = #colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1)
    
    var titleFontSize:CGFloat = 14
    /// 選單最大高度
    var tableViewHeight: CGFloat = 300
    /// 選單選項高度
    var cellHeight: CGFloat = 44
    
    init() { }
}
