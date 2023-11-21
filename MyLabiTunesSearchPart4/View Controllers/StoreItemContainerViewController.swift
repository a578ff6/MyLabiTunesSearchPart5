//
//  StoreItemContainerViewController.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/13.
//

/*
import UIKit

// 包含「TableView」和「CollectionView」的ViewController
class StoreItemContainerViewController: UIViewController {
    
    // 分別對應表格和集合的容器視圖
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var collectionContainerView: UIView!
    
    struct PropertyKeys {
        static let itemCell = "ItemCell"                                 // 用於識別表格視圖中的cell。
        static let itemCollectionViewCell = "ItemCollectionViewCell"     // 用於識別集合視圖中的cell。
    }
    
    /// 代表 TableView 或 CollectionView 的不同部分
    enum Section: CaseIterable {
        case results
    }
    
    /// 用於管理和更新 tableViewDataSource、collectionViewDataSource 的資料來源。
    var tableViewDataSource: UITableViewDiffableDataSource<Section, StoreItem>!
    var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, StoreItem>!
    
    // searchController 和 storeItemController 的實例
    let searchController = UISearchController()
    let storeItemController = StoreItemController()
    
    /// 用於儲存從 iTunes API 獲取的項目
    var items = [StoreItem]()
    /// 定義查詢選項
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    /// 用於描述 UITableView 或 UICollectionView 的資料來源（dataSource）的當前狀態，包括其包含的區段和項目。
    var itemsSnapshot: NSDiffableDataSourceSnapshot<Section, StoreItem> {
        // 建立新的 Diffable 資料來源快照（Snapshot），用於描述資料的當前狀態
        var snapshot = NSDiffableDataSourceSnapshot<Section, StoreItem>()
        
        // 為快照添加 "results" 的新區段（Section）
        snapshot.appendSections([.results])
        // 在這個區段下添加 items 陣列中的所有項目
        snapshot.appendItems(items, toSection: Section.results)
        
        return snapshot
    }
    
     
    // 用於處理異步任務
    var searchTask: Task<Void, Never>? = nil
    var tableViewImageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    var collectionViewImageLoadTasks: [IndexPath: Task<Void, Never>] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 配置 searchController 的相關設置
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["Movies", "Music", "Apps", "Books"]

    }
    
    // 切換顯示的容器視圖（表格或集合）
    @IBAction func switchContainerView(_ sender: UISegmentedControl) {
        tableContainerView.isHidden.toggle()
        collectionContainerView.isHidden.toggle()
    }
    
    
    // 用於根據「搜索條件」獲取對應的項目。這個方法首先重置當前的項目列表，然後根據用戶的搜索條件從iTunes API請求數據。
    @objc func fetchMatchingItems() {
        
        self.items = []     // 重置當前項目列表。
        
        // 從 searchController 的「earchBar獲取用戶輸入的搜索關鍵詞」和「選定的媒體類型」。
        let searchTerm = searchController.searchBar.text ?? ""
        let mediaType = queryOptions[searchController.searchBar.selectedScopeButtonIndex]
        
        // 取消任何仍在獲取中的圖片並重置圖片任務字典
        tableViewImageLoadTasks.values.forEach { task in task.cancel() }
        tableViewImageLoadTasks = [:]
        
        collectionViewImageLoadTasks.values.forEach { task in task.cancel() }
        collectionViewImageLoadTasks = [:]
        
        // 取消現有的搜索任務
        searchTask?.cancel()
        searchTask = Task {
            if !searchTerm.isEmpty {
                /// 設置查詢條件
                let query = [
                    "term": searchTerm,
                    "media": mediaType,
                    "lang": "en_us",
                    "limit": "20"
                ]
                
                // 使用 storeItemController 發送查詢請求，並處理返回的數據。
                do {
                    let items = try await storeItemController.fetchItems(matching: query)
                    // 確保當結果返回時，用戶的搜索條件沒有改變。
                    if searchTerm == self.searchController.searchBar.text &&
                        mediaType == queryOptions[searchController.searchBar.selectedScopeButtonIndex] {
                        self.items = items
                    }
                    
                } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    // 若請求被取消，則不進行任何操作。
                } catch {
                    print(error)
                }
                // 更新表格視圖的資料來源，並應用動畫。
                await tableViewDataSource.apply(self.itemsSnapshot, animatingDifferences: true)
                await collectionViewDataSource.apply(self.itemsSnapshot, animatingDifferences: true)
            } else {
                // 若搜索條件為空，則直接更新空的資料來源。
                await self.tableViewDataSource.apply(self.itemsSnapshot, animatingDifferences: true)
                await self.collectionViewDataSource.apply(self.itemsSnapshot, animatingDifferences: true)
            }
            searchTask = nil        // 重置搜索任務。
        }
    }
    
    /// 配置「表格視圖」的資料來源。
    func configureTableViewDataSource(_ tableView: UITableView) {
        // 創建 TableViewDiffableDataSource
        tableViewDataSource = UITableViewDiffableDataSource<Section, StoreItem>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            // 嘗試從重用池中取得並配置表格的 cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.itemCell, for: indexPath) as? ItemTableViewCell else {
                fatalError("Unable to dequeue ItemTableViewCell")
            }
            
            // 取消之前的圖片加載任務，避免重複加載
            self.tableViewImageLoadTasks[indexPath]?.cancel()
            // 建立一個新的加載圖片的任務
            self.tableViewImageLoadTasks[indexPath] = Task {
                cell.titleLabel.text = item.name
                cell.detailLabel.text = item.artist
                // 預設圖片，等待實際圖片加載完成後替換
                cell.itemImageView.image = UIImage(systemName: "photo")
                
                do {
                    // 嘗試加載並顯示實際圖片
                    let image = try await self.storeItemController.fetchImage(from: item.artworkURL)
                    cell.itemImageView.image = image
                } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    // 如果是因為任務取消而產生錯誤，則忽略
                } catch {
                    cell.itemImageView.image = UIImage(systemName: "photo")
                    print("Error fetching image: \(error)")
                }
                // 清除該 indexPath 的圖片加載任務
                self.tableViewImageLoadTasks[indexPath] = nil
            }
            // 返回配置好的 cell
            return cell
        })
    }
    
    /// 配置「集合視圖」的資料來源。
    func configureCollectionViewDataSource(_ collectionView: UICollectionView) {
        // 設置 collectionViewDataSource。負責為每個集合視圖項目提供一個cell。
        collectionViewDataSource = UICollectionViewDiffableDataSource<Section, StoreItem>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PropertyKeys.itemCollectionViewCell, for: indexPath) as? ItemCollectionViewCell else {
                fatalError("Unable to dequeue ItemCollectionViewCell")
            }
            
            // 取消之前可能正在進行的圖片加載任務。
            self.collectionViewImageLoadTasks[indexPath]?.cancel()
            // 開始一個新的圖片加載任務。
            self.collectionViewImageLoadTasks[indexPath] = Task {
                cell.titleLabel.text = item.name
                cell.detailLabel.text = item.artist
                // 初始設置圖片為預設的系統圖片。
                cell.itemImageView.image = UIImage(systemName: "photo")
                
                do {
                    let image = try await self.storeItemController.fetchImage(from: item.artworkURL)
                    cell.itemImageView.image = image
                } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    // 如果是因為任務取消而產生錯誤，則忽略
                } catch {
                    cell.itemImageView.image = UIImage(systemName: "photo")
                    print("Error fetching image: \(error)")
                }
                // 清除引用，表示圖片加載任務已完成或取消。
                self.collectionViewImageLoadTasks[indexPath] = nil
            }
            
            return cell
        })
    }
    

    // 配置轉場
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableViewController = segue.destination as? StoreItemListTableViewController {
            configureTableViewDataSource(tableViewController.tableView)
        }
        
        if let collectionViewController = segue.destination as? StoreItemCollectionViewController {
            configureCollectionViewDataSource(collectionViewController.collectionView)
        }
    }
    
}

// 擴展 StoreItemContainerViewController 來實現 UISearchResultsUpdating 協議
extension StoreItemContainerViewController: UISearchResultsUpdating {
    
    // 當搜索條件變更時，更新搜索結果
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchMatchingItems), object: nil)
        perform(#selector(fetchMatchingItems), with: nil, afterDelay: 0.3)
    }
}

*/



// MARK: - 重構
import UIKit

// 包含「表格」和「集合」的ViewController
@MainActor
class StoreItemContainerViewController: UIViewController {
    
    // MARK: - Outlets
    // 分別對應表格和集合的容器視圖
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var collectionContainerView: UIView!
    
    // MARK: - Properties
    struct PropertyKeys {
        static let itemCell = "ItemCell"                                 // 用於識別表格視圖中的cell。
        static let itemCollectionViewCell = "ItemCollectionViewCell"     // 用於識別集合視圖中的cell。
    }
    
    // searchController 和 storeItemController 的實例
    let searchController = UISearchController()
    let storeItemController = StoreItemController()
    
    /// 用於管理和更新 tableViewDataSource、collectionViewDataSource 的資料來源。
    var tableViewDataSource: StoreItemTableViewDiffableDataSource!
    var collectionViewDataSource: UICollectionViewDiffableDataSource<String, StoreItem>!
    
    /// 用於儲存從 iTunes API 獲取的項目
    var items = [StoreItem]()
    
    /// 用於判斷當前選擇的「搜尋範圍」
    var selectedSearchScope: SearchScope {
        // 從searchBar的 scope 按鈕索引中取得當前選擇的索引值
        let selectedIndex = searchController.searchBar.selectedScopeButtonIndex
        // 根據索引值從 SearchScope 的所有案例中選擇對應的搜尋範圍
        let searchScope = SearchScope.allCases[selectedIndex]
        
        return searchScope
    }
    
    /// 引用集合視圖控制器
    weak var collectionViewController: StoreItemCollectionViewController?
    
    // MARK: - Asynchronous Tasks
    // 用於處理異步任務
    var searchTask: Task<Void, Never>? = nil
    var tableViewImageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    var collectionViewImageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    
    // MARK: - Data Source Snapshot
    /// 用於管理數據源快照
    var itemsSnapshot = NSDiffableDataSourceSnapshot<String, StoreItem>()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration()
    }
    
    // MARK: - Actions
    // 切換顯示的容器視圖（表格或集合）
    @IBAction func switchContainerView(_ sender: UISegmentedControl) {
        tableContainerView.isHidden.toggle()
        collectionContainerView.isHidden.toggle()
    }
    
    // MARK: - Configuration
    /// 配置 searchController 的相關設置
    private func configuration() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchBar.showsScopeBar = true
        // 設置searchBar的範圍按鈕標題
        searchController.searchBar.scopeButtonTitles = SearchScope.allCases.map({ $0.title })
    }
    

    // MARK: - Data Fetching

    // 用於根據「搜索條件」獲取對應的項目。這個方法首先重置當前的項目列表，然後根據用戶的搜索條件從iTunes API請求數據。
    @objc func fetchMatchingItems() {
        
        // 清空 itemsSnapshot
        itemsSnapshot.deleteAllItems()
        
        /// 從 searchController 的「searchBar獲取用戶輸入的搜索關鍵詞」。
        let searchTerm = searchController.searchBar.text ?? ""
        
        /// 如果選擇的搜索範圍為「全部」，則查詢所有類型；否則僅查詢選定的類型
        let searchScopes: [SearchScope]
        if selectedSearchScope == .all {
            searchScopes = [.movies, .music, .apps, .books]
        } else {
            searchScopes = [selectedSearchScope]
        }
        
        // 取消任何仍在獲取中的圖片並重置圖片任務字典
        tableViewImageLoadTasks.values.forEach { task in task.cancel() }
        tableViewImageLoadTasks = [:]
        collectionViewImageLoadTasks.values.forEach { task in task.cancel() }
        collectionViewImageLoadTasks = [:]
        
        // 取消現有的搜索任務
        searchTask?.cancel()
        // 在查詢過程中，如果用戶更改了搜索條件，則取消當前的搜索任務並重置
        searchTask = Task {
            if !searchTerm.isEmpty {
                do {
                    // 使用 storeItemController 向 iTunes API 發送請求，根據 searchScopes 和 searchTerm 獲取數據。
                    try await fetchAndHandleItemsForSearchScopes(searchScopes, withSearchTerm: searchTerm)
                } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    // 忽略由 URLSession 引起的取消錯誤。
                } catch is CancellationError {
                    // 忽略由 TaskGroup 引起的取消錯誤。
                } catch {
                    print(error)
                }
            } else {
                // 若搜索條件為空（searchTerm 為空），則不執行搜索，直接更新界面以顯示空的數據集。
                await self.tableViewDataSource.apply(self.itemsSnapshot, animatingDifferences: true)
                await self.collectionViewDataSource.apply(self.itemsSnapshot, animatingDifferences: true)
            }
            searchTask = nil        // 重置搜索任務。
        }
    }
    
    /// 更新異步獲取的項目到視圖的數據源，並應用到表格和集合視圖
    func handleFetchedItems(_ items: [StoreItem]) async {
        /// 先取得當前快照中的項目標識符
        let currentSnapshotItems = itemsSnapshot.itemIdentifiers
        
        /// 結合原有快照項目和新獲取的項目，創建一個更新後的快照。使用 createSectionedSnapshot 來根據項目類型生成分區
        let updatedSnapshot = createSectionedSnapshot(from: currentSnapshotItems + items)
        
        // 更新 itemsSnapshot 為最新的快照
        itemsSnapshot = updatedSnapshot
        
        // 設定集合視圖的布局配置，根據當前選擇的搜尋範圍進行調整
        collectionViewController?.configureCollectionViewLayout(for: selectedSearchScope)
        
        // 異步更新表格視圖和集合視圖的數據源，並啟用動畫效果
        await tableViewDataSource.apply(itemsSnapshot, animatingDifferences: true)
        await collectionViewDataSource.apply(itemsSnapshot, animatingDifferences: true)
    }
    
    /// 針對指定的「搜尋範圍」和「搜尋詞」進行異步查詢，並處理返回的結果。
    /// - Parameters:
    ///   - searchScopes: 要查詢的搜尋範圍陣列。
    ///   - searchTerm: 使用者輸入的搜尋關鍵詞。
    /// - Throws: 異步查詢過程中可能產生的錯誤。
    func fetchAndHandleItemsForSearchScopes(_ searchScopes: [SearchScope], withSearchTerm searchTerm: String) async throws {
        try await withThrowingTaskGroup(of: (SearchScope, [StoreItem]).self) { group in
            // 遍歷每個搜尋範圍，為每個範圍創建一個異步查詢任務。
            for searchScope in searchScopes {
                group.addTask {
                    try Task.checkCancellation()
                    
                    /// 設置查詢條件
                    let query = [
                        "term": searchTerm,
                        "media": searchScope.mediaType,
                        "lang": "en_us",
                        "limit": "20"
                    ]
                    // 執行查詢並返回結果。
                    return (searchScope, try await self.storeItemController.fetchItems(matching: query))
                }
            }
            
            // 處理每個異步任務的返回結果。
            for try await (searchScope, items) in group {
                try Task.checkCancellation()
                
                // 確認搜尋詞仍然符合當前輸入，並處理對應的搜尋範圍的結果。
                if searchTerm == self.searchController.searchBar.text &&
                    (self.selectedSearchScope == .all || searchScope == self.selectedSearchScope) {
                    await handleFetchedItems(items)
                }
            }
        }
    }
    
    /// 搜尋結果分別顯示在不同的區段
    func createSectionedSnapshot(from items: [StoreItem]) -> NSDiffableDataSourceSnapshot<String, StoreItem> {
        
        // 根據kind值篩選出不同類型的媒體
        let movies = items.filter { $0.kind == "feature-movie" }
        let music = items.filter { $0.kind == "song" || $0.kind == "album" }
        let apps = items.filter { $0.kind == "software" }
        let books = items.filter { $0.kind == "ebook" }
        
        // 將篩選後的項目根據類別分組
        let grouped: [(SearchScope, [StoreItem])] = [
            (.movies, movies),
            (.music, music),
            (.apps, apps),
            (.books, books)
        ]
        
        // 建立 Diffable Data Source 快照
        var snapshot = NSDiffableDataSourceSnapshot<String, StoreItem>()
        // 對每組類別進行迭代，將其加入到快照中
        grouped.forEach { (scope, items) in
            if items.count > 0 {
                snapshot.appendSections([scope.title])
                snapshot.appendItems(items, toSection: scope.title)
            }
        }
        
        return snapshot
    }

    
    // MARK: - Data Source Configuration
    /// 配置「表格視圖」的資料來源。
    func configureTableViewDataSource(_ tableView: UITableView) {
        // 嘗試從重用池中取得並配置表格的 cell
        tableViewDataSource = StoreItemTableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.itemCell, for: indexPath) as? ItemTableViewCell else {
                fatalError("Unable to dequeue ItemTableViewCell")
            }
            
            // 取消之前的圖片加載任務，避免重複加載
            self.tableViewImageLoadTasks[indexPath]?.cancel()
            // 建立一個新的加載圖片的任務
            self.tableViewImageLoadTasks[indexPath] = Task {
                await cell.configure(for: item, storeItemController: self.storeItemController)
                // 清除引用，表示圖片加載任務已完成或取消。
                self.tableViewImageLoadTasks[indexPath] = nil
            }
            // 返回配置好的 cell
            return cell
        })
    }
    
    /// 配置「集合視圖」的資料來源。
    func configureCollectionViewDataSource(_ collectionView: UICollectionView) {
        // 設置 collectionViewDataSource。負責為每個集合視圖項目提供一個cell。
        collectionViewDataSource = UICollectionViewDiffableDataSource<String, StoreItem>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PropertyKeys.itemCollectionViewCell, for: indexPath) as? ItemCollectionViewCell else {
                fatalError("Unable to dequeue ItemCollectionViewCell")
            }
            
            // 取消之前可能正在進行的圖片加載任務。
            self.collectionViewImageLoadTasks[indexPath]?.cancel()
            // 開始一個新的圖片加載任務。
            self.collectionViewImageLoadTasks[indexPath] = Task {
                await cell.configure(for: item, storeItemController: self.storeItemController)
                // 清除引用，表示圖片加載任務已完成或取消。
                self.collectionViewImageLoadTasks[indexPath] = nil
            }
            
            return cell
        })
        
        // 設置 supplementaryViewProvider ，用於生成集合視圖的Header。
        collectionViewDataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "Header", withReuseIdentifier: StoreItemCollectionViewSectionHeader.reuseIdentifier, for: indexPath) as? StoreItemCollectionViewSectionHeader else {
                fatalError("Unable to dequeue StoreItemCollectionViewSectionHeader")
            }
            
            // 設置Header標題。
            let title = self.itemsSnapshot.sectionIdentifiers[indexPath.section]
            headerView.setTitle(title)
            
            return headerView
        }
    }
     
    // MARK: - Navigation
    // 配置轉場
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 如果目的視圖控制器是StoreItemListTableViewController
        if let tableViewController = segue.destination as? StoreItemListTableViewController {
            // 配置表格視圖的數據源
            configureTableViewDataSource(tableViewController.tableView)
        }
        
        // 如果目的視圖控制器是StoreItemCollectionViewController
        if let collectionViewController = segue.destination as? StoreItemCollectionViewController {
            // 配置集合視圖的數據源
            configureCollectionViewDataSource(collectionViewController.collectionView)
            
            // 根據選擇的搜索範圍配置集合視圖的布局
            collectionViewController.configureCollectionViewLayout(for: selectedSearchScope)
            
            // 將當前的集合視圖控制器保存為類別屬性，以供後續使用
            self.collectionViewController = collectionViewController
        }
    }
    
}

// MARK: - Extension
// 擴展 StoreItemContainerViewController 來實現 UISearchResultsUpdating 協議
extension StoreItemContainerViewController: UISearchResultsUpdating {
    
    // 當搜索條件變更時，更新搜索結果
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchMatchingItems), object: nil)
        perform(#selector(fetchMatchingItems), with: nil, afterDelay: 0.3)
    }
}

