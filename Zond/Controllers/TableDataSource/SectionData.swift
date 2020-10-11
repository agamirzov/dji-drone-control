//
//  SectionData.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 08.04.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import CoreGraphics

enum SectionId {
    case params
    case actions

    var headerHeight: CGFloat {
        switch self {
            case .params:
                return Dimensions.tileSize
            case .actions:
                return Dimensions.tileSize
        }
    }

    var footerHeight: CGFloat {
        switch self {
            case .params:
                return 0.0
            case .actions:
                return 0.0
        }
    }
}

enum SectionType {
    case spacer

    var reuseIdentifier: String {
        switch self {
            case .spacer:
                return "spacer"
        }
    }
}

class SectionData {
    private(set) var rows: [RowData<Any>]
    let id: SectionId
    let headerHeight: CGFloat
    let footerHeight: CGFloat

    init(id: SectionId, rows: [RowData<Any>]) {
        self.id = id
        self.headerHeight = id.headerHeight
        self.footerHeight = id.footerHeight
        for row in rows {
            row.setIdPath(IdPath(id, row.id))
        }
        self.rows = rows
    }
}