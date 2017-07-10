#!/usr/bin/swift
//
//  main.swift
//  sounds-billboard
//
//  Created by Julien Di Marco on 10/07/2017.
//  Copyright © 2017 Julien Di Marco. All rights reserved.
//

/// Works in swift 4.0, developed on xcode-9b1

import Foundation

// MARK: - Constants && Defines -

let displayBillboardResult_: Bool = false

let executableName_ = "billboard"
let billboardUsage_ = """
Usage: ./billboard filePath
Compute filePath billboard logic to standard output.

 when filePath is -, read standard input.
"""


// MARK: - Helpers Function -

/// Billboard line spliter by widest billboard line
/// return billboard text split by widest lenght provided
func split(array: [String], byLenght lenght: Int) -> [String] {
  return array.reduce([], { (splits, word) in
    var mutableSplits_: [String] = splits as [String]
    let split_ = splits.last

    //print("split \"\(split_ ?? "")\" (\(split_?.characters.count ?? 0)) + \" \" + word \"\(word)\" (\(word.characters.count)) = \((split_ ?? "").characters.count + word.characters.count + 1) ")

    if let split_ = split_, (split_.characters.count < lenght) &&
      ((split_.characters.count + word.characters.count + 1) <= lenght) {
      mutableSplits_[mutableSplits_.count - 1] = "\(split_) \(word)"
    }
    else { mutableSplits_ = mutableSplits_ + [word] }

    return mutableSplits_
  })
}

/// Convenient helper computing widest billboard line from fontSize and billboard width
func split(array: [String], billboardSize: CGSize, withFontSize fontsize: Int) -> [String] {
  guard fontsize >= 1 else { return array }

  return split(array: array, byLenght: Int(billboardSize.width) / fontsize)
}

// MARK: - Logic Billboards Functions -

/// Computed Billboard FontSize recursively for specified number of lines
/// 1. if fontsize not defined use tallest possible fontsize with height and num of lines
/// 2. compute widest possible line from fontsize and billboard width
///   3. check if words to display are bigger than widest line and decrement fontsize if needed
///   4. check if text can be split by provided number of lines and width of lines, decrement fontsize if needed
/// 5. if fontsize match all conditions or fontsize <= 1 return computed fontsize
func recursiveGroupedSolution(size: CGSize, lines: Int, fontSize: Int?, text: String) -> Int {
  guard lines >= 1 else { return 1 }
  guard let fontSize = fontSize else { return recursiveGroupedSolution(size: size, lines: lines, fontSize: (Int(size.height) / lines), text: text) }
  guard fontSize >= 1 else { return 1 }

  let wordSplit_ = text.components(separatedBy: .whitespaces)
  let maxWidthCharacters = Int(size.width) / fontSize

  if (wordSplit_.contains { $0.characters.count > maxWidthCharacters }) {
    //print("words in array bigger than (\(maxWidthCharacters)) characters with (\(fontSize)) fontsize")
    return recursiveGroupedSolution(size: size, lines: lines, fontSize: fontSize - 1, text: text)
  }

  //print("widest line: \(maxWidthCharacters) chars with \(fontSize) fontSize")
  let lineSplits_ = split(array: wordSplit_, byLenght: maxWidthCharacters)
  if lineSplits_.count != lines && fontSize > 1
  { return recursiveGroupedSolution(size: size, lines: lines, fontSize: fontSize - 1, text: text) }

  //print("result billboard with (\(lines)) lines, \(fontSize) fontSize -> \(lineSplits_)")
  return fontSize
}

/// computed font size of billboard with text and billboard size
/// compute billboard fontsize depending on line number
/// increase line number until previous computation is bigger than new computation
/// return last biggest computation
func computeFontSize(size: CGSize, text: String) -> Int {
  var lines_ = 1
  var fontSize_ = 1
  var maxFontSize = 0

  repeat {
    maxFontSize = fontSize_
    fontSize_ = recursiveGroupedSolution(size: size, lines: lines_, fontSize: nil, text: text)
    lines_ += 1

    //print("lines: \(lines_), size: \(fontSize_)")
  } while( maxFontSize <= fontSize_ && lines_ <= Int(size.height));

  return maxFontSize
}

/// Process case string/line with number of case for output
/// tokenize string/line input and verify minimun of three tokens (width, height and word)
/// extract width and height as number and exit on error
/// extract rest of tokens as string separated by whitespace
/// proccess billboard logic with size and output result
func handleBillboardCase(string: String, caseNumber: Int) {
  let tokenizedString_ = string.components(separatedBy: .whitespaces)
  guard tokenizedString_.count >= 3 else { print("case #\(caseNumber): error, format string doesn't match [Width Height String]"); return }
  guard let width = Int(tokenizedString_[0]), let height = Int(tokenizedString_[1]) else { print("case #\(caseNumber): error, format string doesn't have Integer [Width] or [Height]"); return }

  let extractSize_ = CGSize(width: width, height: height)
  let extractString_ = tokenizedString_[2...].joined(separator: " ")
  let extractStringTokens_ = Array(tokenizedString_[2...])

  let computedBillboardFontSize_ = computeFontSize(size: extractSize_, text: extractString_)
  let computedBillboardDisplay_ = split(array: extractStringTokens_, billboardSize: extractSize_, withFontSize: computedBillboardFontSize_)

  print("case #\(caseNumber): \(computedBillboardFontSize_)" + (displayBillboardResult_ ? " -> \(computedBillboardDisplay_)" : ""))
}

// MARK: - Command Lines Helpers && Logics -

/// Proccess stdin input from command line
/// eg. cat testfile | ./billboard -
/// loop on readline until number of case is reached with
/// 1. attempt to extract numbe of case from first line
/// 2. proccess line and decrement number of case
func proccessBillboardOnStdin() {

  var caseNumber_ = 0
  var numberInput_: Int? = nil
  while let line = readLine(strippingNewline: true), (numberInput_ == nil || numberInput_! > 0) {
    if numberInput_ == nil {
      numberInput_ = Int(line)
      guard numberInput_ != nil else { print("\(executableName_): Error file line should indicate the number of billboard case"); exit(1) }
    } else {
      handleBillboardCase(string: line, caseNumber: caseNumber_)

      caseNumber_ += 1
      numberInput_ = numberInput_ != nil ? numberInput_! - 1 : numberInput_
    }
  }

}

/// Process filepath from command line
/// 1. check path exist
/// 2. read file and construct line array
/// 3. extract first line for number of case
/// 4. process each line until number of case is reach
func proccessBillboard(withFile filepath: String) {
  guard let file = FileHandle(forReadingAtPath: filepath) else { print("\(executableName_): \(filepath): No such file or directory") ; exit(1) }

  let data_ = file.readDataToEndOfFile()
  let string_ = String(data: data_, encoding: String.Encoding.utf8)

  let contents_ = string_?.components(separatedBy: .newlines)
  guard let contentsLines_ = contents_ else { print("\(executableName_): \(filepath): Error reading file lines"); exit(1) }
  guard contentsLines_.count >= 1 else { print("\(executableName_): \(filepath): Error content file empty"); exit(1) }
  guard let numberInput_ = Int(contentsLines_.first!) else { print("\(executableName_): \(filepath): Error file line should indicate the number of billboard case"); exit(1) }

  for caseIndex in 1...numberInput_ {
    guard contentsLines_.count > caseIndex else { print("\(executableName_): \(filepath): Error file content doesn't match case input"); exit(1) }
    handleBillboardCase(string: contentsLines_[caseIndex], caseNumber: caseIndex)
  }
}

// MARK: - Main script

let arguments = CommandLine.arguments
guard arguments.count >= 2 else { print(billboardUsage_) ; exit(1) }

// Proccess standard input
if arguments[1] == "-" { proccessBillboardOnStdin() }
else                   { proccessBillboard(withFile: arguments[1]) }
