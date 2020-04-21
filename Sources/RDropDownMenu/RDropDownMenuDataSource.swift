//
//  Created by Ray on 2020/3/24.
//

import UIKit

public protocol RDropDownMenuDataSource: NSObjectProtocol {
    /// 有多少個 column
    func numberOfColumns(_ menu: RDropDownMenu) -> Int
    
    /// 每個 column 有多少行
    func numberOfSections(_ menu: RDropDownMenu, inColumn column: Int) -> Int
    
    /// 某列的某行 item 的數量，數量大於 0 ，則有二三...級選單，反之亦然
    func numberOfSectionItems(_ menu: RDropDownMenu, inColumn column: Int, beforeSectionSelect: [RDropDownMenu.Index]) -> Int
    
    /// 每個 section 的 每個子項標題
    func textOfItem(_ menu: RDropDownMenu, inColumn column: Int, beforeSectionSelect: [RDropDownMenu.Index], inRow row: Int) -> String
    
    /// 第 column 列， 每個 section 的 每個子項圖片
    func imageOfItem(_ menu: RDropDownMenu, inColumn column: Int, beforeSectionSelect: [RDropDownMenu.Index], inRow row: Int) -> UIImage?
    
    /// 每 column 的預設標題
    func menu(_ menu: RDropDownMenu, defaultTitleAtColumn column: Int) -> String
}
extension RDropDownMenuDataSource {
    
    func numberOfColumns(_ menu: RDropDownMenu) -> Int { return 1 }
    
    func textOfItem(_ menu: RDropDownMenu, inColumn column: Int, beforeSectionSelect: [RDropDownMenu.Index], inRow row: Int) -> String { return "" }
    
    func imageOfItem(_ menu: RDropDownMenu, inColumn column: Int, beforeSectionSelect: [RDropDownMenu.Index], inRow row: Int) -> UIImage? { return nil }
    
    func menu(_ menu: RDropDownMenu, defaultTitleAtColumn column: Int) -> String { return "未知" }
}
