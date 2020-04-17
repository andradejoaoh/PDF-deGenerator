//
//  PDFGenerator.swift
//  PDF deGenerator
//
//  Created by João Henrique Andrade on 14/04/20.
//  Copyright © 2020 João Henrique Andrade. All rights reserved.
//
import Foundation
import PDFKit

class PDFGenerator {
    let titulo: String
    let texto: String
    let imagem: UIImage?
    let contato: String
    
    init(titulo: String, texto: String, imagem: UIImage?, contato: String) {
        self.titulo = titulo
        self.texto = texto
        self.imagem = imagem
        self.contato = contato
    }
    
    func criarPDF() -> Data {
        // 1
        let pdfMetaData = [
            kCGPDFContextCreator: "PDF deGenerator",
            kCGPDFContextAuthor: "João Henrique Andrade",
            kCGPDFContextTitle: titulo
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // 2
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // 3
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        // 4
        let data = renderer.pdfData { (context) in
            // 5
            context.beginPage()
            // 6
            let titleBottom = addTitle(pageRect: pageRect)
            let imageBottom = addImage(pageRect: pageRect, imageTop: titleBottom + 18.0)
            if imagem != nil {
               let textBottom = addBodyText(pageRect: pageRect, textTop: imageBottom + 18.0)
                addContactText(pageRect: pageRect, contactTop: textBottom + 16)
            } else {
               let textBottom = addBodyText(pageRect: pageRect, textTop: titleBottom + 18.0)
                addContactText(pageRect: pageRect, contactTop: textBottom + 16)
            }
        }
        return data
    }
    
    func addTitle(pageRect: CGRect) -> CGFloat {
        // 1
        let titleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        // 2
        let titleAttributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: titleFont]
        // 3
        let attributedTitle = NSAttributedString(
            string: titulo,
            attributes: titleAttributes
        )
        // 4
        let titleStringSize = attributedTitle.size()
        // 5
        let titleStringRect = CGRect(
            x: (pageRect.width - titleStringSize.width) / 2.0,
            y: 36,
            width: titleStringSize.width,
            height: titleStringSize.height
        )
        // 6
        attributedTitle.draw(in: titleStringRect)
        // 7
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addBodyText(pageRect: CGRect, textTop: CGFloat) -> CGFloat {
        // 1
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        // 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        // 3
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        // 4
        let attributedText = NSAttributedString(
            string: texto,
            attributes: textAttributes
        )
        // 5
        let textRect = CGRect(
            x: 10,
            y: textTop,
            width: pageRect.width - 20,
            height: attributedText.size().height * CGFloat(attributedText.string.count)/100
        )
        // 6
        attributedText.draw(in: textRect)
        // 7
        return textRect.origin.y + textRect.size.height
    }
    
    func addContactText(pageRect: CGRect, contactTop: CGFloat) {
           let contactFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
           // 1
           let paragraphStyle = NSMutableParagraphStyle()
           paragraphStyle.alignment = .natural
           paragraphStyle.lineBreakMode = .byWordWrapping
           // 2
           let contactAttributes = [
               NSAttributedString.Key.paragraphStyle: paragraphStyle,
               NSAttributedString.Key.font: contactFont
           ]
           let attributedText = NSAttributedString(
               string: contato,
               attributes: contactAttributes
           )
           // 3
           let contactRect = CGRect(
               x: 10,
               y: contactTop,
               width: pageRect.width - 20,
               height: attributedText.size().height * CGFloat(attributedText.string.count)/75
           )
           attributedText.draw(in: contactRect)
       }
    
    func addImage(pageRect: CGRect, imageTop: CGFloat) -> CGFloat {
        guard let imagem = imagem else { return CGFloat(0)}
        let maxHeight = pageRect.height * 0.4
        let maxWidth = pageRect.width * 0.8
        // 2
        let aspectWidth = maxWidth / imagem.size.width
        let aspectHeight = maxHeight / imagem.size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        // 3
        let scaledWidth = imagem.size.width * aspectRatio
        let scaledHeight = imagem.size.height * aspectRatio
        // 4
        let imageX = (pageRect.width - scaledWidth) / 2.0
        let imageRect = CGRect(x: imageX, y: imageTop,
                               width: scaledWidth, height: scaledHeight)
        // 5
        imagem.draw(in: imageRect)
        return imageRect.origin.y + imageRect.size.height
    }
}
