//
//  FolioReaderBookmarkList.swift
//  EpubViewerKit
//
//  Created by Ajith Tom Jacob on 28/12/25.
//

import UIKit

class FolioReaderBookmarkList: UITableViewController {

    fileprivate var bookmarks = [Bookmark]()
    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader

    init(folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader

        super.init(style: UITableView.Style.plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kReuseCellIdentifier)
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundColor = self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, self.readerConfig.menuBackgroundColor)
        self.tableView.separatorColor = self.folioReader.isNight(self.readerConfig.nightModeSeparatorColor, self.readerConfig.menuSeparatorColor)

        guard let bookId = (self.folioReader.readerContainer?.book.name as NSString?)?.deletingPathExtension else {
            self.bookmarks = []
            return
        }

        self.bookmarks = Bookmark.allByBookId(withConfiguration: self.readerConfig, bookId: bookId)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseCellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.clear

        let bookmark = bookmarks[indexPath.row]

        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.readerConfig.localizedHighlightsDateFormat
        let dateString = dateFormatter.string(from: bookmark.date)

        // Date
        var dateLabel: UILabel!
        if cell.contentView.viewWithTag(456) == nil {
            dateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-40, height: 16))
            dateLabel.tag = 456
            dateLabel.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
            dateLabel.font = UIFont(name: "Avenir-Medium", size: 12)
            cell.contentView.addSubview(dateLabel)
        } else {
            dateLabel = cell.contentView.viewWithTag(456) as? UILabel
        }

        dateLabel.text = dateString.uppercased()
        dateLabel.textColor = self.folioReader.isNight(UIColor(white: 5, alpha: 0.3), UIColor.lightGray)
        dateLabel.frame = CGRect(x: 20, y: 20, width: view.frame.width-40, height: dateLabel.frame.height)
        // Name if it exists
        if let name = bookmark.bookmarkName {
            var nameLabel: UILabel!
            if cell.contentView.viewWithTag(889) == nil {
                nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-40, height: 0))
                nameLabel.tag = 889
                nameLabel.font = UIFont.systemFont(ofSize: 14)
                nameLabel.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
                nameLabel.numberOfLines = 3
                nameLabel.textColor = UIColor.gray
                cell.contentView.addSubview(nameLabel)
            } else {
                nameLabel = cell.contentView.viewWithTag(889) as? UILabel
            }
            
            nameLabel.text = name
            nameLabel.sizeToFit()
            nameLabel.frame = CGRect(x: 20, y: 46, width: view.frame.width-40, height: nameLabel.frame.height)
        } else {
            cell.contentView.viewWithTag(889)?.removeFromSuperview()
        }

        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bookmark = bookmarks[indexPath.row]

        var totalHeight = 66.0
        
        if let name = bookmark.bookmarkName {
            let nameLabel = UILabel()
            nameLabel.frame = CGRect(x: 20, y: 46 , width: view.frame.width-40, height: CGFloat.greatestFiniteMagnitude)
            nameLabel.text = name
            nameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            nameLabel.numberOfLines = 0
            nameLabel.font = UIFont.systemFont(ofSize: 14)
            
            nameLabel.sizeToFit()
            totalHeight += nameLabel.frame.height
        }

        return totalHeight
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bookmark = bookmarks[safe: indexPath.row] else { return }

        self.folioReader.readerCenter?.changePageWith(bookMark: bookmark)
        self.dismiss()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let bookmark = bookmarks[safe: indexPath.row] else { return }

            bookmark.remove(withConfiguration: self.readerConfig) // Remove from Database
            bookmarks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // MARK: - Handle rotation transition
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }

}
