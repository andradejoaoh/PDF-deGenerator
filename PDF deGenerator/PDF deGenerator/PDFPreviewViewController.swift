//
//  PDFPreviewViewController.swift
//  PDF deGenerator
//
//  Created by João Henrique Andrade on 14/04/20.
//  Copyright © 2020 João Henrique Andrade. All rights reserved.
//

import Foundation
import UIKit
import PDFKit

class PDFPreviewViewController: UIViewController {
    public var documentData: Data?
    @IBOutlet var PDFView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
              self.toolbarItems?.append(shareButton)
        if let data = documentData {
            PDFView.document = PDFDocument(data: data)
            PDFView.autoScales = true
        }
    }
    @objc func shareAction() {
         guard let pdfData = documentData
             else {
                 let alert = UIAlertController(title: "Não foi possível compartilhar o PDF", message: "Você deve gerar um novo PDF.", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "Entendi", style: .default, handler: nil))
                 present(alert, animated: true, completion: nil)
                 return
         }
         let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
         present(vc, animated: true, completion: nil)
     }
}
