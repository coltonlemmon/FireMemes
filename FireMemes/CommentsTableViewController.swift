//
//  CommentsTableViewController.swift
//  FireMemes
//
//  Created by Jose Melendez on 6/13/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    
    var meme: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
      
    }
   
 

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meme?.comments.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsShown", for: indexPath)

        // Configure the cell...
        guard let meme = meme else { return cell }
        
        let comment = meme.comments[indexPath.row]
        cell.textLabel?.text = comment
        
        return cell
    }
 

       // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
    
