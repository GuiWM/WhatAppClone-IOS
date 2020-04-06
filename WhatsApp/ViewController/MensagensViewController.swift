//
//  MensagensViewController.swift
//  WhatsApp
//
//  Created by Guilherme Magnabosco on 02/04/20.
//  Copyright © 2020 Guilherme Magnabosco. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class MensagensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableViewMensagens: UITableView!
    @IBOutlet weak var fotoBotao: UIButton!
    @IBOutlet weak var mensagemCaixaTexto: UITextField!
    
    
    var listaMensagens: [Dictionary<String, Any>]! = []
    
    var auth: Auth!
    var storage: Storage!
    var db: Firestore!
    var idUsuarioLogado: String!
    var contato: Dictionary<String, Any>!
    var mensagensListener: ListenerRegistration!
    var imagePicker = UIImagePickerController()
    
    var nomeContato: String!
    var urlFotoContato: String!
    var nomeUsuarioLogado: String!
    var urlFotoUsuarioLogado: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
        imagePicker.delegate = self

        
        // Recuperar id do usuario logado
        if let id = auth.currentUser?.uid {
            self.idUsuarioLogado = id
            repurarDadosUsuarioLogado()
        }
        
        //Configura titulo da tela
        if let nome = contato["nome"] as? String {
            nomeContato = nome
            self.navigationItem.title = nomeContato
        }
        
        if let url = contato["urlImagem"] as? String {
            urlFotoContato = url
        }
        
            
        // configuracao da table view
        tableViewMensagens.backgroundView = UIImageView(image: UIImage(named: "bg"))
        tableViewMensagens.separatorStyle = .none
        
        // Configura lista de mensagens
        //self.listaMensagens = ["Ola, tudo bem?","Tudo uma merda seu corno desgracento do carai pega na minha vara!", "Carai rogerin qual foi", "Pai ta chato fi","Beleza po", "Chama la o cleitin", "Suavi"]
        
    }
    
    
    
    @IBAction func enviarImagem(_ sender: Any) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imagemRecuperada = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        let imagens = storage.reference().child("imagens")

        if let imagemUpload = imagemRecuperada.jpegData(compressionQuality: 0.3) {
            
            let identificadorUnico = UUID().uuidString
            let nomeImagem = "\(identificadorUnico).jpg"
            let imagemMensagemRef = imagens.child("mensagens").child(nomeImagem)
            
            imagemMensagemRef.putData(imagemUpload, metadata: nil) { (metadata, erro) in
                
                if erro == nil {
                    print("Sucesso ao fazer upload da imagem.")
                    
                    imagemMensagemRef.downloadURL { (url, erro) in
                        
                        if let urlImagem = url?.absoluteString {
                            
                            if let idUsuarioDestinatario = self.contato["id"] as? String {
                                
                                let mensagem: Dictionary<String, Any> = [
                                    "idUsuario": self.idUsuarioLogado!,
                                    "urlImagem": urlImagem,
                                    "data": FieldValue.serverTimestamp()
                                ]
                                
                                // salvar mensagem para remetente
                                self.salvarMensagens(idRemetente: self.idUsuarioLogado, idDestinatario: idUsuarioDestinatario, mensagem: mensagem)
                                
                                //salvar mensagem para destinatario
                                self.salvarMensagens(idRemetente: idUsuarioDestinatario, idDestinatario: self.idUsuarioLogado, mensagem: mensagem)
                                
                                var conversa: Dictionary <String, Any> = [
                                    "ultimaMensagem": "image...",
                                ]
                                
                                //salvar conversa para remetente
                                conversa["idRemetente"] = self.idUsuarioLogado!
                                conversa["idDestinatario"] = idUsuarioDestinatario
                                conversa["nomeUsuario"] = self.nomeContato!
                                conversa["urlFotoUsuario"] = self.urlFotoContato!
                                self.salvarConversa(idRemetente: self.idUsuarioLogado, idDestinatario: idUsuarioDestinatario, conversa: conversa)
                                
                                //salvar conversa para destinatario
                                conversa["idRemetente"] = idUsuarioDestinatario
                                conversa["idDestinatario"] = self.idUsuarioLogado!
                                conversa["nomeUsuario"] = self.nomeUsuarioLogado
                                conversa["urlFotoUsuario"] = self.urlFotoUsuarioLogado
                                self.salvarConversa(idRemetente: idUsuarioDestinatario, idDestinatario: self.idUsuarioLogado, conversa: conversa)

                            }
                            
                        }
                        
                    }
                    
                } else {
                    print("Erro ao fazer upload da imagem.")
                }
                
            }
        }
        
        imagePicker.dismiss(animated: true, completion: nil)


        
    }
    
    func repurarDadosUsuarioLogado() {
        
        let usuarios = db.collection("usuarios")
        .document(idUsuarioLogado)
        
        usuarios.getDocument { (documentSnapshot, erro) in
            
            if erro == nil {
                if let dados = documentSnapshot?.data() {
                    if let url = dados["urlImagem"] as? String {
                        if let nome = dados["nome"] as? String {
                            self.urlFotoUsuarioLogado = url
                            self.nomeUsuarioLogado = nome
                        }
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func enviarMensagem(_ sender: Any) {
        
        if let textoDigitado = mensagemCaixaTexto.text {
            if !textoDigitado.isEmpty {
                if let idUsuarioDestinatario = contato["id"] as? String {
                    
                    let mensagem: Dictionary<String, Any> = [
                        "idUsuario": idUsuarioLogado!,
                        "texto": textoDigitado,
                        "data": FieldValue.serverTimestamp()
                    ]
                    
                    // salvar mensagem para remetente
                    salvarMensagens(idRemetente: idUsuarioLogado, idDestinatario: idUsuarioDestinatario, mensagem: mensagem)
                    
                    //salvar mensagem para destinatario
                    salvarMensagens(idRemetente: idUsuarioDestinatario, idDestinatario: idUsuarioLogado, mensagem: mensagem)

                    var conversa: Dictionary <String, Any> = [
                        "ultimaMensagem": textoDigitado,
                    ]
                    
                    //salvar conversa para remetente
                    conversa["idRemetente"] = self.idUsuarioLogado!
                    conversa["idDestinatario"] = idUsuarioDestinatario
                    conversa["nomeUsuario"] = self.nomeContato!
                    conversa["urlFotoUsuario"] = self.urlFotoContato!
                    salvarConversa(idRemetente: idUsuarioLogado, idDestinatario: idUsuarioDestinatario, conversa: conversa)
                    
                    //salvar conversa para destinatario
                    conversa["idRemetente"] = idUsuarioDestinatario
                    conversa["idDestinatario"] = self.idUsuarioLogado!
                    conversa["nomeUsuario"] = self.nomeUsuarioLogado
                    conversa["urlFotoUsuario"] = self.urlFotoUsuarioLogado
                    salvarConversa(idRemetente: idUsuarioDestinatario, idDestinatario: idUsuarioLogado, conversa: conversa)
                    
                }
            }
        }
        
    }
    
    func salvarConversa(idRemetente: String, idDestinatario: String, conversa: Dictionary<String, Any>) {
        
        db.collection("conversas")
            .document(idRemetente)
            .collection("ultimas_conversas")
            .document(idDestinatario)
            .setData(conversa)
        
    }
    
    func salvarMensagens(idRemetente: String, idDestinatario: String, mensagem: Dictionary<String, Any>) {
        
        db.collection("mensagens")
            .document(idRemetente)
            .collection(idDestinatario)
            .addDocument(data: mensagem)
        
        //limpar caixa de texto
        mensagemCaixaTexto.text = ""
        
    }
    
    func addListenerRecuperarMensagens() {
        
        if let idDestinatario = contato["id"] as? String {
            mensagensListener = db.collection("mensagens")
            .document(idUsuarioLogado)
            .collection(idDestinatario)
            .order(by: "data", descending: false)
                .addSnapshotListener { (querySnapshot, erro) in
                    
                    //limpa lista
                    self.listaMensagens.removeAll()
                    
                    //Recuperar dados
                    if let snapshot = querySnapshot {
                        for document in snapshot.documents {
                            let dados = document.data()
                            self.listaMensagens.append(dados)
                        }
                        self.tableViewMensagens.reloadData()
                    }
                    
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaMensagens!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celulaDireita = tableView.dequeueReusableCell(withIdentifier: "celulaMensagensDireita", for: indexPath) as! MensagensTableViewCell
        
        let celulaEsquerda = tableView.dequeueReusableCell(withIdentifier: "celulaMensagensEsquerda", for: indexPath) as! MensagensTableViewCell
              
        let celulaImagemDireita = tableView.dequeueReusableCell(withIdentifier: "celulaImagemDireita", for: indexPath) as! MensagensTableViewCell
        
        let celulaImagemEsquerda = tableView.dequeueReusableCell(withIdentifier: "celulaImagemEsquerda", for: indexPath) as! MensagensTableViewCell

        
        let indice = indexPath.row
        let dados = self.listaMensagens[indice]
        
        let texto = dados["texto"] as? String
        let idUsuario = dados["idUsuario"] as? String
        let urlImagem = dados["urlImagem"] as? String

        
        if idUsuarioLogado == idUsuario {
            if urlImagem != nil {
                celulaImagemDireita.ImagemDireita.sd_setImage(with: URL(string: urlImagem!), completed: nil)
                return celulaImagemDireita
            }
            celulaDireita.mensagemDireitaLabel.text = texto
            return celulaDireita
        } else {
            if urlImagem != nil {
                celulaImagemEsquerda.imagemEsquerda.sd_setImage(with: URL(string: urlImagem!), completed: nil)
                return celulaImagemEsquerda
            }
            celulaEsquerda.mensagemEsquerdaLabel.text = texto
            return celulaEsquerda
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        addListenerRecuperarMensagens()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        mensagensListener.remove()
    }

}
