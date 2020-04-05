//
//  ConversasViewController.swift
//  WhatsApp
//
//  Created by Guilherme Magnabosco on 05/04/20.
//  Copyright © 2020 Guilherme Magnabosco. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseAuth
import FirebaseFirestore

class ConversasViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableViewConversas: UITableView!
    
    var auth: Auth!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewConversas.separatorStyle = .none
        
        auth = Auth.auth()
        db = Firestore.firestore()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaConversa", for: indexPath) as! ConversaTableViewCell
        
        celula.conversa.text = "Guilherme Magnabosco"
        celula.ultimaConversa.text = "me responde"
        celula.fotoConversa.image = UIImage(named: "imagem-perfil")
        
        return celula
        
        
    }
    

}
