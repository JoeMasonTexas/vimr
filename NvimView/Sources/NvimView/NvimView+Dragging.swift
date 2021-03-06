/**
 * Tae Won Ha - http://taewon.de - @hataewon
 * See LICENSE
 */

import Cocoa

extension NvimView {

  override public func draggingEntered(
    _ sender: NSDraggingInfo
  ) -> NSDragOperation {
    return isFile(sender: sender) ? .copy : NSDragOperation()
  }

  override public func draggingUpdated(
    _ sender: NSDraggingInfo
  ) -> NSDragOperation {
    return isFile(sender: sender) ? .copy : NSDragOperation()
  }

  override public func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    guard isFile(sender: sender) else {
      return false
    }

    guard let urls = sender.draggingPasteboard
      .readObjects(forClasses: [NSURL.self]) as? [URL] else { return false }

    self.open(urls: urls)
      .subscribeOn(self.scheduler)
      .subscribe(onError: { [weak self] error in
        self?.eventsSubject.onNext(
          .apiError(msg: "\(urls) could not be opened.", cause: error)
        )
      })
      .disposed(by: self.disposeBag)

    return true
  }
}

private func isFile(sender: NSDraggingInfo) -> Bool {
  return (sender.draggingPasteboard.types?.contains(
    NSPasteboard.PasteboardType(String(kUTTypeFileURL))
  )) ?? false
}
