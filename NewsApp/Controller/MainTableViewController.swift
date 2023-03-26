//
//  ViewController.swift
//  NewsApp
//
//  Created by Luis Filipe Alves de Oliveira on 16/02/23.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {
    let cellIdentifier: String = "cell"
    var activityIndicator: UIActivityIndicatorView?
    var fetchResultController: NSFetchedResultsController<NewsData>!
    var news = [NewsData]()

    var dataController: DataController!

    // MARK: Private funcs
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<NewsData> = NewsData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: dataController.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchResultController.delegate = self

        do {
            try fetchResultController.performFetch()
        } catch {
            print("no fetch data \(error.localizedDescription)")
        }
    }

    private func fetchNews() {
        NetwotkManager.shared.getNews { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.deleteData()
                for item in response {
                    let newsData = NewsData(context: self.dataController.viewContext)

                    newsData.url = item.url
                    newsData.title = item.title
                    newsData.byline = item.byline

                    if let image = item.media.first?.mediaMetaData.last?.url {
                        guard let imageURL = URL(string: image) else { return }
                        guard let imageData = try? Data(contentsOf: imageURL) else { return }

                        newsData.image = image
                        newsData.data = imageData
                    }
                    try? self.dataController.viewContext.save()
                }
            case .failure(let error):
                print("error: \(error)")
            }

            DispatchQueue.main.async {
                self.hideActivityIndicator()
                self.tableView.reloadData()
            }
        }
    }

    private func deleteData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NewsData.fetchRequest()

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        do {
            let context = dataController.viewContext
            let result = try context.execute(deleteRequest)

            guard let deleteResult = result as? NSBatchDeleteResult,
                  let ids = deleteResult.result as? [NSManagedObjectID] else {
                return
             }

            let changes = [NSDeletedObjectsKey: ids]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        } catch {
            print("error on delete storage: \(error.localizedDescription)")
        }

        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    private func showActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        guard let activityIndicator = activityIndicator else { return }

        self.view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.widthAnchor.constraint(equalToConstant: 70),
            activityIndicator.heightAnchor.constraint(equalToConstant: 70),
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])

        activityIndicator.startAnimating()
    }

    private func hideActivityIndicator() {
        guard let activityIndicator = activityIndicator else { return }

        activityIndicator.stopAnimating()
    }

    // MARK: Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        showActivityIndicator()
        fetchNews()
    }

    // MARK: Overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsData = fetchResultController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NewYorkTableViewCell
        cell.title.text = newsData.title
        cell.by.text = newsData.byline

        if let imageData = newsData.data {
            cell.imageNews.image = UIImage(data: imageData)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsData = fetchResultController.object(at: indexPath)

        guard let url = newsData.url else { return }

        if let url = URL(string: url) { UIApplication.shared.open(url) }
    }
}


extension MainTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if newIndexPath != nil {
                tableView.insertRows(at: [newIndexPath!], with: .none)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .none)
            }
            break;
        case .move, .update:
            break;
        }
    }
}
