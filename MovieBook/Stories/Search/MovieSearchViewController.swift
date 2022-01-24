//
//  MovieSearchViewController.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022. All rights reserved.
//

import Foundation
import UIKit
import Combine

class MovieSearchViewController: ViewController, StoryboardLoadable, UISearchControllerDelegate, UISearchResultsUpdating {

    static var storyboardName: String { return "MovieSearch" }
    static let emptyCellReuseID: String = "EmptyCell"
    
    var viewModel: MovieSearchViewModel!
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.delegate = self
        controller.searchResultsUpdater = self
        controller.searchBar.autocapitalizationType = .none
        return controller
    }()
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @Published private(set) var searchedText: String = ""
    private var subscriptions = Set<AnyCancellable>()

    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var isTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        registerForChanges()
    }
    
    func registerForChanges() {
        viewModel.onMoviesUpdated = { [weak self] _ in
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
        viewModel.onMovieSearchError = { [weak self] errorMessage in
            guard let self = self else { return }
            self.isTyping = false
            self.tableView.reloadData()
            self.showAlert(message: errorMessage)
            self.refreshControl?.endRefreshing()
        }
        
        $searchedText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .filter({ $0.count > 1 })
            .sink { [weak self] text in
                print("Querying: \(text)")
                self?.viewModel.query(by: text)
            }
            .store(in: &subscriptions)
    }
    
    private func configureUI() {
        self.title = "Search for Movies"
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self,
                                 action: #selector(refresh(sender:)),
                                 for: .valueChanged)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidChangeFrameNotification,
                                               object: nil)
        tableView.addSubview(refreshControl)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Type movie title"
        configureTableView()
    }
    
    @objc private func keyboardDidShow(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if endFrame.size.height > 0 && isTyping {
                    tableViewBottomConstraint.constant = endFrame.size.height
                } else {
                    tableViewBottomConstraint.constant = 0
                }
            }
        }
    }
    
    private func configureTableView() {
        tableView.tableHeaderView = searchController.searchBar
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 85.0
        tableView.register(UINib(nibName: "MovieSummaryCell", bundle: nil),
                           forCellReuseIdentifier: MovieSummaryCell.reuseIdentifier)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: Self.emptyCellReuseID)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        isTyping = false
        tableView.reloadData()
        view.endEditing(false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MovieSearchViewController {
    @objc func refresh(sender:AnyObject)
    {
        if isTyping {
            refreshControl.endRefreshing()
        } else {
            if let query = viewModel.state.mostRecentSuccessfulQuery {
                self.viewModel.query(by: query)
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchedText = searchController.searchBar.text ?? ""
    }
}

extension MovieSearchViewController: UISearchBarDelegate {
    
 /*   public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        isTyping = true
        tableView.reloadData()
        return true
    }
    
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        isTyping = true
        tableView.reloadData()
        return true
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        isTyping = false
        tableView.reloadData()
        view.endEditing(false)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isTyping = false
            tableView.reloadData()
        }
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        isTyping = false
        tableView.reloadData()
        return true
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isTyping = false
        view.endEditing(false)
        if let text = searchBar.text {
            viewModel.query(by: text)
        }
    }*/
}

extension MovieSearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*  if isTyping {
         if let suggestedOptions = viewModel.suggestedOptions,
         suggestedOptions.count > indexPath.row {
         let cell = UITableViewCell()
         cell.textLabel?.text = suggestedOptions[indexPath.row]
         return cell
         }
         } else {*/
        let movies = viewModel.state.movies
        if movies.isEmpty {
            if let cell = tableView.dequeueReusableCell(withIdentifier: Self.emptyCellReuseID) {
                cell.textLabel?.text = "No results"
                cell.selectionStyle = .none
                return cell
            }
        }
        else if let cell = tableView.dequeueReusableCell(withIdentifier: MovieSummaryCell.reuseIdentifier)
                    as? MovieSummaryCell {
            if  movies.count > indexPath.row {
                cell.update(with: movies[indexPath.row])
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return isTyping ? viewModel.suggestedOptions?.count ?? 0 : viewModel.state.movies?.count ?? 0
        let count = viewModel.state.movies.count
        return count == 0 ? 1 : count
    }
}

extension MovieSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(false)
        if isTyping {
            if let suggestedOptions = viewModel.suggestedOptions,
                suggestedOptions.count > indexPath.row {
                searchController.searchBar.text = suggestedOptions[indexPath.row]
                viewModel.query(by: suggestedOptions[indexPath.row])
                isTyping = false
            }
        }
    }
}
