//
//  NSString+LTMorphingLabel.swift
//  https://github.com/lexrus/LTMorphingLabel
//
//  The MIT License (MIT)
//  Copyright (c) 2015 Lex Tang, http://lexrus.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files
//  (the “Software”), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation


public enum LTOriginPositionActionType : CustomDebugStringConvertible {
    
    case Reuse(Int)
    case Discard
    
    public var debugDescription: String {
        switch self {
        case .Reuse(let offset):
            return "[Origin] Reuse \(offset)"
        case .Discard:
            return "[Origin] Discard"
        }
    }
}

public enum LTCurrentPositionActionType: CustomDebugStringConvertible {
    
    case New
    case Old
    case None
    
    public var debugDescription: String {
        switch self {
        case .New:
            return "[Current] New"
        case .Old:
            return "[Current] Old"
        case .None:
            return "[Current] None"
        }
    }
}

public struct LTCharacterDiffResult : CustomDebugStringConvertible {
    
    public var originPositionAct: LTOriginPositionActionType = .Discard
    public var currentPositionAct: LTCurrentPositionActionType = .New
    
    public var debugDescription: String {
        
        var info: String = ""
        
        switch originPositionAct {
        case .Reuse(let offset):
            info = "[Reuse] Move to \(offset),"
        case .Discard:
            info = "[Discard]"
        }
        
        switch currentPositionAct {
        case .New:
            info += " new"
        case .Old:
            info += " old"
        case .None:
            info += " none"
        }
        
        return info
    }
}

public func >>(lhs: String, rhs: String) -> [LTCharacterDiffResult] {
    
    let rightChars = rhs.characters.enumerate()
    let lhsLength = lhs.characters.count
    let rhsLength = rhs.characters.count
    var skipIndexes = [Int]()
    let leftChars = Array(lhs.characters)
    
    var diffResults = Array(count: max(lhsLength, rhsLength), repeatedValue: LTCharacterDiffResult())
    if rhsLength < lhsLength { for index in rhsLength..<lhsLength { diffResults[index].currentPositionAct = .None }}
    
    for leftIndex in 0..<lhsLength {
        let leftChar = leftChars[leftIndex]
        
        // Search left character in the new string
        var foundCharacterInRhs = false
        for (rightIndex, rightChar) in rightChars {
            let rightCharDidFlag = {
                (index: Int) -> Bool in
                for skipIndex in skipIndexes {
                    if index == skipIndex {
                        return true
                    }
                }
                return false
            }(rightIndex)
            
            if rightCharDidFlag {
                continue
            }
            
            if leftChar == rightChar {
                skipIndexes.append(rightIndex)
                foundCharacterInRhs = true
                
                diffResults[leftIndex].originPositionAct = .Reuse(rightIndex - leftIndex)
                diffResults[rightIndex].currentPositionAct = .Old
                break
            }
        }
        
        if !foundCharacterInRhs {
            diffResults[leftIndex].originPositionAct = .Discard
        }
    }
    
    
    return diffResults
}
