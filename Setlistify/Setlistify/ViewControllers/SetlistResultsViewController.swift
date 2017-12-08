//
//  SetlistResultsViewController.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 30/11/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import UIKit

class SetlistResultsViewController: UITableViewController {

    var dataSource: SetlistSearchResponse?
    var currentPage = 1
    
    var artistSearch = ""
    var venueSearch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.sectionFooterHeight = 0
        self.tableView.sectionHeaderHeight = 0
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if artistSearch.count > 0 {
            self.title = artistSearch
        }
        else {
            setupLogoInTop()
        }
    }
    
    func setupLogoInTop() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 45))
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let logo = #imageLiteral(resourceName: "setlistify_logo")
        imageView.image = logo
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        self.navigationItem.titleView = imageView
    }
    
    func fetchDataAPI() {
        guard let data = dataSource else { return }
        SetlistConnectionManager.search(with: artistSearch, venue: venueSearch, pageNumber: currentPage) { (response) in

            switch response.result {
            case .success(let data):
                print(data.itemsPerPage)
                
                self.dataSource?.setlist.append(contentsOf: data.setlist)
                self.tableView.reloadData()
                
            case .failure:
                
                let myalert = UIAlertController(title: "Sorry", message: "We couldn't find any setlists.", preferredStyle: UIAlertControllerStyle.alert)
                myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Selected")
                })
                self.present(myalert, animated: true)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.total ?? 0//dataSource?.setlist.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SetlistTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SetlistCell") as! SetlistTableViewCell
        
        if (dataSource?.setlist.count ?? 0) - 1 >= indexPath.row {
            if let setlist = dataSource?.setlist[indexPath.row] {
                cell.populateCell(with: setlist.artist.name, venue: setlist.venue.name, songCount: setlist.sets.songCount(), dateString: setlist.eventDate)
            }
        }
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.title = ""
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetlistViewController") as! SetlistViewController
        vc.dataSource = dataSource
        vc.selectedSetIndex = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let data = dataSource else { return }
        if indexPath.row == currentPage * data.itemsPerPage - 1 {
            if data.setlist.count < data.total {
                currentPage += 1
                fetchDataAPI()
            }
        }
    }
}
