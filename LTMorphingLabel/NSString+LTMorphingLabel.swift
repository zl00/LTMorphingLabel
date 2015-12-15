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


public enum LTCharacterDiffType : Int, CustomDebugStringConvertible {
    
    case Same = 0
    case Add = 1
    case Delete
    case Move
    case MoveAndAdd
    case Replace
    
    public var debugDescription: String {
        switch self {
        case .Same:
            return "Same"
        case .Add:
            return "Add"
        case .Delete:
            return "Delete"
        case .Move:
            return "Move"
        case .MoveAndAdd:
            return "MoveAndAdd"
        default:
            return "Replace"
        }
    }
    
}


public struct LTCharacterDiffResult : CustomDebugStringConvertible {
    
    public var diffType: LTCharacterDiffType = .Add
    public var moveOffset: Int = 0
    public var skip: Bool = false
    
    public var debugDescription: String {
        switch diffType {
        case .Same:
            return "The character is unchanged."
        case .Add:
            return "A new character is ADDED."
        case .Delete:
            return "The character is DELETED."
        case .Move:
            return "The character is MOVED to \(moveOffset)."
        case .MoveAndAdd:
            return "The character is MOVED to \(moveOffset) and a new character is ADDED."
        default:
            return "The character is REPLACED with a new character."
        }
    }
    
}


public func >>(lhs: String, rhs: String) -> [LTCharacterDiffResult] {
    
    let rightChars = rhs.characters.enumerate()
    let lhsLength = lhs.characters.count
    let rhsLength = rhs.characters.count
    var skipIndexes = [Int]()
    let leftChars = Array(lhs.characters)
    
    var diffResults = Array(count: max(lhsLength, rhsLength), repeatedValue: LTCharacterDiffResult())
    
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
                if leftIndex == rightIndex {
                    // Character not changed
                    diffResults[leftIndex].diffType = .Same
                } else {
                    // foundCharacterInRhs and move
                    diffResults[leftIndex].diffType = .Move
                    if leftIndex + 1 <= rhsLength {
                        // Move to a new index and add a new character to new original place
                        diffResults[leftIndex].diffType = .MoveAndAdd
                    }
                    diffResults[leftIndex].moveOffset = rightIndex - leftIndex
                }
                break
            }
        }
        
        if !foundCharacterInRhs {
            if leftIndex + 1 <= rhs.characters.count {
                diffResults[leftIndex].diffType = .Replace
            } else {
                diffResults[leftIndex].diffType = .Delete
            }
        }
    }
    
    for (i, diffResult) in diffResults.enumerate() {
        switch diffResult.diffType {
        case .Move, .MoveAndAdd:
            diffResults[i + diffResult.moveOffset].skip = true
        default:
            ()
        }
    }
    
    return diffResults
}
