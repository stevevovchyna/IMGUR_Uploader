//
//  LinksViewController.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 12.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import UIKit

class LinksViewController: UIViewController {

    let linkManager = LinkManager()
    var allLinks: [Link] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // obtaining all the links available on the device
        allLinks = linkManager.getAllLinks()
    }

    // button created for convenience - to delete all the links saved on the device
    @IBAction func deleteAll(_ sender: UIBarButtonItem) {
        for link in allLinks {
            linkManager.removeLink(article: link)
        }
        linkManager.save()
        allLinks = linkManager.getAllLinks()
        tableView.reloadData()
    }
}

extension LinksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLinks.count
    }
    
    // populate the table with the links from the `allLinks` array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell", for: indexPath)
        guard let link = allLinks[indexPath.row].link else { return cell }
        cell.textLabel?.text = link
        return cell
    }
    
}

extension LinksViewController: UITableViewDelegate {
    
    // open in browser on tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let link = allLinks[indexPath.row].link, let url = URL(string: link) else { return }
        tableView.cellForRow(at: indexPath)?.isSelected = false
        UIApplication.shared.open(url)
    }
    
    // swipe to delete functionality
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            linkManager.removeLink(article: allLinks[indexPath.row])
            linkManager.save()
            allLinks = linkManager.getAllLinks()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
}
