//
//  CommentsTableViewController.swift
//  FireMemes
//
//  Created by Jose Melendez on 6/13/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Outlets and Actions
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBAction func postCommentButton(_ sender: Any) {
        guard let meme = meme else { return }
        guard let comment = commentTextField.text else { return }
        MemeController.shared.addCommentToMeme(meme: meme, comment: comment)
        tableView.reloadData()
    }
    
    //MARK: - Internal Properties
    
    var meme: Meme?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        hideKeyboardWhenTappedAround()
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meme?.comments.count ?? 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

extension UITableViewController {
   override func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UITableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
   override func dismissKeyboard() {
        view.endEditing(true)
    }
}
    
