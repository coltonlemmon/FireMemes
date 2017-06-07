//
//  ShowMemesTableViewController.swift
//  FireMemes
//
//  Created by Jose Melendez on 6/7/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit

class ShowMemesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

 

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memeFeed", for: indexPath)


        return cell
    }
 


}
