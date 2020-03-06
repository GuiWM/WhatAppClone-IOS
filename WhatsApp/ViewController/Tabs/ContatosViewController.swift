//
//  ContatosViewController.swift
//  WhatsApp
//
//  Created by Guilherme Magnabosco on 06/03/20.
//  Copyright © 2020 Guilherme Magnabosco. All rights reserved.
//

import UIKit

class ContatosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableViewContatos: UITableView!
    @IBOutlet weak var searchBarContatos: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarContatos.delegate = self
        
        tableViewContatos.separatorStyle = .none
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("pesquisa: \(searchText)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        <#code#>
    }
    
    /*Metodos de listagem de tabela*/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaContatos", for: indexPath) as! ContatoTableViewCell
        
        let indice = indexPath.row
        
        celula.nome.text = "Guilherme Magnabosco \(indice + 1)"
        celula.email.text = "guilherme.magnabosco@hotmail.com \(indice + 1)"
        celula.fotoContato.image = UIImage(named: "imagem-perfil")
        
        return celula
        
    }

}
