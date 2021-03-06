//
//  Scores.swift
//  minisweeper
//
//  Created by David Wu on 6/11/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import CoreData

struct Score {
    let date:     Date
    let numCols:  Int
    let numMines: Int
    let numRows:  Int
    let time:     TimeInterval
}

class ScoresController {

    private let persistentContainer: NSPersistentContainer

    init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func addScore(_ score: Score) {
        let context = persistentContainer.viewContext
        let scoreMO = ScoreMO(context: context)
        scoreMO.setValue(score.date,     forKey: "date")
        scoreMO.setValue(score.numCols,  forKey: "numCols")
        scoreMO.setValue(score.numMines, forKey: "numMines")
        scoreMO.setValue(score.numRows,  forKey: "numRows")
        scoreMO.setValue(score.time,     forKey: "time")
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Core Data context: failed to save with error \(error)")
        }
    }

    func reset() {
        let coordinator = persistentContainer.persistentStoreCoordinator
        let context = persistentContainer.viewContext
        do {
            try coordinator.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Score")),
                                    with: context)
        } catch let error as NSError {
            fatalError("Core Data coordinator: failed to execute request with error \(error)")
        }
    }
}
