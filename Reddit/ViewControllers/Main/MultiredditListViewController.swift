//
//  MultiredditListViewController.swift
//  Reddit
//
//  Created by Ivan Bruel on 06/05/16.
//  Copyright © 2016 Faber Ventures. All rights reserved.
//

import Foundation
import RxSwift
import NSObject_Rx
import RxDataSources

// MARK: Properties
class MultiredditListViewController: UIViewController, InsettableScrollViewViewController {

  // MARK: Static Properties
  private static let estimatedTableViewCellHeight: CGFloat = 60

  // MARK: IBOutlets
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.estimatedRowHeight = MultiredditListViewController.estimatedTableViewCellHeight
      tableView.rowHeight = UITableViewAutomaticDimension
    }
  }

  // MARK: Public Properties
  var viewModel: MultiredditListViewModel!

  // MARK: InsettableScrollViewViewController Property
  var topScrollInset: CGFloat = 0
}

// MARK: Lifecycle
extension MultiredditListViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    tableView.deselectRows(true)
  }
}

// MARK: Setup
extension MultiredditListViewController {

  private func setup() {
    bindTableView()
    setupInsettableScrollView(tableView)
    viewModel.requestMultireddits()
  }

  private func bindTableView() {
    let dataSource =
      RxTableViewSectionedReloadDataSource<SectionViewModel<MultiredditListItemViewModel>>()

    dataSource.configureCell = { (_, tableView, indexPath, viewModel) in
      let cell = tableView.dequeueReusableCell(MultiredditListItemTableViewCell.self,
                                               indexPath: indexPath)
      cell.viewModel = viewModel
      return cell
    }

    dataSource.titleForHeaderInSection = { (dataSource, index) in
      return dataSource.sectionAtIndex(index).title
    }

    dataSource.sectionIndexTitles = { dataSource in
      return dataSource.sectionModels.map { $0.title }
    }

    dataSource.sectionForSectionIndexTitle = { (_, _, index) in
      return index
    }

    viewModel
      .viewModels
      .bindTo(tableView.rx_itemsWithDataSource(dataSource))
      .addDisposableTo(rx_disposeBag)
  }

}

// MARK: Segues
extension MultiredditListViewController {

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let segueEnum = StoryboardSegue.Main(optionalRawValue: segue.identifier) else { return }

    if let linkListViewController = segue.navigationRootViewController as? LinkListViewController,
      cell = sender as? MultiredditListItemTableViewCell where segueEnum == .LinkList {
      linkListViewController.viewModel = cell.viewModel.linkListViewModel
    }
  }
}
