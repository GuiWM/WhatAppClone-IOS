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
    var listaConversas: [Dictionary<String, Any>] = []
    var conversasListener: ListenerRegistration!
    
    var auth: Auth!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewConversas.separatorStyle = .none
        
        auth = Auth.auth()
        db = Firestore.firestore()
        
    }
    
    func addListenerRecuperarConversas() {
        
        if let idUsuario = auth.currentUser?.uid {
            
            conversasListener = db.collection("conversas")
            .document(idUsuario)
            .collection("ultimas_conversas")
                .addSnapshotListener { (querySnapshot, erro) in
                    
                    if erro == nil {
                        
                        self.listaConversas.removeAll()
                        
                        if let snapshot = querySnapshot {
                            for document in snapshot.documents {
                                let dados = document.data()
                                self.listaConversas.append(dados)
                            }
                            
                            self.tableViewConversas.reloadData()
                        }
                    }
                    
            }
            
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaConversas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaConversa", for: indexPath) as! ConversaTableViewCell
        
        let indice = indexPath.row
        let dados = self.listaConversas[indice]
        let nome = dados["nomeUsuario"] as? String
        let ultimaMensagem = dados["ultimaMensagem"] as? String
        
        celula.conversa.text = nome
        celula.ultimaConversa.text = ultimaMensagem
        
        if let urlFotoUsuario = dados["urlFotoUsuario"] as?  String {
            celula.fotoConversa.sd_setImage(with: URL(string: urlFotoUsuario), completed: nil)
        } else {
            celula.fotoConversa.image = UIImage(named: "imagem-perfil")
        }
        
        return celula
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableViewConversas.deselectRow(at: indexPath, animated: true)
        
        let indice = indexPath.row
        let conversa = self.listaConversas[indice]
        
        if let id = conversa["idDestinatario"] as? String {
            if let nome = conversa["nomeUsuario"] as? String {
                if let url = conversa["urlFotoUsuario"] as? String {
                    
                    let contato: Dictionary<String, Any> = [
                        "id": id,
                        "nome": nome,
                        "urlImagem": url
                    ]
                    
                    self.performSegue(withIdentifier: "iniciarConversa", sender: contato)

                    
                }
            }
        }
                
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "iniciarConversa" {
            let viewDestino = segue.destination as! MensagensViewController
            viewDestino.contato =  sender as? Dictionary
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.addListenerRecuperarConversas()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        conversasListener.remove()
        
    }
    

}
