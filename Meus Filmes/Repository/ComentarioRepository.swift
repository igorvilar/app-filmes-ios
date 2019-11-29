//
//  ComentarioRepository.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 29/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit
import CoreData

struct ComentarioRepository {

    static func salvarComentario(comentario: String, idFilme: Int64) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let mensagens = Mensagens(context: managedContext)
        mensagens.comentario = comentario
        mensagens.idFilme = idFilme
        mensagens.data = Date()
        managedContext.insert(mensagens)
        try? managedContext.save()
    }
    
    static func listarMensagens(idFilme: Int64) throws -> [Mensagens]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<Mensagens>(entityName: "Mensagens")
        request.predicate = NSPredicate(format: "idFilme == %d", idFilme)
        let mensagens = try managedContext.fetch(request)
        return mensagens
    }
}
