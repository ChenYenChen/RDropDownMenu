//
// Created by Ray on 2020/03/24.
//

import UIKit

class RDropDownMenu: UIView {
    
    public class Index {
        /// 列
        var column: Int
        /// 行
        var section: Int
        /// 子項
        var row: Int
        
        init(column: Int, section: Int, row: Int = -1) {
            self.column = column
            self.section = section
            self.row = row
        }
    }
    /// 選單屬性
    public var attribute: RDropDownMenuAttributes = RDropDownMenuAttributes()
    public weak var delegate: RDropDownMenuDelegate?
    public var dataSource: RDropDownMenuDataSource?
    
    private var menuOrigin: CGPoint = .zero
    /// 選單選項
    private var currentSelectedRows: [Index] = []
    private var currentTitleLayers: [CATextLayer] = []
    private var currentIndicatorLayers: [CAShapeLayer] = []
    private var currentBgLayers: [CALayer] = []
    private var tempTableView: [UITableView] = []
    
    /// 目前選項
    private var currentSelectedColumn = -1
    /// 是否以顯示
    private var isShow: Bool = false
    // 動畫時間
    private let duration = 0.2
    // cell height
    private let cellHeight: CGFloat = 44
    
    /// 手機大小
    private lazy var screen: CGSize = UIScreen.main.bounds.size
    /// 背景覆蓋
    private lazy var backGroundView: UIView = {
        let view = UIView(frame: CGRect(x: menuOrigin.x, y: menuOrigin.y, width: screen.width, height: screen.height))
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        // 是否不透明
        view.isOpaque = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped(sender:))))
        return view
    }()
    
    private lazy var bottomLine: UIView = {
        let scale = UIScreen.main.scale
        let view = UIView(frame: CGRect(x: 0, y: self.frame.height - (1 / scale), width: self.screen.width, height: 1 / scale))
        view.backgroundColor = self.attribute.separatorColor
        view.isHidden = true
        return view
    }()
    
    // MARK: - init view
    private func initView() {
        self.backgroundColor = UIColor.white
        self.addSubview(self.bottomLine)
        
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(self.menuTap(_:)))
        self.addGestureRecognizer(menuTap)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }
    
    // MARK: - reload data
    func reloadData() {
        guard let source = self.dataSource else { return }
        // 列數
        let numberOfColumn = source.numberOfColumns(self)
        
        let menuHeight: CGFloat = self.frame.height
        
        /// 背景layer
        func creatBackgroundLayer(position: CGPoint, backgroundColor: UIColor) -> CALayer {
            let layer = CALayer()
            layer.position = position
            layer.backgroundColor = backgroundColor.cgColor
            layer.bounds = CGRect(x: 0, y: 0, width: self.screen.width / CGFloat(numberOfColumn), height: menuHeight - 1)
            return layer
        }
        /// 標題Layer
        func creatTitleLayer(text: String, position: CGPoint, textColor: UIColor) -> CATextLayer {
            // size
            let textSize = calculateStringSize(text)
            let maxWidth = self.screen.width / CGFloat(numberOfColumn) - 25
            let textLayerWidth = (textSize.width < maxWidth) ? textSize.width : maxWidth
            // textLayer
            let textLayer = CATextLayer()
            textLayer.bounds = CGRect(x: 0, y: 0, width: textLayerWidth, height: textSize.height)
            textLayer.fontSize = self.attribute.titleFontSize
            textLayer.string = text
            textLayer.alignmentMode = .center
            textLayer.truncationMode = .end
            textLayer.foregroundColor = self.attribute.textColor.cgColor
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.position = position
            return textLayer
        }
        /// indicatorLayer
        func creatIndicatorLayer(position: CGPoint, color: UIColor) -> CAShapeLayer {
            // path
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: 0))
            bezierPath.addLine(to: CGPoint(x: 5, y: 5))
            bezierPath.move(to: CGPoint(x: 5, y: 5))
            bezierPath.addLine(to: CGPoint(x: 10, y: 0))
            bezierPath.close()
            // shapeLayer
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = bezierPath.cgPath
            shapeLayer.lineWidth = 0.8
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.bounds = shapeLayer.path!.boundingBox
            shapeLayer.position = position
            return shapeLayer
        }
        /// separatorLayer
        func creatSeparatorLayer(position: CGPoint, color: UIColor) -> CAShapeLayer {
            // path
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: 0))
            bezierPath.addLine(to: CGPoint(x: 0, y: menuHeight - 16))
            bezierPath.close()
            // separatorLayer
            let separatorLayer = CAShapeLayer()
            separatorLayer.path = bezierPath.cgPath
            separatorLayer.strokeColor = color.cgColor
            separatorLayer.lineWidth = 1
            separatorLayer.bounds = separatorLayer.path!.boundingBox
            separatorLayer.position = position
            return separatorLayer
        }
        
        var maxSection: Int = 0
        
        // 目前選擇
        (0..<numberOfColumn).forEach { column in
            let numberOfSection = source.numberOfSections(self, inColumn: column)
            
            if maxSection < numberOfColumn {
                maxSection = numberOfColumn
            }
            
            var defaultSelect: [Index] = []
            
            (0..<numberOfSection).forEach { (section) in
                var index: Index!
                let count = source.numberOfSectionItems(self, inColumn: column, beforeSectionSelect: defaultSelect)
                
                if count > 0 {
                    index = Index(column: column, section: section, row: 0)
                    defaultSelect.append(index)
                } else {
                    index = Index(column: column, section: section)
                }
                self.currentSelectedRows.append(index)
            }
        }
        
        self.tempTableView.removeAll()
        
        
        let backgroundLayerWidth = self.screen.width / CGFloat(numberOfColumn)
        
        self.currentBgLayers.removeAll()
        self.currentTitleLayers.removeAll()
        self.currentIndicatorLayers.removeAll()
        
        // 建立 table view
        (0..<maxSection).forEach { section in
            let table = self.createTableView(as: section)
            self.tempTableView.append(table)
        }
        
        // 建立 column
        (0..<numberOfColumn).forEach { (index) in
            let row = CGFloat(index)
            
            // backgroundLayer
            let backgroundLayerPosition = CGPoint(x: (row + 0.5) * backgroundLayerWidth, y: menuHeight * 0.5)
            let backgroundLayer = creatBackgroundLayer(position: backgroundLayerPosition, backgroundColor: UIColor.white)
            self.layer.addSublayer(backgroundLayer)
            
            // titleLayer
            var titleStr: String!
            
            let sections = self.currentSelectedRows.filter({ $0.column == index })
            
            if let lastSection = sections.last(where: { $0.row != -1 }) {
                let defaultSelect = (0..<lastSection.section).compactMap({ Index(column: index, section: $0, row: 0) })
                titleStr = source.textOfItem(self, inColumn: index, beforeSectionSelect: defaultSelect, inRow: 0)
            } else {
                titleStr = source.menu(self, defaultTitleAtColumn: index)
            }
            
            let titleLayerPosition = CGPoint(x: (row + 0.5) * backgroundLayerWidth, y: menuHeight * 0.5)
            let titleLayer = creatTitleLayer(text: titleStr, position: titleLayerPosition, textColor: self.attribute.textColor)
            self.layer.addSublayer(titleLayer)
            self.currentTitleLayers.append(titleLayer)
            
            // indicatorLayer
            let textSize = calculateStringSize(titleStr)
            let indicatorLayerPosition = CGPoint(x: titleLayerPosition.x + (textSize.width / 2) + 10, y: menuHeight / 2 + 2)
            let indicatorLayer = creatIndicatorLayer(position: indicatorLayerPosition, color: self.attribute.textColor)
            self.layer.addSublayer(indicatorLayer)
            self.currentIndicatorLayers.append(indicatorLayer)
            
            // separatorLayer
            if index != numberOfColumn - 1 {
                let separatorLayerPosition = CGPoint(x: ceil((row + 1) * backgroundLayerWidth) - 1, y: menuHeight / 2)
                let separatorLayer = creatSeparatorLayer(position: separatorLayerPosition, color: self.attribute.separatorColor)
                self.layer.addSublayer(separatorLayer)
            }
        }
        
        self.bottomLine.isHidden = false
    }
    
    // MARK: - tap action
    
    // FIXME: - background view tap action
    @objc private func backTapped(sender: UITapGestureRecognizer) {
        self.animate(show: false)
    }
    // FIXME: - menu tap action
    @objc private func menuTap(_ sender: UITapGestureRecognizer) {
        guard let source = self.dataSource else { return }
        
        // 列數
        let numberOfColumn = source.numberOfColumns(self)
        
        // 確認點擊的index
        let tapPoint = sender.location(in: self)
        let tapIndex: Int = Int(tapPoint.x / (self.screen.width / CGFloat(numberOfColumn)))
        
        // 收回其他的 column 的 menu
        (0..<numberOfColumn).forEach { (index) in
            if index != tapIndex {
                self.animate(indicator: self.currentIndicatorLayers[index], reverse: false, complete: {
                    self.changeTitleLayer(self.currentTitleLayers[index], indicator: nil, show: false)
                })
            }
        }
        
        // 收回當前的 menu
        if self.currentSelectedColumn == tapIndex && self.isShow {
            // 收回menu
            self.animate(show: false)
            
        } else if self.currentSelectedColumn != tapIndex && self.isShow {
            self.currentSelectedColumn = tapIndex
            // 载入數據
            let selectColumn = self.currentSelectedRows.filter({ $0.column == tapIndex })
            
            var befaultSelect: [Index] = []
            selectColumn.forEach { index in
                if source.numberOfSectionItems(self, inColumn: tapIndex, beforeSectionSelect: befaultSelect) > 0 {
                    befaultSelect.append(index)
                    self.tempTableView[index.section].reloadData()
                }
            }
            self.animate(indicator: self.currentIndicatorLayers[tapIndex], reverse: true, complete: {
                self.changeTitleLayer(self.currentTitleLayers[tapIndex], indicator: nil, show: true)
                self.animateTableView(show: true)
            })
            
        } else {
            // 彈出menu
            self.currentSelectedColumn = tapIndex
            // 载入數據
            let selectColumn = self.currentSelectedRows.filter({ $0.column == tapIndex })
            
            var befaultSelect: [Index] = []
            selectColumn.forEach { index in
                if source.numberOfSectionItems(self, inColumn: tapIndex, beforeSectionSelect: befaultSelect) > 0 {
                    befaultSelect.append(index)
                    self.tempTableView[index.section].reloadData()
                }
            }
            
            self.animate(show: true)
        }
    }
    
    // MARK: - create tableview
    private func createTableView(as section: Int) -> UITableView {
        let table = UITableView(frame: .zero)
        table.isHidden = true
        table.tag = section
        table.dataSource = self
        table.delegate = self
        table.layer.borderWidth = 0.5
        table.layer.borderColor = self.attribute.separatorColor.cgColor
        return table
    }
    
    
    // MARK: - animation
    private func animate(show: Bool) {
        let indicator = self.currentIndicatorLayers[self.currentSelectedColumn]
        self.animate(indicator: indicator, reverse: show) {
            self.changeTitleLayer(self.currentTitleLayers[self.currentSelectedColumn], indicator: indicator, show: show)
            self.animateForBackgroundView(show: show) {
                self.animateTableView(show: show)
            }
        }
        self.isShow = show
    }
    //FIXME: - 箭頭 動畫
    private func animate(indicator: CAShapeLayer, reverse: Bool, complete: @escaping (() -> Void)) {
        indicator.transform = reverse ? CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1) : CATransform3DIdentity
        indicator.strokeColor = reverse ? self.attribute.selectedTextColor.cgColor : self.attribute.textColor.cgColor
        complete()
    }
    
    //FIXME: - backgroundView 動畫
    private func animateForBackgroundView(show: Bool, complete: @escaping (() -> Void)) -> Void {
        
        if show {
            self.superview?.addSubview(self.backGroundView)
            self.superview?.addSubview(self)
            UIView.animate(withDuration: self.duration, animations: {
                self.backGroundView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            })
        }else {
            UIView.animate(withDuration: self.duration, animations: {
                self.backGroundView.backgroundColor = UIColor(white: 0, alpha: 0)
            }, completion: { (finished) in
                self.backGroundView.removeFromSuperview()
            })
        }
        complete()
    }
    
    // FIXME: - tableView動畫
    private func animateTableView(show: Bool) {
        
        if show {
            guard let source = self.dataSource else { return }
            let maxHeight = screen.height - self.frame.maxY
            let selects = self.currentSelectedRows.filter({ $0.column == self.currentSelectedColumn && $0.row > -1 })
            
            var temp: [(table: UITableView, width: CGFloat, height: CGFloat)] = []
            let tableWidth: CGFloat = screen.width / CGFloat(selects.count)
            var befortSelect: [Index] = []
            selects.forEach { (index) in
                let table = self.tempTableView[index.section]
                table.frame.origin = CGPoint(x: tableWidth * CGFloat(index.section), y: self.frame.origin.y + self.frame.height)
                let row = source.numberOfSectionItems(self, inColumn: self.currentSelectedColumn, beforeSectionSelect: befortSelect)
                let totalHeight = CGFloat(row) * self.cellHeight
                let height = totalHeight < maxHeight ? totalHeight : maxHeight
                temp.append((table, tableWidth, height))
                befortSelect.append(index)
                if table.isHidden {
                    table.isHidden = false
                    superview?.addSubview(table)
                }
            }
            
            (selects.count..<self.tempTableView.count).forEach { row in
                let table = self.tempTableView[row]
                table.isHidden = true
                table.removeFromSuperview()
            }
            
            UIView.animate(withDuration: self.duration) {
                temp.forEach { (sender) in
                    sender.table.frame.size.width = sender.width
                    sender.table.frame.size.height = sender.height
                }
            }
        } else {
            self.tempTableView.forEach { (table) in
                UIView.animate(withDuration: self.duration, animations: {
                    table.frame.size.height = 0
                }, completion: { _ in
                    table.isHidden = true
                    table.removeFromSuperview()
                })
            }
        }
    }
    //FIXME: - titleLayer 變化
    private func changeTitleLayer(_ textLayer: CATextLayer, indicator: CAShapeLayer?, show: Bool) {
        guard let source = self.dataSource else { return }
        // 列數
        let numberOfColumn = source.numberOfColumns(self)
        let textSize = self.calculateStringSize((textLayer.string as? String) ?? "")
        let maxWidth = self.screen.width / CGFloat(numberOfColumn) - CGFloat(25.0)
        let textLayerWidth = (textSize.width < maxWidth) ? textSize.width : maxWidth
        textLayer.bounds.size.width = textLayerWidth
        textLayer.bounds.size.height = textSize.height
        
        if let indicatorR = indicator {
            indicatorR.position.x = textLayer.position.x + (textLayerWidth / 2) + 10
        }
        
        textLayer.foregroundColor = show ? self.attribute.selectedTextColor.cgColor : self.attribute.textColor.cgColor
    }
    // MARK: - 計算文字大小
    private func calculateStringSize(_ string: String) -> CGSize {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.attribute.titleFontSize)]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let size = string.boundingRect(with: CGSize(width: 280, height: 0), options: option, attributes: attributes, context: nil).size
        return CGSize(width: ceil(size.width) + 5, height: size.height)
    }
}
extension RDropDownMenu: UITableViewDataSource {
    // MARK: - Table view dataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let source = self.dataSource else { return 0 }
        let beforeSelect = self.currentSelectedRows.filter({ $0.section < tableView.tag && $0.column == self.currentSelectedColumn })
        return source.numberOfSectionItems(self, inColumn: self.currentSelectedColumn, beforeSectionSelect: beforeSelect)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "dropDownCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
            cell.textLabel?.textColor = self.attribute.textColor
            cell.textLabel?.highlightedTextColor = self.attribute.selectedTextColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: self.attribute.titleFontSize)
            cell.detailTextLabel?.textColor = self.attribute.detailTextColor
            cell.detailTextLabel?.highlightedTextColor = self.attribute.selectedTextColor
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: self.attribute.detailTextFontSize)
            cell.imageView?.contentMode = .scaleAspectFit
        }
        
        guard let source = self.dataSource else { return cell }
        var beforeSelect = self.currentSelectedRows.filter({ $0.section < tableView.tag && $0.column == self.currentSelectedColumn })
        cell.textLabel?.text = source.textOfItem(self, inColumn: self.currentSelectedColumn, beforeSectionSelect: beforeSelect, inRow: indexPath.row)
        cell.imageView?.image = source.imageOfItem(self, inColumn: self.currentSelectedColumn, beforeSectionSelect: beforeSelect, inRow: indexPath.row)
        
        if let _ = self.currentSelectedRows.first(where: { $0.column == self.currentSelectedColumn && $0.section == tableView.tag && $0.row == indexPath.row }) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        beforeSelect.append(Index(column: self.currentSelectedColumn, section: tableView.tag, row: indexPath.row))
        let hasNextItem = source.numberOfSectionItems(self, inColumn: self.currentSelectedColumn, beforeSectionSelect: beforeSelect) > 0
        cell.accessoryType = hasNextItem ? .disclosureIndicator : .none
        
        return cell
    }
}
extension RDropDownMenu: UITableViewDelegate {
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let source = self.dataSource else { return }
        let columns = self.currentSelectedRows.filter({ $0.column == self.currentSelectedColumn })
        guard let section = columns.first(where: { $0.section == tableView.tag }) else { return }
        
        // final select action
        func finalSelect() {
            var selects = self.currentSelectedRows.filter({ $0.column == self.currentSelectedColumn && $0.row > -1 })
            
            if let last = selects.last {
                let titleLayer = self.currentTitleLayers[self.currentSelectedColumn]
                selects.removeLast()
                titleLayer.string = source.textOfItem(self, inColumn: self.currentSelectedColumn, beforeSectionSelect: selects, inRow: last.row)
                self.changeTitleLayer(titleLayer, indicator: self.currentIndicatorLayers[self.currentSelectedColumn], show: true)
            }
            
            guard selects.count == tableView.tag else { return }
            self.animate(show: false)
        }
        
        guard section.row != indexPath.row else {
            finalSelect()
            return
        }
        section.row = indexPath.row
        var beforeSelect: [Index] = columns.filter({ $0.section <= tableView.tag })
        var nextSection = tableView.tag
        var count = source.numberOfSectionItems(self, inColumn: self.currentSelectedColumn, beforeSectionSelect: beforeSelect)
        
        if count != 0 {
            repeat {
                nextSection = nextSection + 1
                columns.first(where: { $0.section == nextSection })?.row = 0
                self.tempTableView[nextSection].reloadData()
                beforeSelect.append(Index(column: self.currentSelectedColumn, section: nextSection, row: 0))
                count = source.numberOfSectionItems(self, inColumn: self.currentSelectedColumn, beforeSectionSelect: beforeSelect)
            } while count != 0
        }
        
        columns.filter({ $0.section > nextSection }).forEach({ $0.row = -1 })
        
        
        self.animateTableView(show: true)
        
        finalSelect()
    }
}
