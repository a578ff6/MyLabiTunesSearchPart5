//
//  StoreItemListTableViewController.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/13.
//

import UIKit

class StoreItemListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
