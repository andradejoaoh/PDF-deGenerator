//
//  ViewController.swift
//  PDF deGenerator
//
//  Created by João Henrique Andrade on 14/04/20.
//  Copyright © 2020 João Henrique Andrade. All rights reserved.
//

import UIKit
import PDFKit

class PDFDegenerateViewController: UIViewController {
    
    @IBOutlet weak var tituloTextField: UITextField!
    @IBOutlet weak var textoTextField: UITextView!
    @IBOutlet weak var contatoTextField: UITextView!
    @IBOutlet weak var barraDePorcentagem: UISlider!
    @IBOutlet weak var porcentagemLabel: UILabel!
    @IBOutlet weak var switchImagem: UISwitch!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var settingsView: UIView!
    
    var imagemSelecionada: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
        self.toolbarItems?.append(shareButton)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        setupView()
    }
    
    func degenerarTexto() -> String? {
        let caracteresNoTexto = textoTextField.text.count
        let numeroDeRemocao = barraDePorcentagem.value * Float(caracteresNoTexto)
        var novoTexto = Array(textoTextField.text)
        var indice = caracteresNoTexto
        for _ in 0..<Int(numeroDeRemocao) {
            let removerRandom = Int.random(in: 0..<indice)
            novoTexto.remove(at: removerRandom)
            indice -= 1
        }
        return String(novoTexto)
    }
    
    func degenerarContato() -> String? {
        let caracteresNoContato = contatoTextField.text.count
        let numeroDeRemocao = barraDePorcentagem.value * Float(caracteresNoContato)
        var novoContato = Array(contatoTextField.text)
        var indice = caracteresNoContato
        for _ in 0..<Int(numeroDeRemocao) {
            let removerRandom = Int.random(in: 0..<indice)
            novoContato.remove(at: removerRandom)
            indice -= 1
        }
        return String(novoContato)
    }
    
    func gerarPDF() -> Data? {
        guard let title = tituloTextField.text,
            let body = degenerarTexto(),
            let contato = degenerarContato(),
            let image = imagemSelecionada
            else {
                let alert = UIAlertController(title: "Não foram fornecidas todas as informações", message: "Você deve preencher todos os campos para poder gerar o PDF.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Entendi", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return nil
        }

        var pdfGenerator = PDFGenerator(titulo: title, texto: body, imagem: image, contato: contato)
        if !switchImagem.isOn{
            pdfGenerator = PDFGenerator(titulo: title, texto: body, imagem: nil, contato: contato)
        }
        return pdfGenerator.criarPDF()
    }
    
    @IBAction func atualizarPorcentagemLabel(_ sender: Any) {
        let valor = (barraDePorcentagem.value * 100)
        porcentagemLabel.text = String(format: "%.2f%", valor)
    }
    
    @IBAction func escolherImagem(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Selecione uma Foto", message: "Qual o local da foto?", preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Fotos", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                let photoPicker = UIImagePickerController()
                photoPicker.delegate = self
                photoPicker.sourceType = .photoLibrary
                photoPicker.allowsEditing = false
                
                self.present(photoPicker, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(photoAction)
        
        let cameraAction = UIAlertAction(title: "Câmera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                cameraPicker.sourceType = .camera
                
                self.present(cameraPicker, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(cameraAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if
            let _ = tituloTextField.text,
            let _ = textoTextField.text,
            let _ = imagemSelecionada,
            let _ = contatoTextField.text {
            return true
        }
        
        let alert = UIAlertController(title: "Não foram fornecidas todas as informações", message: "Você deve preencher todos os campos para poder gerar o PDF.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendi", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        return false
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PDFPreviewSegue" {
            guard let vc = segue.destination as? PDFPreviewViewController else { return }
            guard let pdfData = gerarPDF() else { return }
            vc.documentData = pdfData
        }
    }
    
    @objc func shareAction() {
        guard let pdfData = gerarPDF()
            else {
                let alert = UIAlertController(title: "Não foram fornecidas todas as informações", message: "Você deve preencher todos os campos para poder gerar o PDF.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Entendi", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
        }
        let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func preVisualizar(_ sender: Any) {
        performSegue(withIdentifier: "PDFPreviewSegue", sender: self)
    }
    
    func setupView() -> Swift.Void {
        contatoTextField.layer.borderWidth = 1
        contatoTextField.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        contatoTextField.layer.cornerRadius = 4
        textoTextField.layer.borderWidth = 1
        textoTextField.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        textoTextField.layer.cornerRadius = 4
        titleView.layer.cornerRadius = 8
        textView.layer.cornerRadius = 8
        settingsView.layer.cornerRadius = 8
    }
}

extension PDFDegenerateViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        imagemSelecionada = selectedImage
        dismiss(animated: true, completion: nil)
    }
}

extension PDFDegenerateViewController: UINavigationControllerDelegate {
}

