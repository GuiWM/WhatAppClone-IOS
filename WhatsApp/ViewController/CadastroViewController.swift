//
//  CadastroViewController.swift
//  WhatsApp
//
//  Created by Guilherme Magnabosco on 20/02/20.
//  Copyright © 2020 Guilherme Magnabosco. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CadastroViewController: UIViewController {

    @IBOutlet weak var campoNome: UITextField!
    @IBOutlet weak var campoEmail: UITextField!
    @IBOutlet weak var campoSenha: UITextField!
    var auth: Auth!
    var firestore: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        firestore = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func cadastrar(_ sender: Any) {
        
        if let nome = campoNome.text {
            if let email = campoEmail?.text {
                if let senha = campoSenha.text {
                    
                    auth.createUser(withEmail: email, password: senha) { (dadosResultado, erro) in
                                                
                        if erro == nil {
                            
                            //salvar dados do usuario
                            if let idUsuario = dadosResultado?.user.uid {
                                
                                self.firestore.collection("usuarios").document(idUsuario).setData(["nome": nome, "email": email])
                                
                            }
                            
                            print("Sucesso ao cadastrar usuario.")
                        } else {
                            print("Erro ao cadastrar usuario.")
                        }
                        
                    }
                    
                } else {
                    print("Digite sua senha!")
                }
            } else {
                print("Digite seu email!")
            }
        } else {
            print("Digite seu nome!")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
