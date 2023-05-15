import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

class SimpleMacroExpansionContext: MacroExpansionContext {
  let moduleName: String
  let fullFilePath: String
  let sourceFile: SourceFileSyntax

  init(moduleName: String, fullFilePath: String, sourceFile: SourceFileSyntax) {
    self.moduleName = moduleName
    self.fullFilePath = fullFilePath
    self.sourceFile = sourceFile
  }

  func location(
    of node: some SyntaxProtocol,
    at position: PositionInSyntaxNode,
    filePathMode: SourceLocationFilePathMode
  ) -> AbstractSourceLocation? {
    let fileName = fullFilePath
    let offsetAdjustment = 0

    let rawPosition: AbsolutePosition
    switch position {
    case .beforeLeadingTrivia:
      rawPosition = node.position
    case .afterLeadingTrivia:
      rawPosition = node.positionAfterSkippingLeadingTrivia
    case .beforeTrailingTrivia:
      rawPosition = node.endPositionBeforeTrailingTrivia
    case .afterTrailingTrivia:
      rawPosition = node.endPosition
    }

    let converter = SourceLocationConverter(file: fileName, tree: sourceFile)
    return AbstractSourceLocation(converter.location(for: rawPosition.advanced(by: offsetAdjustment)))
  }

  func makeUniqueName(_ name: String) -> TokenSyntax {
    TokenSyntax(
      .identifier("__local\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"), presence: .present
    )
  }

  func diagnose(_ diagnostic: Diagnostic) {}
}
