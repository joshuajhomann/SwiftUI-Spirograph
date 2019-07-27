//
//  CurrentValueSubject+Bindable.swift
//  SpirographSwiftUI
//
//  Created by Joshua Homann on 7/23/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import SwiftUI
import Combine

extension CurrentValueSubject {
  func makeBinding() -> Binding<Output> {
    Binding<Output>(
      getValue: { self.value },
      setValue: { self.value = $0 }
    )
  }
}
