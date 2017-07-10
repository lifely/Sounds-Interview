

import UIKit

/// 1. Try fitting the whole string at chars * height of frame
/// 2. Find the biggest word and try fitting this one similar to ^
/// 2. a if bigger than 1. associates words together as lines of same-ish chars counts

/// 3. after though, second solution doesn't work the best, maybe just testing by number of lines
/// so first line = find biggest font size, two line split everything and find biggest, continue until previous solution is bigger than new solution

/// compare two solutions results and use biggest size
/// recursive search for max size, could also use dichotomy

/// dichotomy :
/// try max size posible if not available / 2
/// if /2 too big continue /2 otherwise try increasing by 1.5
/// round to avoid floats

/// Options
/// include margin around frames to avoid hitting corners

/// Script Flow
/// 1. reading and parsing of first line / number of test cases
/// 2. parsing each lines, process and output
/// 3. success

func recursiveOneLineSolution(size: CGSize, fontSize: Int, text: String) -> Int {
  guard (fontSize > 1) else { return 1 }

  let computedWidth_ = (text.characters.count * fontSize)

  if computedWidth_ > Int(size.width)
  { return recursiveOneLineSolution(size: size, fontSize: (fontSize - 1), text: text) }

  //print("computedWidth (\(fontSize) * \(text.characters.count)): \(computedWidth_) <= \(size.width)")
  return fontSize
}

func recursiveMultilineSolution(size: CGSize, text: String) -> Int {
  let wordSplit_ = text.components(separatedBy: .whitespaces)
  let biggestWord_ = wordSplit_.reduce("", { ($0.characters.count > $1.characters.count) ? $0 : $1 })

  let linesSplits_ = split(array: wordSplit_, byLenght: biggestWord_.characters.count)

  print("Longuest word: \(biggestWord_) (\(biggestWord_.characters.count)), \(linesSplits_)")

  return 0
}

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

func split(array: [String], billboardSize: CGSize, withFontSize fontsize: Int) -> [String] {
  guard fontsize >= 1 else { return array }

  return split(array: array, byLenght: Int(billboardSize.width) / fontsize)
}

func recursiveGroupedSolution(size: CGSize, lines: Int, fontSize: Int?, text: String) -> Int {
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

let displayBillboardResult_ = false

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

//computeFontSize(size: CGSize(width: 20, height: 6), text: "hacker cup")
//computeFontSize(size: CGSize(width: 100, height: 20), text: "hacker cup 2013")
//computeFontSize(size: CGSize(width: 10, height: 20), text: "MUST BE ABLE TO HACK")
//computeFontSize(size: CGSize(width: 55, height: 25), text: "Can you hack")
//computeFontSize(size: CGSize(width: 100, height: 20), text: "hack your way to the cup")
//computeFontSize(size: CGSize(width: 1000, height: 1000), text: "Facebook Hacker Cup 2013")

handleBillboardCase(string: "20 6 hacker cup", caseNumber: 1)

