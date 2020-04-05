//
//  CadastroContatoViewController.swift
//  WhatsApp
//
//  Created by Guilherme Magnabosco on 06/03/20.
//  Copyright © 2020 Guilherme Magnabosco. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CadastroContatoViewController: UIViewController {

    
    @IBOutlet weak var campoEmail: UITextField!
    @IBOutlet weak var mensagemErro: UILabel!
    
    var idUsuarioLogado: String!
    var emailUsuarioLogado: String!
    
    var auth: Auth!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        db = Firestore.firestore()
        
        if let currentUser = auth.currentUser {
            self.idUsuarioLogado = currentUser.uid
            self.emailUsuarioLogado = currentUser.email
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cadastrarContato(_ sender: Any) {
        
        //Verifica se usuario digitou o proprio email
        if let emailDigitado = campoEmail.text {
            if emailDigitado == self.emailUsuarioLogado {
                
                mensagemErro.isHidden = false
                mensagemErro.text = "Você está adicionando seu próprio email. Deixa de ser burro."
                
                return
            }
            
            //Verifica se existe usuario no Firebase
            db.collection("usuarios").whereField("email", isEqualTo: emailDigitado).getDocuments { (snapshotResultado, erro) in
                
                if let totalItens = snapshotResultado?.count {
                    if totalItens == 0 {
                        self.mensagemErro.text = "Usuário não cadastrado."
                        self.mensagemErro.isHidden = false
                        return
                    }
                }
                
                //Salva contato
                if let snapshot = snapshotResultado {
                    
                    for document in snapshot.documents {
                        let dados = document.data()
                        self.salvarContado(dadosContato: dados)
                    }
                    
                }
                
            }
            
        }
        
        
    }
    
    func salvarContado(dadosContato: Dictionary<String, Any>) {
        
        if let idUsuarioContato = dadosContato["id"] {
            db.collection("usuarios").document(idUsuarioLogado).collection("contatos").document(String(describing: idUsuarioContato))
                .setData(dadosContato) { (erro) in
                    
                    if erro == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
            }
        }
        
    }
    
}
