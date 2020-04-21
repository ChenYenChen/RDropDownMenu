//
// Created by Ray on 2020/03/24.
//

import Foundation

public protocol RDropDownMenuDelegate: NSObjectProtocol {
    func menu(_ menu: RDropDownMenu, didSelectRowAtIndexPath indexPath: [RDropDownMenu.Index])
}
extension RDropDownMenuDelegate {
    func menu(_ menu: RDropDownMenu, didSelectRowAtIndexPath indexPath: [RDropDownMenu.Index]) { }
}
